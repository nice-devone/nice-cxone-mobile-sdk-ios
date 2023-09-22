import CXoneChatSDK
import UIKit

class AnalyticsReporter {
    
    // MARK: - Properties
    
    private let analyticsTitle: String
    private let analyticsUrl: String
    
    // MARK: - Lifecycle
    
    init(analyticsTitle: String, analyticsUrl: String) {
        self.analyticsTitle = analyticsTitle
        self.analyticsUrl = analyticsUrl
        
        NotificationCenter.default.addObserver(self, selector: #selector(onViewDidAppear), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    deinit {
        onDisappear()
    }
    
    // MARK: - Methods
    
    func onAppear() {
        onViewDidAppear()
    }
    
    func onDisappear() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
	}

    func reportViewPage() {
        onViewDidAppear()
    }
}

// MARK: - Private methods

private extension AnalyticsReporter {
    
    @objc
    func didEnterBackground() {
        guard !analyticsTitle.isEmpty, !analyticsUrl.isEmpty else {
            fatalError("Title or Uri has not been set correctly")
        }
        
        Task {
            do {
                try await CXoneChat.shared.analytics.viewPageEnded(title: analyticsTitle, url: analyticsUrl)
            } catch {
                error.logError()
            }
        }
    }
    
    @objc
    func onViewDidAppear() {
        guard !analyticsTitle.isEmpty, !analyticsUrl.isEmpty else {
            fatalError("Title or Uri has not been set correctly")
        }
        
        Task {
            do {
                try await CXoneChat.shared.analytics.viewPage(title: analyticsTitle, url: analyticsUrl)
            } catch {
                error.logError()
            }
        }
    }
}
