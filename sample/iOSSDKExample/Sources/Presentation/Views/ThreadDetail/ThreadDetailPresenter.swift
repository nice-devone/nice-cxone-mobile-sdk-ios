import CXoneChatSDK
import UIKit

class ThreadDetailPresenter: BasePresenter<ThreadDetailPresenter.Input, ThreadDetailPresenter.Navigation, Void, ThreadDetailViewState> {
    
    // MARK: - Structs
    
    struct Input {
        let configuration: Configuration
        let thread: ChatThread
    }
    
    struct Navigation {
        let showToast: (_ title: String, _ message: String) -> Void
        let showController: (UIViewController) -> Void
        let popToThreadList: () -> Void
    }
    
    struct DocumentState {
        var thread: ChatThread
        var title: String
        var isConnected = true
        var isAgentTyping = false
        var isEditButtonHidden = true
        var shouldReloadData = true
        var brandLogo = try? UIImage.load("brandLogo.png", from: .documentDirectory)
    }
    
    // MARK: - Properties
    
    private lazy var documentState = DocumentState(thread: input.thread, title: input.thread.name ?? L10n.ThreadList.noAgent)

    var thread: ChatThread { documentState.thread }

    var brandLogo: UIImage? { documentState.brandLogo }
    
    // MARK: - Lifecycle
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidSubscribe() {
        super.viewDidSubscribe()
        
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reconnect), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        CXoneChat.shared.delegate = self
        
        loadThreadIfNeeded()
        
        Task {
            do {
                try await CXoneChat.shared.analytics.chatWindowOpen()
            } catch {
                error.logError()
            }
        }
    }
}

// MARK: - Actions

extension ThreadDetailPresenter {
    
    @objc
    func didEnterBackground() {
        documentState.isConnected = false
        
        CXoneChat.shared.connection.disconnect()
    }
    
    func onShareCellContent(_ content: Any?) {
        let controller = UIActivityViewController(activityItems: [content as Any], applicationActivities: nil)

        navigation.showController(controller)
    }
    
    func onCopyCellContent(_ content: Any?) {
        switch content {
        case let content as UIImage:
            UIPasteboard.general.image = content
        case let content as URL:
            UIPasteboard.general.url = content
        default:
            break
        }
        
        UIPasteboard.general.string = content as? String
    }
    
    @objc
    func onEditCustomField() {
        let contactCustomFields: [CustomFieldType] = CXoneChat.shared.threads.customFields.get(for: input.thread.id)
        
        guard !contactCustomFields.isEmpty else {
            Log.error(.unableToParse("contactCustomFields"))
            return
        }
        
        let controller = FormViewController(
            entity: FormVO(title: L10n.ThreadDetail.EditCustomFields.title, entities: contactCustomFields.map(FormCustomFieldType.init))
        ) { [weak self] customFields in
            guard let self = self else {
                return
            }

            do {
                try CXoneChat.shared.threads.customFields.set(customFields, for: self.documentState.thread.id)
            } catch {
                error.logError()
                self.viewState.toError(title: L10n.Common.oops, message: L10n.Common.genericError)
            }
        }

        navigation.showController(controller)
    }
    
    @objc
    func onEditThreadName() {
        let controller = UIAlertController(
            title: L10n.ThreadDetail.UpdateThreadName.title,
            message: L10n.ThreadDetail.UpdateThreadName.message,
            preferredStyle: .alert
        )
        controller.addTextField { textField in
            textField.placeholder = L10n.ThreadDetail.UpdateThreadName.placeholder
        }
        
        let saveAction = UIAlertAction(title: L10n.Common.confirm, style: .default) { [weak self] _ in
            guard let self = self, let title = (controller.textFields?[safe: 0] as? UITextField)?.text else {
                Log.error(CommonError.unableToParse("title", from: controller.textFields?[safe: 0]))
                return
            }
            
            do {
                try CXoneChat.shared.threads.updateName(title, for: self.documentState.thread.id)
            } catch {
                error.logError()
                self.viewState.toError(title: L10n.Common.oops, message: L10n.Common.genericError)
            }
        }
        
        let cancel = UIAlertAction(title: L10n.Common.cancel, style: .cancel)
        controller.addAction(saveAction)
        controller.addAction(cancel)
        
        navigation.showController(controller)
    }
    
    func onSendMessage(_ message: OutboundMessage) async throws {
        let newMessage = try await CXoneChat.shared.threads.messages.send(message, for: documentState.thread)
        
        documentState.thread.messages.append(newMessage)
    }
    
    func isPreviousMessageSameSender(at indexPath: IndexPath) -> Bool {
        guard indexPath.section - 1 >= 0 else {
            return false
        }
        
        guard let senderId = documentState.thread.messages[safe: indexPath.section]?.sender.senderId.lowercased(),
              let previousSenderId = documentState.thread.messages[safe: indexPath.section - 1]?.sender.senderId.lowercased()
        else {
            return false
        }
        
        return senderId == previousSenderId
    }
    
