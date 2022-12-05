import Foundation


// Visitor

/// All information about a visitor.
struct VisitorDTO: Encodable {
    
    let customerIdentity: CustomerIdentityDTO?

    let browserFingerprint: BrowserFingerprintDTO

    let journey: JourneyDTO?

    let customVariables: [CustomVariableDTO]?
}
