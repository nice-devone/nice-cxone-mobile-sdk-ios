@testable import CXoneChatSDK
import Foundation


class DateProviderMock: DateProvider {
    
    var now: Date = Calendar.current.startOfDay(for: Date())
}
