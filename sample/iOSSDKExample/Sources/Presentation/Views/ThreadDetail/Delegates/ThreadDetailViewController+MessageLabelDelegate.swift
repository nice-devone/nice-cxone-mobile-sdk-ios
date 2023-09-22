import MessageKit
import UIKit

extension ThreadDetailViewController: MessageLabelDelegate {
    
    func didSelectAddress(_ addressComponents: [String: String]) {
        Log.info("Address Selected: \(addressComponents)")
	}
	
    func didSelectDate(_ date: Date) {
        Log.info("Date Selected: \(date)")
	}
	
    func didSelectPhoneNumber(_ phoneNumber: String) {
        Log.info("Phone Number Selected: \(phoneNumber)")
	}
	
    func didSelectURL(_ url: URL) {
        Log.info("URL Selected: \(url)")
        
        present(WKWebViewController(url: url), animated: true)
	}
	
    func didSelectTransitInformation(_ transitInformation: [String: String]) {
        Log.info("TransitInformation Selected: \(transitInformation)")
	}

    func didSelectHashtag(_ hashtag: String) {
        Log.info("Hashtag selected: \(hashtag)")
	}

    func didSelectMention(_ mention: String) {
        Log.info("Mention selected: \(mention)")
	}

    func didSelectCustom(_ pattern: String, match: String?) {
        Log.info("Custom data detector patter selected: \(pattern)")
	}
}
