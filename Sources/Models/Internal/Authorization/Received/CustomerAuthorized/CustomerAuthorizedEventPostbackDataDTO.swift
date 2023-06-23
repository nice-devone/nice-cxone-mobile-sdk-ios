import Foundation


/// Represents info about data of a customer authorized postback event.
struct CustomerAuthorizedEventPostbackDataDTO: Decodable {
    
    /// The identity of the ustomer.
    let consumerIdentity: CustomerIdentityDTO

    /// An access token used by the customer for sending messages if OAuth authorization is on for the channel.
    let accessToken: AccessTokenDTO?
}
