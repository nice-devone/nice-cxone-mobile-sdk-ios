import CXoneChatSDK
import Foundation

class PreviewAnalyticsProvider: AnalyticsProvider {
    
    // MARK: - Properties
    
    var visitorId: UUID?

    // MARK: - Methods
    
    func viewPage(title: String, url: String) throws { }

    func viewPageEnded(title: String, url: String) throws { }

    func chatWindowOpen() throws { }

    func visit() throws { }

    func conversion(type: String, value: Double) throws { }

    func proactiveActionDisplay(data: CXoneChatSDK.ProactiveActionDetails) throws { }

    func proactiveActionClick(data: CXoneChatSDK.ProactiveActionDetails) throws { }

    func proactiveActionSuccess(_ isSuccess: Bool, data: CXoneChatSDK.ProactiveActionDetails) throws { }

    func customVisitorEvent(data: CXoneChatSDK.VisitorEventDataType) throws { }
}
