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
import Foundation
import SwiftUI
import UIKit

class ThreadListPresenter: BasePresenter<ThreadListPresenter.Input, ThreadListPresenter.Navigation, Void, ThreadListViewState> {

    // MARK: - Structs
    
    struct Input {
        let configuration: Configuration
        let deeplinkOption: DeeplinkOption?
    }

    struct Navigation {
        var presentController: (UIViewController) -> Void
        var navigateToThread: (ChatThread) -> Void
        var navigateToLogin: () -> Void
        var navigateToConfiguration: () -> Void
        var showProactiveActionPopup: (_ data: [String: Any], _ actionId: UUID) -> Void
        let showController: (UIViewController) -> Void
        let popToThreadList: () -> Void
    }
    
    struct DocumentState {
        var isConnected = false
        var threads = [ChatThread]()
        var isCurrentThreadsSegmentSelected = true
        
        var isMultiThread: Bool { CXoneChat.shared.connection.channelConfiguration.hasMultipleThreadsPerEndUser }
    }
    
    // MARK: - Properties
    
    lazy var documentState = DocumentState()
    
    // MARK: - Lifecycle
    
    override func viewDidSubscribe() {
        super.viewDidSubscribe()
        
        RemoteNotificationsManager.shared.isChatSDKActive = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(onViewDidAppear), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    deinit {
        RemoteNotificationsManager.shared.isChatSDKActive = false
        
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Actions

extension ThreadListPresenter {
    
    @objc
    func didEnterBackground() {
        documentState.isConnected = false
        
        CXoneChat.shared.connection.disconnect()
    }
    
    @objc
    func onViewDidAppear() {
        CXoneChat.shared.delegate = self
        
        if documentState.isConnected {
            documentState.threads = getThreads()
            
            viewState.toLoaded(documentState: documentState)
        } else {
            Task { @MainActor in
                await connect()
            }
        }
    }
    
    func onViewWillDisappear() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    @objc
    func onAddThreadTapped() {
        guard documentState.isMultiThread || documentState.threads.isEmpty else {
            Log.error(CommonError.failed("Cannot create new thread - Current brand is not multi thread."))
            viewState.toError(
                title: L10n.ThreadList.NewThread.UnableToCreate.title,
                message: L10n.ThreadList.NewThread.UnableToCreate.message
            )
            return
        }
        
        promptUserCredentials()
    }

    @objc
    func onSendEvents() {
        let vc = UIHostingController(
            rootView: EventSenderListView(analyticsProvider: CXoneChat.shared.analytics) { [weak self] in
                self?.navigation.popToThreadList()
            }
        )

        navigation.showController(vc)
    }
    
    @objc
    func onDisconnectTapped() {
        let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        controller.addAction(UIAlertAction(title: L10n.Common.disconnect, style: .default) { [weak self] _ in
            CXoneChat.shared.connection.disconnect()
            
            self?.navigation.navigateToLogin()
        })
        controller.addAction(UIAlertAction(title: L10n.Common.signOut, style: .destructive) { [weak self] _ in
            RemoteNotificationsManager.shared.unregister()
            
            LocalStorageManager.reset()
            FileManager.default.eraseDocumentsFolder()
            CXoneChat.signOut()
            
            self?.navigation.navigateToConfiguration()
        })
        controller.addAction(UIAlertAction(title: L10n.Common.cancel, style: .cancel, handler: nil))
        
        navigation.presentController(controller)
    }
    
    @objc
    func onSegmentControlChanged(isCurrentThreadsSegmentSelected: Bool) {
        documentState.isCurrentThreadsSegmentSelected = isCurrentThreadsSegmentSelected
        
        documentState.threads = getThreads()
        
        viewState.toLoaded(documentState: documentState)
    }
    
    func onThreadSwipeToDelete(_ thread: ChatThread) {
        viewState.toLoading()
        
        do {
            try CXoneChat.shared.threads.archive(thread)
        } catch {
            error.logError()
            viewState.toError(title: L10n.Common.oops, message: L10n.Common.genericError)
        }
    }
    
    @MainActor
    func onThreadTapped(thread: ChatThread) async {
        navigation.navigateToThread(thread)
    }
}

// MARK: - CXoneChatDelegate

extension ThreadListPresenter: CXoneChatDelegate {
    
    func onConnect() {
        documentState.isConnected = true
        
        do {
            try loadThreads()
        } catch {
            error.logError()
            
            viewState.toError(title: L10n.Common.oops, message: L10n.Common.genericError)
        }
    }
    
    func onUnexpectedDisconnect() {
        documentState.isConnected = false
        
        Task { @MainActor in
            viewState.toLoading(title: L10n.Common.reconnecting)
            
            await connect()
        }
    }
    
    func onTokenRefreshFailed() {
        CXoneChat.shared.customer.set(nil)
        
        navigation.navigateToLogin()
    }
    
    func onThreadLoad(_ thread: ChatThread) {
        documentState.threads = getThreads()
        
        if case .thread(let threadId) = input.deeplinkOption {
            Task { @MainActor in
                if thread.id == threadId {
                    navigation.navigateToThread(thread)
                } else {
                    showUnknownThreadFromDeeplinkAlert()
                }
            }
        }
        
        viewState.toLoaded(documentState: documentState)
    }
    
    func onThreadsLoad(_ threads: [ChatThread]) {
        documentState.threads = threads.filter { documentState.isCurrentThreadsSegmentSelected ? $0.canAddMoreMessages : !$0.canAddMoreMessages }
        
        if !documentState.threads.isEmpty {
            documentState.threads.forEach { thread in
                do {
                    try CXoneChat.shared.threads.loadInfo(for: thread)
                } catch {
                    error.logError()
                }
            }
        } else {
            if case .thread = input.deeplinkOption {
                Task { @MainActor in
                    showUnknownThreadFromDeeplinkAlert()
                }
            }
            
            viewState.toLoaded(documentState: documentState)
        }
    }
    
    func onThreadInfoLoad(_ thread: ChatThread) {
        documentState.threads = getThreads()
        
        if case .thread(let threadId) = input.deeplinkOption {
            Task { @MainActor in
                if thread.id == threadId {
                    navigation.navigateToThread(thread)
                } else {
                    showUnknownThreadFromDeeplinkAlert()
                }
            }
        }
        
        if documentState.threads.filter(\.messages.isEmpty).isEmpty {
            viewState.toLoaded(documentState: documentState)
        }
    }
    
    func onThreadArchive() {
        documentState.threads = getThreads()
        
        viewState.toLoaded(documentState: documentState)
    }
    
    func onNewMessage(_ message: Message) {
        documentState.threads = CXoneChat.shared.threads.get().filter(\.canAddMoreMessages)
        
        guard let thread = documentState.threads.thread(by: message.threadId) else {
            Log.error(CommonError.unableToParse("thread", from: documentState.threads))
            viewState.toError(title: L10n.Common.oops, message: L10n.Common.genericError)
            return
        }
        
        if thread.messages.isEmpty {
            do {
                try CXoneChat.shared.threads.loadInfo(for: thread)
            } catch {
                error.logError()
                viewState.toError(title: L10n.Common.oops, message: L10n.Common.genericError)
            }
        } else {
            viewState.toLoaded(documentState: documentState)
        }
    }
    
    func onCustomPluginMessage(_ messageData: [Any]) {
        Log.info("Plugin message received")
        
        viewState.toLoaded(documentState: documentState)
    }
    
    func onAgentChange(_ agent: Agent, for threadId: UUID) {
        documentState.threads = getThreads()
        
        viewState.toLoaded(documentState: documentState)
    }
    
    func onThreadUpdate() {
        documentState.threads = getThreads()
        
        viewState.toLoaded(documentState: documentState)
    }
    
    func onProactivePopupAction(data: [String: Any], actionId: UUID) {
        navigation.showProactiveActionPopup(data, actionId)
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

private extension ThreadListPresenter {
    
    @MainActor
    func connect() async {
        viewState.toLoading()
        
        do {
            if let env = input.configuration.environment {
                try await CXoneChat.shared.connection.connect(environment: env, brandId: input.configuration.brandId, channelId: input.configuration.channelId)
            } else {
                try await CXoneChat.shared.connection.connect(
                    chatURL: input.configuration.chatUrl,
                    socketURL: input.configuration.socketUrl,
                    brandId: input.configuration.brandId,
                    channelId: input.configuration.channelId
                )
            }
        } catch {
            error.logError()
            viewState.toError(title: L10n.Common.oops, message: L10n.Common.genericError)
            
            navigation.navigateToLogin()
        }
        
    }
    
    func loadThreads() throws {
        if documentState.isMultiThread {
            try CXoneChat.shared.threads.load()
        } else {
            try CXoneChat.shared.threads.load(with: nil)
        }
    }
    
    func getThreads() -> [ChatThread] {
        CXoneChat.shared.threads
            .get()
            .filter { documentState.isCurrentThreadsSegmentSelected ? $0.canAddMoreMessages : !$0.canAddMoreMessages }
    }
    
    func promptUserCredentials() {
        let entities: [FormCustomFieldType] = [
            .textField(
                FormTextFieldEntity(label: L10n.ThreadList.NewThread.UserDetails.firstName, ident: "firstName", isRequired: false, isEmail: false)
            ),
            .textField(
                FormTextFieldEntity(label: L10n.ThreadList.NewThread.UserDetails.lastName, ident: "lastName", isRequired: false, isEmail: false)
            )
        ]
        let controller = FormViewController(
            entity: FormVO(title: L10n.ThreadList.NewThread.UserDetails.title, entities: entities)
        ) { [weak self] customFields in
            CXoneChat.shared.customer.setName(
                firstName: customFields.first { $0.key == "firstName" }.map(\.value) ?? "",
                lastName: customFields.first { $0.key == "lastName" }.map(\.value) ?? ""
            )
            
            if let preChatSurvey = CXoneChat.shared.threads.preChatSurvey {
                self?.promptContactCustomFields(with: preChatSurvey)
            } else {
                self?.createNewThread()
            }
        }

        navigation.presentController(controller)
    }
    
    func promptContactCustomFields(with preChatSurvey: PreChatSurvey) {
        let controller = FormViewController(
            entity: FormVO(title: preChatSurvey.name, entities: preChatSurvey.customFields.map { FormCustomFieldType(from: $0) })
        ) { [weak self] customFields in
            self?.createNewThread(with: customFields)
        }
        
        navigation.presentController(controller)
    }
    
    func createNewThread(with customFields: [String: String]? = nil) {
        do {
            let threadId: UUID
            
            if let customFields {
                threadId = try CXoneChat.shared.threads.create(with: customFields)
            } else {
                threadId = try CXoneChat.shared.threads.create()
            }
            
            guard let thread = CXoneChat.shared.threads.get().thread(by: threadId) else {
                Log.error(CommonError.unableToParse("thread", from: documentState.threads))
                viewState.toError(title: L10n.Common.oops, message: "Something went wrong. Please, try it again later.")
                return
            }
            
            documentState.threads = getThreads()
            
            navigation.navigateToThread(thread)
        } catch {
            error.logError()
            viewState.toError(title: L10n.Common.oops, message: L10n.Common.genericError)
        }
    }
    
    func showUnknownThreadFromDeeplinkAlert() {
        let controller = UIAlertController(title: L10n.Common.oops, message: L10n.Common.notificationUnknownError, preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: L10n.Common.close, style: .cancel))
        
        navigation.showController(controller)
    }
}
