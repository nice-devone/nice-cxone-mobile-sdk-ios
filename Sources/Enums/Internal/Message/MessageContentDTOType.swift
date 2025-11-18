//
// Copyright (c) 2021-2025. NICE Ltd. All rights reserved.
//
// Licensed under the NICE License;
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    https://github.com/nice-devone/nice-cxone-mobile-sdk-ios/blob/main/LICENSE
//
// TO THE EXTENT PERMITTED BY APPLICABLE LAW, THE CXONE MOBILE SDK IS PROVIDED ON
// AN “AS IS” BASIS. NICE HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS
// OR IMPLIED, INCLUDING (WITHOUT LIMITATION) WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT, AND TITLE.
//

import Foundation

enum MessageContentDTOType: Equatable {
    
    // MARK: - Cases
    
    case text(MessagePayloadDTO)
        
    case richLink(MessageRichLinkDTO)
    
    case quickReplies(MessageQuickRepliesDTO)
    
    case listPicker(MessageListPickerDTO)
    
    case inactivityPopup(MessageInactivityPopupDTO)
    
    case postback(MessagePostbackDTO)
    
    case unknown(fallbackText: String?)
    
    // MARK: - ElementType
    
    var type: ElementType {
        switch self {
        case .text:
            return .text
        case .richLink:
            return .richLink
        case .quickReplies:
            return .quickReplies
        case .listPicker:
            return .listPicker
        case .inactivityPopup:
            return .inactivityPopup
        case .postback:
            return .postback
        case .unknown:
            return .unknown
        }
    }
}

// MARK: - Codable

extension MessageContentDTOType: Codable {
    
    enum CodingKeys: CodingKey {
        case type
        case payload
        case parameters
        case postback
        case fallbackText
    }
    
    enum TextPayloadKeys: CodingKey {
        case text
    }
    
    enum UnsupportedPayloadKeys: CodingKey {
        case payload
    }
    enum UnsupportedElementsKeys: CodingKey {
        case elements
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        switch try container.decode(ElementType.self, forKey: .type) {
        case .text:
            let payloadContainer = try container.nestedContainer(keyedBy: TextPayloadKeys.self, forKey: .payload)
            
            let parameters = try container.decodeIfPresent(Parameters.self, forKey: .parameters)
            
            self = .text(
                MessagePayloadDTO(
                    text: try payloadContainer.decode(String.self, forKey: .text),
                    postback: try container.decodeIfPresent(String.self, forKey: .postback),
                    parameters: parameters?.toDictionary ?? [String: AnyValue]()
                )
            )
        case .richLink:
            self = .richLink(try container.decode(MessageRichLinkDTO.self, forKey: .payload))
        case .quickReplies:
            self = .quickReplies(try container.decode(MessageQuickRepliesDTO.self, forKey: .payload))
        case .listPicker:
            self = .listPicker(try container.decode(MessageListPickerDTO.self, forKey: .payload))
        case .plugin:
            let plugin = try container.decode(MessagePluginDTO.self, forKey: .payload)
            
            if case .inactivityPopup(let entity) = plugin.type {
                self = .inactivityPopup(entity)
            } else {
                // Only "INACITIVITY_POPUP" plugin is supported, other plugins are treated as unknown
                self = .unknown(fallbackText: try Self.getFallbackForUnsupportedMessage(from: container))
            }
        case .inactivityPopup:
            self = .inactivityPopup(try container.decode(MessageInactivityPopupDTO.self, forKey: .payload))
        case .postback:
            self = .postback(try container.decode(MessagePostbackDTO.self, forKey: .payload))
        default:
            self = .unknown(fallbackText: try Self.getFallbackForUnsupportedMessage(from: container))
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .text(let text):
            var payloadContainer = container.nestedContainer(keyedBy: TextPayloadKeys.self, forKey: .payload)
            
            try container.encode(ElementType.text.rawValue, forKey: .type)
            try payloadContainer.encode(text.text, forKey: .text)
            try container.encode(text.parameters, forKey: .parameters)
            try container.encode(text.postback, forKey: .postback)
        case .richLink(let richLink):
            try container.encode(ElementType.richLink.rawValue, forKey: .type)
            try container.encode(richLink, forKey: .payload)
        case .quickReplies(let quickReplies):
            try container.encode(ElementType.quickReplies.rawValue, forKey: .type)
            try container.encode(quickReplies, forKey: .payload)
        case .listPicker(let listPicker):
            try container.encode(ElementType.listPicker.rawValue, forKey: .type)
            try container.encode(listPicker, forKey: .payload)
        case .inactivityPopup(let popup):
            #if DEBUG
            try container.encode(ElementType.plugin.rawValue, forKey: .type)
            try container.encode(MessagePluginDTO(type: .inactivityPopup(popup)), forKey: .payload)
            #else
                LogManager.warning("Encoding of inactivity popup message type is not supported.")
            #endif
        case .postback:
            LogManager.warning("Encoding of postback message type is not supported.")
        case .unknown:
            LogManager.warning("Encoding of unknown message type is not supported.")
        }
    }
}

