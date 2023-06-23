import Foundation


enum ConversionDataMapper {
    
    static func map(_ entity: ConversionData) -> ConversionDataDTO {
        ConversionDataDTO(conversionType: entity.type, conversionValue: entity.value, conversionTimeWithMilliseconds: entity.timeWithMilliseconds)
    }
}
