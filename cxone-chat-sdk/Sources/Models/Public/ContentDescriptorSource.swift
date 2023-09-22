import Foundation

/// describes the details of data attached to a `ContentDescriptor`
public enum ContentDescriptorSource {
    /// data is an array of bytes contained in a `Data` object
    case bytes(Data)
    /// data is referenced by URL
    case url(URL)
}

// MARK: - CustomStringConvertible

extension ContentDescriptorSource: CustomStringConvertible {
    public var description: String {
        switch self {
        case .bytes(let data):  return "ContentDescriptorSource.bytes(length=\(data.count))"
        case .url(let url):     return "ContentDescriptorSource.uri(uri=\(url))"
        }
    }
}
