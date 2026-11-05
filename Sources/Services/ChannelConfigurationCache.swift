//
// Copyright (c) 2021-2026. NICE Ltd. All rights reserved.
//
// Licensed under the NICE License;
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    https://github.com/nice-devone/nice-cxone-mobile-sdk-ios/blob/main/LICENSE
//
// TO THE EXTENT PERMITTED BY APPLICABLE LAW, THE CXONE MOBILE SDK IS PROVIDED ON
// AN "AS IS" BASIS. NICE HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS
// OR IMPLIED, INCLUDING (WITHOUT LIMITATION) WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT, AND TITLE.
//

import CXoneGuideUtility
import Foundation

/// A single cached channel configuration together with the request it answered and its expiry.
private struct ChannelConfigurationCacheEntry: Sendable {

    // MARK: - Properties

    /// The configuration as decoded from the channel endpoint.
    let configuration: ChannelConfigurationDTO

    /// The fully resolved channel URL this configuration was fetched from.
    ///
    /// Used as the cache key so a configuration is only ever replayed for the exact
    /// brand + channel + chat server it came from.
    let url: URL

    /// The instant at which this entry stops being served.
    let expiresAt: Date

    // MARK: - Methods

    /// Whether the entry may still be served at `date`.
    func isValid(at date: Date) -> Bool {
        date < expiresAt
    }
}

/// The cache's full wrapped state: the current entry plus a generation counter.
///
/// Held together in one `SafeAccessContainer` so a store can check the generation it was handed
/// against the current one and write the entry in the same lock acquisition — see
/// ``ChannelConfigurationCache/set(_:for:generation:)``.
private struct ChannelConfigurationCacheState: Sendable {

    // MARK: - Properties

    var entry: ChannelConfigurationCacheEntry?

    /// Bumped by ``ChannelConfigurationCache/invalidate()``. A store whose captured generation no
    /// longer matches this value started before the most recent invalidation and is dropped.
    var generation = 0
}

/// An in-memory, time-limited cache for the channel configuration endpoint.
///
/// The SDK would otherwise re-fetch `GET /chat/1.0/brand/{brandId}/channel/{channelId}` on every
/// app open, configuration change and `prepare(...)`. The payload changes rarely, and the backend
/// already fronts it with a five-minute Redis cache, so repeating the request mostly adds latency
/// and load. Caching it here for the same interval collapses those repeats — most visibly the
/// back-to-back pair an integrator produces by calling
/// ``ConnectionProvider/getChannelConfiguration(chatURL:brandId:channelId:)`` to render a
/// pre-chat screen and then `prepare(...)` moments later.
///
/// ## Keying
///
/// The cache holds **one entry**: the most recently fetched configuration, tagged with the
/// **fully resolved channel URL** it came from. A fetch for any other URL is a miss and replaces
/// it, so an integrator alternating between two channels gets no benefit from the cache — the
/// common case is a single channel for the lifetime of the instance.
///
/// The URL, rather than the channel ID alone, is what an entry is matched against. The public
/// entry points also take a brand ID and an environment (or an explicit chat URL), so a channel
/// ID on its own does not identify a configuration: an integrator that switches brand or
/// environment while keeping the channel ID would otherwise be served the previous brand's
/// settings. Matching on the URL also means re-initializing the SDK against a different channel
/// misses structurally — the tag simply no longer matches — with no separate invalidation step.
///
/// ## Staleness
///
/// A configuration change made in the backend can take up to the TTL to reach the device. This is
/// accepted by design: the TTL matches the backend's own cache, so the endpoint would frequently
/// serve the same stale value anyway.
///
/// ## Concurrency
///
/// Backed by `SafeAccessContainer`, so each individual operation is atomic and the cache can be
/// read and written from any isolation domain. The *check-fetch-store* sequence around a cache
/// miss is deliberately **not** serialized: two callers that miss simultaneously will both fetch,
/// and the second store simply wins. Collapsing them would need an in-flight coordinator (see
/// ``TokenRefreshCoordinator``) for no real benefit — the window is small, the request is
/// idempotent, and the backend caches it regardless.
///
/// A miss racing an ``invalidate()`` is a different hazard and *is* guarded against: without it,
/// a fetch started just before a `signOut()` could complete afterward and store the previous
/// session's configuration back into the cache, where it would be served into the next session
/// for up to a TTL. ``set(_:for:generation:)`` closes that gap — see ``currentGeneration()``.
final class ChannelConfigurationCache: Sendable {

