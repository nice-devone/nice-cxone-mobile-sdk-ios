import Foundation

internal extension Sequence {
    /// asynchronously map a sequence
    ///
    /// `transform` will be synchronously applied to each element in
    /// the receiver and the results coalesced into a single output
    /// array.
    ///
    /// - parameter transform: transform to apply to each element.
    /// - Throws: rethrows any exception thrown by `transform`
    /// - returns: an array of the results of each trasnform application
    func asyncMap<T>(
        _ transform: (Element) async throws -> T
    ) async rethrows -> [T] {
        var values = [T]()

        for element in self {
            try await values.append(transform(element))
        }

        return values
    }
}
