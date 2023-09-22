import Foundation

struct TimeSpentOnPageEventDTO: Encodable {

    let url: String

    let title: String

    let timeSpentOnPage: Int
}
