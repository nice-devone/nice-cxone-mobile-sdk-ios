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

import CXoneChatSDK
import SwiftUI
import UIKit

class SettingsViewModel: ObservableObject {
    
    // MARK: - Properties
    
    @Published var presentingBrandLogoActionSheet = false
    @Published var shouldShareLogs = false
    @Published var showingFileManager = false
    @Published var showingImagePicker = false
    @Published var showRemoveLogsAlert = false
    
    var brandLogo = try? UIImage.load("brandLogo.png", from: .documentDirectory)
    
    let sdkVersion = CXoneChat.version
    
    var navigationBarColor: UIColor { ChatAppearance.navigationBarColor }
    var navigationElementsColor: UIColor { ChatAppearance.navigationElementsColor }
    var backgroundColor: UIColor { ChatAppearance.backgroundColor }
    var agentCellColor: UIColor { ChatAppearance.agentCellColor }
    var customerCellColor: UIColor { ChatAppearance.customerCellColor }
    var agentFontColor: UIColor { ChatAppearance.agentFontColor }
    var customerFontColor: UIColor { ChatAppearance.customerFontColor }
    
    // MARK: - Functions
    
    func removeLogs() -> String {
        do {
            try Log.removeLogs()
            
            return L10n.Settings.Logs.Remove.Message.success
        } catch {
            return L10n.Settings.Logs.Remove.Message.failure
        }
    }
    
    func brandLogoImage() -> Image {
        if let image = brandLogo {
            return Image(uiImage: image)
        } else {
            return Asset.Settings.brandLogoPlaceholder
        }
    }
    
    func colorDidChange(color: UIColor, for title: String) {
        switch title {
        case L10n.Settings.Theme.ChatNavigationBarColorField.placeholder:
            onNavigationBarColorChanged(color)
        case L10n.Settings.Theme.ChatNavigationElementsColorField.placeholder:
            onNavigationElementsColorChanged(color)
        case L10n.Settings.Theme.ChatBackgroundColorField.placeholder:
            onBackgroundColorChanged(color)
        case L10n.Settings.Theme.ChatAgentCellColorField.placeholder:
            onAgentCellColorChanged(color)
        case L10n.Settings.Theme.ChatCustomerCellColorField.placeholder:
            onCustomerCellColorChanged(color)
        case L10n.Settings.Theme.ChatAgentFontColorField.placeholder:
            onAgentFontColorChanged(color)
        case L10n.Settings.Theme.ChatCustomerFontColorField.placeholder:
            onCustomerFontColorChanged(color)
        default:
            return
        }
    }
}

// MARK: - Private methods

private extension SettingsViewModel {
    
    func onNavigationBarColorChanged(_ color: UIColor?) {
        if UIApplication.isDarkModeActive {
            LocalStorageManager.chatNavigationBarDarkColor = color
        } else {
            LocalStorageManager.chatNavigationBarLightColor = color
        }
    }

    func onNavigationElementsColorChanged(_ color: UIColor?) {
        if UIApplication.isDarkModeActive {
            LocalStorageManager.chatNavigationElementsDarkColor = color
        } else {
            LocalStorageManager.chatNavigationElementsLightColor = color
        }
    }

    func onBackgroundColorChanged(_ color: UIColor?) {
        if UIApplication.isDarkModeActive {
            LocalStorageManager.chatBackgroundDarkColor = color
        } else {
            LocalStorageManager.chatBbackgroundLightColor = color
        }
    }

    func onAgentCellColorChanged(_ color: UIColor?) {
        if UIApplication.isDarkModeActive {
            LocalStorageManager.chatAgentCellDarkColor = color
        } else {
            LocalStorageManager.chatAgentCellLightColor = color
        }
    }

    func onCustomerCellColorChanged(_ color: UIColor?) {
        if UIApplication.isDarkModeActive {
            LocalStorageManager.chatCustomerCellDarkColor = color
        } else {
            LocalStorageManager.chatCustomerCellLightColor = color
        }
    }

    func onAgentFontColorChanged(_ color: UIColor?) {
        if UIApplication.isDarkModeActive {
            LocalStorageManager.chatAgentFontDarkColor = color
        } else {
            LocalStorageManager.chatAgentFontLightColor = color
        }
    }

    func onCustomerFontColorChanged(_ color: UIColor?) {
        if UIApplication.isDarkModeActive {
            LocalStorageManager.chatCustomerFontDarkColor = color
        } else {
            LocalStorageManager.chatCustomerFontLightColor = color
        }
    }
}
