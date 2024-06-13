//
// Copyright (c) 2021-2024. NICE Ltd. All rights reserved.
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

/// The provider for chat fields related properties and methods.
public protocol ContactCustomFieldsProvider {
    
    /// Custom fields for current chat case.
    ///
    /// - Parameter threadId: The unique identifier of the thread for the custom fields.
    ///
    /// - Returns: Dictionary of custom fields for current chat case.
    func get(for threadId: UUID) -> [String: String]
    
    /// Sets custom fields to be saved on a contact (specific thread).
    ///
    /// - Parameters:
    ///   - customFields: The custom fields to be saved.
    ///   - threadId: The unique identifier of the thread for the custom fields.
    ///   
    /// - Throws: ``CXoneChatError/notConnected`` if an attempt was made to use a method without connecting first.
    ///     Make sure you call the `connect` method first.
    /// - Throws: ``CXoneChatError/customerAssociationFailure`` if the SDK could not get customer identity and it may not have been set.
    /// - Throws: ``EncodingError.invalidValue(_:_:)`` if the given value is invalid in the current context for this format.
    func set(_ customFields: [String: String], for threadId: UUID) throws
}
