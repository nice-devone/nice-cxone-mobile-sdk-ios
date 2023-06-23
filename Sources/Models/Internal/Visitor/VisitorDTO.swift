import Foundation


// Visitor

/// All information about a visitor.
struct VisitorDTO: Encodable {
    
    let customerIdentity: CustomerIdentityDTO?

    let browserFingerprint: DeviceFingerprintDTO

    let journey: JourneyDTO?

    let customVariables: [CustomVariableDTO]?
}
