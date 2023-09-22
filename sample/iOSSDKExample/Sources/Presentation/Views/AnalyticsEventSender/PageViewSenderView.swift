import CXoneChatSDK
import SwiftUI

struct PageViewSenderView: View {
    
    // MARK: - Properties

    let analyticsProvider: AnalyticsProvider
    @State var title: String = ""
    @State var url: String = ""

    // MARK: - Content

    var body: some View {
        EventSenderView(label: "Page View") {
            Task {
                do {
                    try await analyticsProvider.viewPage(title: title, url: url)
                } catch {
                    error.logError()
                }
            }
        } enabled: {
            !title.isEmpty && !url.isEmpty
        } content: {
            ValidatedTextField("Title", text: $title, validator: required)
            
            ValidatedTextField("URL", text: $url, validator: required)
        }
    }
}
