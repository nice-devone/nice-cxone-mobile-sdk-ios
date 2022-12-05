import Foundation


/// The provider for connection related properties and methods.
public protocol ConnectionProvider {

    /// The current channel configuration for currently connected CXone session.
    var channelConfiguration: ChannelConfiguration { get }
    
    /// Makes an HTTP request to get the channel configuration details.
    /// - Parameters:
    ///   - environment: The CXone ``Environment`` used to connect. Relates to your location.
    ///   - brandId: The unique id of the brand for which to open the connection.
    ///   - channelId: The unique id of the channel for the connection.
    ///   - Returns: Channel configuration details
    func getChannelConfiguration(environment: Environment, brandId: Int, channelId: String) async throws -> ChannelConfiguration
    
    /// Makes an HTTP request to get the channel configuration details.
    /// - Parameters:
    ///   - chatURL: The chat URL for the custom environment.
    ///   - brandId: The unique id of the brand for which to open the connection.
    ///   - channelId: The unique id of the channel for the connection.
    ///   - completion: Completion handler to be called when the request is successful or fails.
    ///   ///   - Returns: Channel configuration details
    func getChannelConfiguration(chatURL: String, brandId: Int, channelId: String) async throws -> ChannelConfiguration
    
    /// Connects to the CXone service and configures the SDK for use.
    /// - Parameters:
    ///   - environment: The CXone ``Environment`` used to connect. Relates to your location.
    ///   - brandId: The unique id of the brand for which to open the connection.
    ///   - channelId: The unique id of the channel for the connection.
    func connect(environment: Environment, brandId: Int, channelId: String) async throws
    
    /// Connects to the CXone service and configures the SDK for use.
    /// - Parameters:
    ///   - chatURL: The URL to be used for chat requests (channel config and attachment upload).
    ///   - socketURL: The URL to be used for the WebSocket connection.
    ///   - brandId: The unique id of the brand for which to open the connection.
    ///   - channelId: The unique id of the channel for the connection.
    func connect(chatURL: String, socketURL: String, brandId: Int, channelId: String) async throws
    
    /// Disconnects from the CXone service and keeps the customer signed in.
    func disconnect()
    
    /// Pings the CXone chat server to ensure that a connection is established.
    func ping()
    
    /// Manually executes a trigger that was defined in CXone. This can be used to test that proactive actions are displaying.
    /// - Parameter triggerId: The id of the trigger to manually execute.
    func executeTrigger(_ triggerId: UUID) throws
}
