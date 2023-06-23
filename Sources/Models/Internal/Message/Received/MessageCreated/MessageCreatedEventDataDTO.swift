import Foundation


/// Represents all info about data of a message created event.
struct MessageCreatedEventDataDTO: Decodable {
    
    /// The unique id of the brand.
    let brand: BrandDTO

    /// The unique identifier of the channel.
    let channel: ChannelIdentifierDTO

    /// The info about a contact (case).
    let `case`: ContactDTO

    /// The info about a thread from the socket.
    let thread: ThreadDTO

    /// The info about a message in a chat.
    let message: MessageDTO
}
