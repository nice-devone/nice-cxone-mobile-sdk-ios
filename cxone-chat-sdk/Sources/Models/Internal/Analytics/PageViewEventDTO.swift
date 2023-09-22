import Foundation

struct PageViewEventDTO {

    let title: String
    
    let url: String
    
    // Used for ``AnalyticsProvider/viewPageEnded(title:url:)`` method to be able to calculate a time spent on page.
    let timestamp: Date
}

// MARK: - Encodable

extension PageViewEventDTO: Encodable {
    
    enum CodingKeys: CodingKey {
        case title
        case url
    }
}
