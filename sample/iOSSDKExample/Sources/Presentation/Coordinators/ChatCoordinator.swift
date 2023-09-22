import CXoneChatSDK
import SwiftUI
import Swinject
import Toast
import UIKit

class ChatCoordinator: Coordinator {
    
    // MARK: - Properties
    
    var popToConfiguration: (() -> Void)?
    
    // MARK: - Methods
    
    func start(with deeplinkOption: DeeplinkOption?) {
        guard let storedConfiguration = LocalStorageManager.configuration else {
            return
        }
        
        navigationController.setCustomNavigationBarAppearance()
        
        showThreadList(configuration: storedConfiguration, deeplinkOption: deeplinkOption)
    }
}

// MARK: - Navigation

extension ChatCoordinator {

    func showThreadList(configuration: Configuration, deeplinkOption: DeeplinkOption? = nil) {
        navigationController.show(threadListViewController(configuration: configuration, deeplinkOption: deeplinkOption), sender: self)
    }
    
    func showProactiveActionPopup(data: [String: Any], actionId: UUID) {
        let controller = UIViewController()
        controller.view = ProActiveActionPopup(data: data, actionId: actionId)
        
        navigationController.show(controller, sender: self)
    }

    func showThread(_ thread: ChatThread, channelConfiguration: Configuration) {
        navigationController.show(threadViewController(thread, channelConfiguration: channelConfiguration), sender: self)
    }
}

// MARK: - Scenes

private extension ChatCoordinator {
    
    func threadListViewController(configuration: Configuration, deeplinkOption: DeeplinkOption? = nil) -> UIViewController {
        let input = ThreadListPresenter.Input(configuration: configuration, deeplinkOption: deeplinkOption)
        let navigation = ThreadListPresenter.Navigation(
            presentController: { [weak self] controller in self?.navigationController.present(controller, animated: true) },
            navigateToThread: { [weak self] thread in self?.showThread(thread, channelConfiguration: configuration) },
            navigateToLogin: { [weak self] in self?.navigationController.popViewController(animated: true) },
            navigateToConfiguration: { [weak self] in self?.popToConfiguration?() },
            showProactiveActionPopup: { [weak self] data, actionId in self?.showProactiveActionPopup(data: data, actionId: actionId) },
            showController: { [weak self] controller in
                controller.popoverPresentationController?.sourceView = self?.navigationController.view
                self?.navigationController.present(controller, animated: true)
            },
            popToThreadList: { [weak self] in
                self?.navigationController.dismiss(animated: true)
            }
        )
        let presenter = ThreadListPresenter(input: input, navigation: navigation, services: ())
        
        return ThreadListViewController(presenter: presenter)
    }
    
    func threadViewController(_ thread: ChatThread, channelConfiguration: Configuration) -> UIViewController {
        let input = ThreadDetailPresenter.Input(configuration: channelConfiguration, thread: thread)
        let navigation = ThreadDetailPresenter.Navigation(
            showToast: { title, message in
                UIApplication.shared.rootViewController?.view.makeToast(message, duration: 2, position: .top, title: title)
            },
            showController: { [weak self] controller in
                controller.popoverPresentationController?.sourceView = self?.navigationController.view
                
                self?.navigationController.present(controller, animated: true)
            },
            popToThreadList: { [weak self] in
                self?.navigationController.popViewController(animated: true)
            }
        )
        let presenter = ThreadDetailPresenter(input: input, navigation: navigation, services: ())
        
        return ThreadDetailViewController(presenter: presenter)
    }
}
