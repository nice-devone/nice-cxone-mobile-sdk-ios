import Foundation


enum ConversionDataMapper {
    
    static func map(_ entity: ConversionData) -> ConversionDataDTO {
        .init(conversionType: entity.type, conversionValue: entity.value, conversionTimeWithMilliseconds: entity.timeWithMilliseconds)
    }
}
