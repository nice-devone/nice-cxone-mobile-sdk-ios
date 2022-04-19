//
//  File.swift
//  
//
//  Created by kjoe on 3/21/22.
//

import Foundation
struct ConversionData {
    public let conversionType: String
    public let conversionValue: Int // Can be any type? Shown as number in docs
    public let conversionTimeWithMilliseconds: String
}
extension ConversionData: Codable {}

struct PageViewData {
    public let url: String // This can be any identifier for the page; doesn't need to be URL
    public let title: String
}
extension PageViewData: Codable {}

public struct ProactiveActionEventData {
    let actionId: String
    let actionName: String
    let actionType: String    
}
extension ProactiveActionEventData: Codable {}
