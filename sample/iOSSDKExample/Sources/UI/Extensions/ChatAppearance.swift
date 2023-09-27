//
// Copyright (c) 2021-2023. NICE Ltd. All rights reserved.
//
// Licensed under the NICE License;
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    https://github.com/nice-devone/nice-cxone-mobile-sdk-ios/blob/main/LICENSE
//
// TO THE EXTENT PERMITTED BY APPLICABLE LAW, THE CXONE MOBILE SDK IS PROVIDED ON
// AN “AS IS” BASIS. NICE HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS
// OR IMPLIED, INCLUDING (WITHOUT LIMITATION) WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT, AND TITLE.
//

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
