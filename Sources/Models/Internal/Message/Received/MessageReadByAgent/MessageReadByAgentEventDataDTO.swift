import Foundation


/// The data of the message read by agent event.
struct MessageReadByAgentEventDataDTO: Codable {
    
    /// The info about the brand.
    let brand: BrandDTO

    /// The info about the message.
    let message: MessageDTO
}
