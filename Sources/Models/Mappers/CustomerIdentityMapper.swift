import Foundation


enum CustomerIdentityMapper {
    
    static func map(_ entity: CustomerIdentity) -> CustomerIdentityDTO {
        CustomerIdentityDTO(idOnExternalPlatform: entity.id, firstName: entity.firstName, lastName: entity.lastName)
    }
    
    static func map(_ entity: CustomerIdentityDTO) -> CustomerIdentity {
        CustomerIdentity(id: entity.idOnExternalPlatform, firstName: entity.firstName, lastName: entity.lastName)
    }
}
