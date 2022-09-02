import Foundation

// Visitor

/// All information about a visitor.
struct Visitor: Encodable {
    let customerIdentity: CustomerIdentity?
    let browserFingerprint: BrowserFingerprint
    let journey: Journey?
    let customVariables: [CustomVariable]?
}
