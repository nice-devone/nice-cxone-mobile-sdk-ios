import Foundation
import UIKit

/// Represents fingerprint data about the customer.
public struct BrowserFingerprint: Codable {
    var browser = ""
    var browserVersion = ""
    var country = ""
    var ip = ""
    var language = ""
    var location = ""
    
    /// The type of application the customer is using (native or web app).
    internal var applicationType = "native"
    
    /// The operating system the customer is currently using.
    internal var os = "iOS"
    
    /// The operating system version that the customer is currently using.
    internal var osVersion: String = UIDevice.current.systemVersion
    
    /// The type of device that the customer is currently using.
    var deviceType = "mobile"
    public var deviceToken = ""
}
