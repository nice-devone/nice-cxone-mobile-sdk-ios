import Foundation

/// A custom environment with user-defined URLs for both chat and socket connections.
struct CustomEnvironment: EnvironmentDetails {
    
    let location = "Custom"
    
    let chatURL: String
    
    let socketURL: String
}
