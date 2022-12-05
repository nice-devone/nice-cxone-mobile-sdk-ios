import Foundation


enum CustomerIdentityMapper {
    
    static func map(_ entity: CustomerIdentity) -> CustomerIdentityDTO {
        .init(idOnExternalPlatform: entity.id, firstName: entity.firstName, lastName: entity.lastName)
    }
    
    static func map(_ entity: CustomerIdentityDTO) -> CustomerIdentity {
        .init(id: entity.idOnExternalPlatform, firstName: entity.firstName, lastName: entity.lastName)
    }
}
