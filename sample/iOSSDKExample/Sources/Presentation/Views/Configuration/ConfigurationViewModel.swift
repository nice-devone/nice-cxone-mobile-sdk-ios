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
