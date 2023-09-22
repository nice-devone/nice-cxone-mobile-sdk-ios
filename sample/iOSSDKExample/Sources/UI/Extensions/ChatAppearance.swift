import UIKit

enum ChatAppearance {

    static var navigationBarColor: UIColor {
        .themedColor(
            light: LocalStorageManager.chatNavigationBarLightColor ?? .systemBackground,
            dark: LocalStorageManager.chatNavigationBarDarkColor ?? .systemBackground
        )
    }
    static var navigationElementsColor: UIColor {
        .themedColor(
            light: LocalStorageManager.chatNavigationElementsLightColor ?? .systemBlue,
            dark: LocalStorageManager.chatNavigationElementsDarkColor ?? .systemBlue
        )
    }
    static var backgroundColor: UIColor {
        .themedColor(
            light: LocalStorageManager.chatBbackgroundLightColor ?? .systemBackground,
            dark: LocalStorageManager.chatBackgroundDarkColor ?? .systemBackground
        )
    }
    static var agentCellColor: UIColor {
        .themedColor(
            light: LocalStorageManager.chatAgentCellLightColor ?? .lightGray,
            dark: LocalStorageManager.chatAgentCellDarkColor ?? .lightGray
        )
    }
    static var customerCellColor: UIColor {
        .themedColor(
            light: LocalStorageManager.chatCustomerCellLightColor ?? .systemBlue,
            dark: LocalStorageManager.chatCustomerCellDarkColor ?? .systemBlue
        )
    }
    static var agentFontColor: UIColor {
        .themedColor(
            light: LocalStorageManager.chatAgentFontLightColor ?? .black,
            dark: LocalStorageManager.chatAgentFontDarkColor ?? .black
        )
    }
    static var customerFontColor: UIColor {
        .themedColor(
            light: LocalStorageManager.chatCustomerFontLightColor ?? .white,
            dark: LocalStorageManager.chatCustomerFontDarkColor ?? .white
        )
    }
}
