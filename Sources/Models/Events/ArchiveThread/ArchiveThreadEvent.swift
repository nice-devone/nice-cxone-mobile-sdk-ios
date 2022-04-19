//
//  File.swift
//  
//
//  Created by kjoe on 1/28/22.
//

import Foundation

public struct ArchiveThreadEvent: Codable {
    var action: String
    var eventId: String
    var payload: ArchiveThreadPayload
}
