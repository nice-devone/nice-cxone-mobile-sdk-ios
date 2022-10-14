import Foundation

/// Data to be sent on a page view visitor event.
public struct PageViewData: Codable {
    
    /// The unique URL or URI for the page that was viewed. Doesn't need to be a valid URL.
    public let url: String // This can be any identifier for the page; doesn't need to be URL
    
    /// A title for the page that was viewed.
    public let title: String
}