    func isNextMessageSameSender(at indexPath: IndexPath) -> Bool {
        guard indexPath.section + 1 < documentState.thread.messages.count else {
            return false
        }
        
        guard let senderId = documentState.thread.messages[safe: indexPath.section]?.sender.senderId.lowercased(),
              let nextSenderId = documentState.thread.messages[safe: indexPath.section + 1]?.sender.senderId.lowercased()
        else {
            return false
        }
        
        return senderId == nextSenderId
    }
}

// MARK: - CXoneChatDelegate

extension ThreadDetailPresenter: CXoneChatDelegate {
    
    func onConnect() {
        documentState.isConnected = true
        
        do {
            try CXoneChat.shared.threads.load(with: input.thread.id)
        } catch {
            error.logError()
            navigation.popToThreadList()
        }
    }
    
    func onUnexpectedDisconnect() {
        Log.trace("Reconnecting the CXone services.")
        
        reconnect()
    }
    
    func onThreadUpdate() {
        updateThread()
        
        documentState.title = documentState.thread.name?.mapNonEmpty { $0 }
            ?? documentState.thread.assignedAgent?.fullName.mapNonEmpty { $0 }
        ?? L10n.ThreadDetail.noAgent
        
        viewState.toLoaded(documentState: documentState)
    }
    
    func onThreadLoad(_ thread: ChatThread) {
        documentState.thread = thread
        documentState.shouldReloadData = true
        
        documentState.title = thread.name?.mapNonEmpty { $0 }
            ?? thread.assignedAgent?.fullName.mapNonEmpty { $0 }
        ?? L10n.ThreadDetail.noAgent
        
        let anyContactCustomFieldsExists = !(CXoneChat.shared.threads.customFields.get(for: documentState.thread.id) as [CustomFieldType]).isEmpty
        
        if anyContactCustomFieldsExists && documentState.isEditButtonHidden {
            documentState.isEditButtonHidden = false
        }
        
        viewState.toLoaded(documentState: documentState)
        
        documentState.shouldReloadData = false
    }
    
    func onAgentChange(_ agent: Agent, for threadId: UUID) {
        documentState.thread.assignedAgent = agent
        
        guard documentState.thread.name.isNilOrEmpty else {
            return
        }
        
        documentState.title = agent.fullName.mapNonEmpty { $0 } ?? L10n.ThreadDetail.AssignedAgent.noName
        
        viewState.toLoaded(documentState: documentState)
    }
    
    func onAgentTyping(_ isTyping: Bool, threadId: UUID) {
        guard threadId == documentState.thread.id else {
            Log.error("Did start typing in unknown thread.")
            return
        }
        
        documentState.isAgentTyping = isTyping
        
        viewState.toLoaded(documentState: documentState)
    }
    
    func onNewMessage(_ message: Message) {
        if message.threadId == documentState.thread.id {
            updateThread()
            
            viewState.toRefreshSection(
                index: documentState.thread.messages.count - 1,
                addingNewItem: message.direction == .toClient
            )
        } else {
            Task { @MainActor in
                self.navigation.showToast(
                    L10n.ThreadDetail.MessageFromDifferentThread.text(message.senderInfo.fullName),
                    message.contentType.message
                )
            }
        }
    }
    
    func onAgentReadMessage(threadId: UUID) {
        guard let messageIndex = documentState.thread.messages.firstIndex(where: { $0.userStatistics?.readAt == nil }) else {
            return
        }
        
        updateThread()
        
        viewState.toRefreshSection(index: messageIndex, addingNewItem: false)
    }
    
    func onLoadMoreMessages(_ messages: [Message]) {
        documentState.shouldReloadData = true
        
        updateThread()
        
        viewState.toLoaded(documentState: documentState)
        
        documentState.shouldReloadData = false
    }
    
    func onError(_ error: Error) {
        // "recoveringThreadFailed" is a soft error.
        if let error = error as? CXoneChatError, error == CXoneChatError.recoveringThreadFailed {
            Log.info(error.localizedDescription)
        } else {
            error.logError()
        }
        
        viewState.toLoaded(documentState: documentState)
    }
}

// MARK: - Private methods

private extension ThreadDetailPresenter {
    
    func loadThreadIfNeeded() {
        if input.thread.messages.count == 1 {
            viewState.toLoading()
        
            do {
                try CXoneChat.shared.threads.load(with: input.thread.id)
            } catch {
                error.logError()
                viewState.toError(title: L10n.Common.oops, message: L10n.Common.genericError)
                
                navigation.popToThreadList()
            }
        } else {
            viewState.toLoaded(documentState: documentState)
            
            documentState.shouldReloadData = false
        }
    }
    
    @objc
    func reconnect() {
        CXoneChat.shared.delegate = self
        
        Task { @MainActor in
            viewState.toLoading(title: L10n.Common.reconnecting)
            
            try await CXoneChat.shared.connection.connect(
                chatURL: input.configuration.chatUrl,
                socketURL: input.configuration.socketUrl,
                brandId: input.configuration.brandId,
                channelId: input.configuration.channelId
            )
        }
    }
    
    func updateThread() {
        guard let updatedThread = CXoneChat.shared.threads.get().thread(by: documentState.thread.id) else {
            Log.error(CommonError.unableToParse("updatedThread", from: CXoneChat.shared.threads))
            return
        }
        
        documentState.thread = updatedThread
	}
}
