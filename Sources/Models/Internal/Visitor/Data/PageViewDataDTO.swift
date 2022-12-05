import Foundation


/// Data to be sent on a page view visitor event.
struct PageViewDataDTO: Codable {
    
    /// The unique URL or URI for the page that was viewed. Doesn't need to be a valid URL.
    let url: String
    
    /// A title for the page that was viewed.
    let title: String
}
