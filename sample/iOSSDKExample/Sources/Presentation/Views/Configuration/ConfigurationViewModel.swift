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
import Swinject

class ConfigurationViewModel: ObservableObject {
    
    // MARK: - Properties
    
    private let coordinator: LoginCoordinator
    
    @Published private(set) var configurations = [Configuration]()
    @Published var brandId = ""
    @Published var channelId = ""
    @Published var environment: CXoneChatSDK.Environment = .NA1
    @Published var customConfiguration = Configuration(title: "", brandId: 0, channelId: "", environmentName: "", chatUrl: "", socketUrl: "")
    @Published var isDefaultConfigurationHidden = false
    @Published var isShowingInvalidFieldsAlert = false
    
    private var defaultConfiguration: Configuration {
        Configuration(brandId: Int(brandId) ?? 0, channelId: channelId, environment: environment)
    }
    private var currentConfiguration: Configuration {
        isDefaultConfigurationHidden ? customConfiguration : defaultConfiguration
    }
    
    // MARK: - Init
    
    init(coordinator: LoginCoordinator) {
        self.coordinator = coordinator
    }
    
    // MARK: - Methods
    
    func onAppear() {
        loadConfigurations()
    }
    
    func onConfirmButtonTapped() {
        if isConfigurationValid() {
            navigateToLogin()
        } else {
            isShowingInvalidFieldsAlert = true
        }
    }
    
    func navigateToSettings() {
        coordinator.showSettingsView()
    }
    
    func navigateToLogin() {
        coordinator.showLoginView(configuration: currentConfiguration, deeplinkOption: nil)
    }
}

// MARK: - Private methods

private extension ConfigurationViewModel {
    
    func loadConfigurations() {
        guard let filePath = Bundle.main.path(forResource: "environment", ofType: "json") else {
            Log.error(.failed("Could not get file with configurations."))
            return
        }
        
        do {
            guard let data = try String(contentsOfFile: filePath).data(using: .utf8) else {
                Log.error(.failed("Could not get data from file."))
                return
            }
            
            configurations = try Configuration.decodeList(from: data)

            if let configuration = configurations.first {
                customConfiguration = configuration
            }
        } catch {
            Log.error(.error(error))
        }
    }
    
    func isConfigurationValid() -> Bool {
        let isValid: Bool
        
        if isDefaultConfigurationHidden {
            isValid = true
        } else {
            isValid = defaultConfiguration.brandId != 0 && !defaultConfiguration.channelId.isEmpty
        }
        
        if isValid {
            LocalStorageManager.configuration = currentConfiguration
        }
        
        return isValid
    }
}
