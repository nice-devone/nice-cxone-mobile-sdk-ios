//
//  File.swift
//  
//
//  Created by kjoe on 3/21/22.
//

import Foundation
enum VisitorEventType: String, Codable {
    case visitorVisit = "VisitorVisit"
    case pageView = "PageView"
    case chatWindowOpened = "ChatWindowOpened"
    case conversion = "Conversion"
    case proactiveActionDisplayed = "ProactiveActionDisplayed"
    case proactiveActionClicked = "ProactiveActionClicked"
    case proactiveActionSuccess = "ProactiveActionSuccess"
    case proactiveActionFailed = "ProactiveActionFailed"
    case custom = "Custom"
}
enum VisitorEventData: Encodable {
    case pageViewData(PageViewData)
    case conversionData(ConversionData)
    case proActiveAction(ProactiveActionEventData)

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .pageViewData(let data):
            try container.encode(data)
        case .conversionData(let data):
            try container.encode(data)
        case .proActiveAction(let data):
            try container.encode(data)
        }
    }
}
