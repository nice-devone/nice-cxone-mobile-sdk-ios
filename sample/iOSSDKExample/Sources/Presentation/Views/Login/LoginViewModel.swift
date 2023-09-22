import CXoneChatSDK
import SwiftUI

class LoginViewModel: AnalyticsReporter, ObservableObject {
    
    // MARK: - Properties
    
    private let deeplinkOption: DeeplinkOption?
    
    private let loginWithAmazon: LoginWithAmazonUseCase
    private let getChannelConfiguration: GetChannelConfigurationUseCase
    
    private let configuration: Configuration
    private let coordinator: LoginCoordinator
    
    @Published var isLoading = true
    @Published var isLoadingTransparent = false
    @Published var shouldShowError = false
    
    // MARK: - Init
    
    init(
        coordinator: LoginCoordinator,
        configuration: Configuration,
        deeplinkOption: DeeplinkOption?,
        loginWithAmazon: LoginWithAmazonUseCase,
        getChannelConfiguration: GetChannelConfigurationUseCase
    ) {
        self.coordinator = coordinator
        self.configuration = configuration
        self.deeplinkOption = deeplinkOption
        self.loginWithAmazon = loginWithAmazon
        self.getChannelConfiguration = getChannelConfiguration
        super.init(analyticsTitle: "login", analyticsUrl: "/login")
    }
    
    // MARK: - Methods

    override func onAppear() {
        #if !targetEnvironment(simulator)
        RemoteNotificationsManager.shared.onRegistrationFinished = { [weak self] in
            self?.prepareAndFetchConfiguration()
        }
        
        RemoteNotificationsManager.shared.registerIfNeeded()
        #else
        prepareAndFetchConfiguration()
        #endif
    }
    
    func signOut() {
        RemoteNotificationsManager.shared.unregister()
        
        LocalStorageManager.reset()
        FileManager.default.eraseDocumentsFolder()
        
        coordinator.showConfigurationView()
    }
    
    func navigateToSettings() {
        coordinator.showSettingsView()
    }
    
    func navigateToStore() {
        coordinator.showDashboard(deeplinkOption: deeplinkOption)
    }
    
    func invokeLoginWithAmazon() {
        isLoading = true
        isLoadingTransparent = true
        
        Task { @MainActor in
            do {
                try await loginWithAmazon()
                
                coordinator.showDashboard(deeplinkOption: deeplinkOption)
            } catch {
                error.logError()
                
                isLoading = false
                isLoadingTransparent = false
                shouldShowError = true
            }
        }
    }
}

// MARK: - Private methods

private extension LoginViewModel {
    
    func prepareAndFetchConfiguration() {
        Task { @MainActor in
            do {
                if let env = configuration.environment {
                    try await CXoneChat.shared.connection.connect(environment: env, brandId: configuration.brandId, channelId: configuration.channelId)
                } else {
                    try await CXoneChat.shared.connection.connect(
                        chatURL: configuration.chatUrl,
                        socketURL: configuration.socketUrl,
                        brandId: configuration.brandId,
                        channelId: configuration.channelId
                    )
                }

                // Analytics need prepared CXone SDK, then it can report page view
                reportViewPage()

                let channelConfig = try await getChannelConfiguration(configuration: configuration)
                
                if !channelConfig.isAuthorizationEnabled, !UIDevice.current.isPreview {
                    coordinator.showDashboard(deeplinkOption: deeplinkOption)
                } else {
                    isLoading = false
                }
            } catch {
                error.logError()
                
                isLoading = false
                shouldShowError = true
                
                coordinator.popTo(UIHostingController<ConfigurationView>.self)
            }
        }
    }
}