// MARK: - Helpers

private extension MessageContentDTOType {
    
    struct UnsupportedElement: Decodable {
        let type: String
    }
    
    static let galleryType: String = "GALLERY"
    static let unknownType: String = "UNKNOWN"
    
    static func getFallbackForUnsupportedMessage(from container: KeyedDecodingContainer<MessageContentDTOType.CodingKeys>) throws -> String? {
        let unsupportedElementsContainer = try container.nestedContainer(keyedBy: UnsupportedElementsKeys.self, forKey: .payload)
        let elements = try unsupportedElementsContainer.decode([UnsupportedElement].self, forKey: .elements)
        
        let nestedElementType: String = {
            if elements.count > 1 {
                Self.galleryType
            } else {
                elements.first?.type ?? Self.unknownType
            }
        }()
        
        let fallbackText = try container.decodeIfPresent(String.self, forKey: .fallbackText)
        let messageType = try container.decode(String.self, forKey: .type)
        
        if let fallbackText {
            return String(format: "%@:\n%@ – %@", fallbackText, messageType, nestedElementType)
        } else {
            return String(format: "%@ – %@", messageType, nestedElementType)
        }
    }
}

/// A private enum that represents either a single dictionary of parameters or an array of such dictionaries.
///
/// `Parameters` is used to decode dynamic JSON input that can be either:
/// - A single dictionary (`[String: AnyValue]`)
/// - An array of dictionaries (`[[String: AnyValue]]`)
///
/// This is useful in scenarios where an API or data source may return either a single object or a list of objects
/// under the same key, and you want to handle both cases uniformly.
///
/// ## Decoding
/// The initializer attempts to decode the input as a single dictionary first. If that fails,
/// it tries to decode it as an array of dictionaries. If both fail, it throws a `DecodingError`.
private enum Parameters: Decodable {
    
    // MARK: - Cases

    case single([String: AnyValue])
    case multiple([[String: AnyValue]])
    
    // MARK: - Computed Properties

    var toDictionary: [String: AnyValue] {
        switch self {
        case .single(let dictionary):
            return dictionary
        case .multiple(let arrayOfDicts):
            return arrayOfDicts.reduce(into: [String: AnyValue]()) { result, dict in
                dict.forEach { key, value in
                    result[key] = value
                }
            }
        }
    }
    
    // MARK: - Init

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let single = try? container.decode([String: AnyValue].self) {
            self = .single(single)
        } else if let multiple = try? container.decode([[String: AnyValue]].self) {
            self = .multiple(multiple)
        } else {
            throw DecodingError.typeMismatch(
                Parameters.self,
                DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Expected dictionary or array of dictionaries")
            )
        }
    }
}
