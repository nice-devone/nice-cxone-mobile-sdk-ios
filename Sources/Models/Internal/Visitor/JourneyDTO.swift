import Foundation


struct JourneyDTO: Encodable {
    
    // MARK: - Properties
    
    let url: String

    let utm: UTMDTO
    
    
    // MARK: - Codable
    
    enum CodingKeys: CodingKey {
        case referrer
        case utm
    }
    
    enum ReferrerKeys: CodingKey {
        case url
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var referrerCOntainer = container.nestedContainer(keyedBy: ReferrerKeys.self, forKey: .referrer)
        
        try referrerCOntainer.encode(url, forKey: .url)
        try container.encode(utm, forKey: .utm)
    }
}