    // MARK: - Properties

    /// How long a fetched configuration stays servable, matching the backend's Redis TTL.
    static let defaultTTL: TimeInterval = 5 * 60

    private let ttl: TimeInterval
    private let dateProvider: any DateProvider
    private let state = SafeAccessContainer<ChannelConfigurationCacheState>(ChannelConfigurationCacheState())

    // MARK: - Init

    /// - Parameters:
    ///   - ttl: How long a stored configuration stays servable. Defaults to ``defaultTTL``.
    ///   - dateProvider: The clock used to stamp and check expiry. Injected rather than read from
    ///     ``Date/provide()`` so a test can pin it per instance instead of mutating global state —
    ///     the global provider is shared across suites, which Swift Testing may run concurrently.
    ///
    /// Both parameters exist for tests and are not reachable by integrators: the whole type is
    /// internal to the SDK, as is the ``ConnectionService`` initialiser that forwards to it.
    init(
        ttl: TimeInterval = ChannelConfigurationCache.defaultTTL,
        dateProvider: any DateProvider = DateProviderImpl()
    ) {
        self.ttl = ttl
        self.dateProvider = dateProvider
    }

    // MARK: - Methods

    /// The cached configuration for `url`, or `nil` if nothing is cached for it or the entry expired.
    ///
    /// - Parameter url: The fully resolved channel URL being fetched.
    func get(for url: URL) -> ChannelConfigurationDTO? {
        guard let entry = state.content.entry, entry.url == url, entry.isValid(at: dateProvider.now) else {
            return nil
        }

        return entry.configuration
    }

    /// A token identifying the cache's current generation.
    ///
    /// Capture this **before** starting the network fetch that follows a cache miss, and pass it
    /// back to ``set(_:for:generation:)`` once the fetch resolves. If ``invalidate()`` runs while
    /// that fetch is in flight — for example a `signOut()` racing a `prepare()` that already
    /// missed the cache — the generation advances and the eventual store is dropped instead of
    /// resurrecting a configuration from before the invalidation.
    func currentGeneration() -> Int {
        state.content.generation
    }

    /// Stores `configuration` as the response for `url`, expiring one TTL from now — unless
    /// `generation` no longer matches the cache's current generation, meaning ``invalidate()`` ran
    /// after `generation` was captured. In that case the store is silently dropped.
    ///
    /// Only ever called with a configuration **as decoded from the network**. Storing a
    /// configuration taken from ``ConnectionContext/channelConfig`` would be a bug: that value has
    /// had a live ``CurrentLiveChatAvailability`` overlaid onto it, and replaying it here would
    /// stretch availability's own one-minute TTL out to this cache's five minutes. A freshly
    /// decoded configuration always carries `expires: .distantPast`, which keeps availability
    /// being re-checked on its own schedule even when this cache hits.
    ///
    /// - Parameters:
    ///   - configuration: The configuration decoded from the channel endpoint.
    ///   - url: The fully resolved channel URL it was fetched from.
    ///   - generation: The value ``currentGeneration()`` returned **before** the fetch that
    ///     produced `configuration` was started.
    func set(_ configuration: ChannelConfigurationDTO, for url: URL, generation: Int) {
        state.mutate { [dateProvider, ttl] state in
            guard generation == state.generation else {
                return
            }

            state.entry = ChannelConfigurationCacheEntry(
                configuration: configuration,
                url: url,
                expiresAt: dateProvider.now.addingTimeInterval(ttl)
            )
        }
    }

    /// Drops the cached configuration and advances the generation, forcing the next fetch to hit
    /// the network and causing any store from a fetch already in flight to be dropped.
    func invalidate() {
        state.mutate { state in
            state.entry = nil
            state.generation += 1
        }
    }
}
