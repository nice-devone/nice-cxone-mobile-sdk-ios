//
//  File.swift
//  
//
//  Created by Tyler Hendrickson on 3/7/22.
//

import Foundation

struct ThreadData: Codable {
    let thread: ThreadDataInfo
    
    init(id: UUID) {
        thread = ThreadDataInfo(id: id)
    }
}

struct ThreadDataInfo: Codable {
    var id: String
    var idOnExternalPlatform: String

    init (id: UUID) {
        idOnExternalPlatform = id.uuidString
        self.id = "chat_\(idOnExternalPlatform)"
    }
}
