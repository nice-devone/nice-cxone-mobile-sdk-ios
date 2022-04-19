//
//  File.swift
//  
//
//  Created by kjoe on 3/21/22.
//

import Foundation
struct VisitorEvent {
    public let id: String
    public let brandId: Int
    public let type: VisitorEventType
    public let visitorId: String
    public let destinationId: String
    public let channelId: String
    public let createdAtWithMilliseconds: String
    public let data: VisitorEventData?
}
 extension VisitorEvent: Encodable {}
