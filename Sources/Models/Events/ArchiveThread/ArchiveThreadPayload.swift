//
//  File.swift
//  
//
//  Created by Tyler Hendrickson on 3/5/22.
//

import Foundation

public struct ArchiveThreadPayload: Codable {
    var brand: Brand
    var channel: Channel
    var consumerIdentity: CustomerIdentity
    var eventType: String
    var data: ArchiveThreadData
}
