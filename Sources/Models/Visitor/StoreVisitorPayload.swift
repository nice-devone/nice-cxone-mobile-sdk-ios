//
//  File.swift
//  
//
//  Created by kjoe on 3/22/22.
//

import Foundation
struct StoreVisitorPayload {
    let customerIdentity: CustomerIdentity?
    let browserFingerprint: BrowserFingerprint
    let journey: Journey?
    let customVariables: [CustomVariable]?
}

extension StoreVisitorPayload: Encodable {}

struct Journey {
    let referrer: Referrer
    let utm: UTM
}
extension Journey: Encodable {}

struct UTM {
    let source: String
    let medium:  String
    let campaign: String
    let term: String
    let content: String
}
extension UTM: Encodable {}

struct Referrer {
    let ur: String
}
extension Referrer: Encodable {}


struct CustomVariable {
    let identifier: String
    let value: String
}
extension CustomVariable: Encodable {}
