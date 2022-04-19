//
//  File.swift
//  
//
//  Created by Customer Dynamics Development on 11/23/21.
//

import Foundation

/// data of the `SetConsumerCustomFieldPayload`
public struct SetCustomerCustomFieldData {
	var customFields: [CustomField]
    public init(customFields: [CustomField]){
        self.customFields = customFields
    }
}
extension SetCustomerCustomFieldData: Codable {}


/// A different way to call a thread specifically for the CustomFields
public struct CustomFieldThreadCodable {
	public var id: String
	public var idOnExternalPlatform: String
    public init (
        id: String, idOnExternalPlatform: String
    ){
        self.id = id
        self.idOnExternalPlatform = idOnExternalPlatform
    }
}
extension CustomFieldThreadCodable: Codable {}


