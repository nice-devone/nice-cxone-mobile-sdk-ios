import Foundation

/// Runtime feature flags defined in the bundle file..
///
/// Features, which are correctly defined in the `Settings.bundle` file and added as a case to the FeatureFlag manager,
/// appear in the native Settings application and those feature can be changed without editing single line of code.
/// Apple docs: https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/UserDefaults/Preferences/Preferences.html
///
/// Steps to create a feature flag:
/// - add `Toggle Switch` row to the `Root.plist` in the `Settings.bundle`.
/// - add new case to the `FeatureFlag` manager  with same identifier of the added feature flag in the `Root.plist`.
///
/// Usage:
/// ```swift
/// if FeatureFlag.enableFeature.isActive {
///     ...
/// } else {
///     ...
/// }
/// ```
/// - Warning: Feature Flag manager is handling  only `Toggle Switch`. Rest of types (Textfield, Slider, Title, ...) are not supported.
enum FeatureFlag: String {
    
    // MARK: - Debug Features
    
    case enableDebugButtonInConfig
    
    // MARK: - Properties
    
    var isActive: Bool {
        UserDefaults.standard.bool(forKey: self.rawValue)
    }
    
    // MARK: - Methods
    
    static func registerFeatureFlags() {
        let defaultsToRegister = [String: AnyObject]()
        UserDefaults.standard.register(defaults: defaultsToRegister)
    }
}
