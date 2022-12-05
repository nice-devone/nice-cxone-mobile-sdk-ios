import Foundation


/// Data to be sent on a page view visitor event.
public struct PageViewData: Codable {
    
    /// The unique URL or URI for the page that was viewed. Doesn't need to be a valid URL.
    public let url: String
    
    /// A title for the page that was viewed.
    public let title: String
}
