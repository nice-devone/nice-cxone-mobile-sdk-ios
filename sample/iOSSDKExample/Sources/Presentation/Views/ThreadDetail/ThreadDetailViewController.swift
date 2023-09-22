import CXoneChatSDK
import InputBarAccessoryView
import MessageKit
import SafariServices
import Toast
import UIKit
import UniformTypeIdentifiers

class ThreadDetailViewController: MessagesViewController, ViewRenderable {
    
    // MARK: - Properties
    
    let presenter: ThreadDetailPresenter
    let myView = ThreadDetailView()
    
    var observation: NSKeyValueObservation?
    
    var timer: Timer?
    var textInputWaitTime: Int = 0
    
    lazy var audioPlayer = AudioPlayer(messageCollectionView: messagesCollectionView)
    
    // MARK: - Init
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(presenter: ThreadDetailPresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    // MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setCustomNavigationBarAppearance()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.setNormalNavigationBarAppearance()
    }
    
    override func viewDidLoad() {
        messagesCollectionView = myView.messagesCollectionView
        messageInputBar = myView.messageInputBar
        super.viewDidLoad()
        
        presenter.subscribe(from: self)
        
        setupSubviews()
    }
    
    override func loadView() {
        super.loadView()
        
        view = myView

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: Asset.Chat.editThreadName,
            style: .plain,
            target: self,
            action: #selector(onButtonTapped)
        )
        
        myView.refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
    }
    
    func render(state: ThreadDetailViewState) {
        if !state.isLoading {
            hideLoading()
        }
        
        switch state {
        case .loading(let title):
            showLoading(title: title)
        case .loaded(let entity):
            DispatchQueue.main.async {
                self.handleView(with: entity)
            }
        case .refreshSection(let index, let addingNewItem):
            if addingNewItem {
                messagesCollectionView.refreshSectionToAddNewItem(index)
            } else {
                messagesCollectionView.refreshSection(index)
            }
        case .error(let title, let message):
            showAlert(title: title, message: message)
        }
    }
    
    // MARK: - Methods
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        super.motionEnded(motion, with: event)
        
        guard motion == .motionShake else {
            return
        }
        
        let shareLogs = UIAlertAction(title: L10n.Debug.Logs.share, style: .default) { _ in
            do {
                self.present(try Log.getLogShareDialog(), animated: true)
            } catch {
                error.logError()
            }
        }
        let removeLogs = UIAlertAction(title: L10n.Debug.Logs.remove, style: .destructive) { _ in
            do {
                try Log.removeLogs()
            } catch {
                error.logError()
            }
        }
        let cancelAction = UIAlertAction(title: L10n.Common.cancel, style: .cancel)
        
        UIAlertController.show(
            .actionSheet,
            title: L10n.Debug.Logs.title,
            message: nil,
            actions: [shareLogs, removeLogs, cancelAction]
        )
    }
    
    // MARK: - UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let messagesDataSource = messagesCollectionView.messagesDataSource else {
            Log.error(CommonError.unableToParse("messagesDataSource", from: messagesCollectionView))
            return UICollectionViewCell()
        }
        guard !isSectionReservedForTypingIndicator(indexPath.section) else {
            return super.collectionView(collectionView, cellForItemAt: indexPath)
        }
        
        let item = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView)
        
        switch item.kind {
        case .custom(let type):
            switch type {
            case is MessageRichLink:
                return collectionView.dequeue(for: indexPath) as ThreadDetailRichLinkCell
            case is MessageQuickReplies:
                return collectionView.dequeue(for: indexPath) as ThreadDetailQuickRepliesCell
            case is MessageListPicker:
                return collectionView.dequeue(for: indexPath) as ThreadDetailListPickerCell
            default:
                return collectionView.dequeue(for: indexPath) as ThreadDetailPluginCell
            }
        case .linkPreview:
            return collectionView.dequeue(for: indexPath) as ThreadDetailLinkCell
        default:
            return super.collectionView(collectionView, cellForItemAt: indexPath)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if cell is TypingIndicatorCell {
            return
        }
        guard let messageData = presenter.thread.messages[safe: indexPath.section] else {
            Log.error(CommonError.unableToParse("messageData", from: presenter.thread))
            return
        }
        
        if let cell = cell as? MessageContentCell {
            cell.configure(with: messageData, at: indexPath, and: messagesCollectionView)
        }
        
        let isLastCell = indexPath.section == presenter.thread.messages.count - 1
        
        switch cell {
        case let cell as ThreadDetailPluginCell:
            cell.isOptionSelectionEnabled = isLastCell
            cell.pluginDelegate = self
        case let cell as ThreadDetailQuickRepliesCell:
            cell.isOptionSelectionEnabled = isLastCell
            cell.messageDelegate = self
        case let cell as ThreadDetailListPickerCell:
            cell.messageDelegate = self
        case let cell as TypingIndicatorCell:
            cell.typingBubble.startAnimating()
        default:
            break
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemsAt indexPaths: [IndexPath],
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        guard let indexPath = indexPaths.first, let cell = collectionView.cellForItem(at: indexPath) else {
            Log.warning(.failed("Could not get first IndexPath or selected cell."))
            return nil
        }
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak presenter] _ -> UIMenu? in
            var menuOptions = [UIAction]()
            
            switch cell {
            case let mediaCell as MediaMessageCell where cell is MediaMessageCell:
                let share = UIAction(title: L10n.ThreadDetail.CellContextMenu.shareContent, image: Asset.Common.share) { _ in
                    presenter?.onShareCellContent(mediaCell.imageView.image)
                }
                let copy = UIAction(title: L10n.ThreadDetail.CellContextMenu.copyContent, image: Asset.Common.copy) { _ in
                    presenter?.onCopyCellContent(mediaCell.imageView.image)
                }
                
                menuOptions = [share, copy]
            case let textCell as TextMessageCell where cell is TextMessageCell:
                let share = UIAction(title: L10n.ThreadDetail.CellContextMenu.shareContent, image: Asset.Common.share) { _ in
                    presenter?.onShareCellContent(textCell.messageLabel.text)
                }
                let copy = UIAction(title: L10n.ThreadDetail.CellContextMenu.copyContent, image: Asset.Common.copy) { _ in
                    presenter?.onCopyCellContent(textCell.messageLabel.text)
                }
                
                menuOptions = [share, copy]
            case let cell as ThreadDetailRichLinkCell:
                let share = UIAction(title: L10n.ThreadDetail.CellContextMenu.shareContent, image: Asset.Common.share) { _ in
                    presenter?.onShareCellContent(cell.linkUrl)
                }
                let copy = UIAction(title: L10n.ThreadDetail.CellContextMenu.copyContent, image: Asset.Common.copy) { _ in
                    presenter?.onCopyCellContent(cell.linkUrl)
                }
                
                menuOptions = [share, copy]
            default:
                Log.warning(.failed("Unsupported cell content."))
                return nil
            }
            
            return UIMenu(options: .displayInline, children: menuOptions)
        }
    }
}

// MARK: - Actions

private extension ThreadDetailViewController {
    
    @objc
    func didPullToRefresh() {
        if presenter.thread.hasMoreMessagesToLoad {
            do {
                try CXoneChat.shared.threads.messages.loadMore(for: presenter.thread)
            } catch {
                error.logError()
                myView.refreshControl.endRefreshing()
            }
        } else {
            myView.refreshControl.endRefreshing()
        }
    }
    
    @objc
    func onButtonTapped(_ sender: Any) {
        messageInputBar.inputTextView.resignFirstResponder()
        
        switch sender {
        case let button as UIBarButtonItem where button.image == Asset.Chat.editThreadName:
            presenter.onEditThreadName()
        case let button as UIBarButtonItem where button.image == Asset.Chat.editCustomFields:
            presenter.onEditCustomField()
        default:
            Log.warning("Unknown sender did tap.")
        }
    }
}

// MARK: - PluginMessageDelegate

extension ThreadDetailViewController: PluginMessageDelegate {

    func pluginMessageView(_ view: PluginMessageView, subElementDidTap subElement: PluginMessageSubElementType) {
        switch subElement {
        case .button(let entity):
            if let postback = entity.postback {
                try? CXoneChat.shared.analytics.customVisitorEvent(data: .custom(postback))
            }
            guard let url = entity.url else {
                return
            }
            
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.rootViewController?.present(SFSafariViewController(url: url), animated: true)
            }
        default:
            break
        }
    }
    
    func pluginMessageView(_ view: PluginMessageView, quickReplySelected text: String, withPostback postback: String?) {
        try? CXoneChat.shared.analytics.customVisitorEvent(data: .custom("Quick Reply tapped."))
        
        send(OutboundMessage(text: text, postback: postback), for: self.messageInputBar)
    }
}

// MARK: - ThreadDetailRichMessageDelegate

extension ThreadDetailViewController: ThreadDetailRichMessageDelegate {
    
    func richMessageCell(_ cell: MessageContentCell, didSelect option: String, withPostback postback: String) {
        send(OutboundMessage(text: option, postback: postback), for: self.messageInputBar)
    }
}

// MARK: - AttachmentsInputBarAccessoryViewDelegate

extension ThreadDetailViewController: MessagesInputBarAccessoryDelegate {
    
    func inputBar(_ inputBar: MessagesInputBarAccessoryView, didRecordAudioMessage audioMessage: ChatAttachmentManager.Attachment) {
        let controller = AudioPreviewController(audioRecorder: inputBar.audioRecorder)
        controller.modalPresentationStyle = .formSheet
        controller.willSendAttachment = { [weak self] attachment in
            self?.inputBar(inputBar, didPressSendButtonWith: [attachment])
        }
        
        presenter.navigation.showController(controller)
    }
    
    func inputBar(_ inputBar: MessagesInputBarAccessoryView, didPressSendButtonWith attachments: [ChatAttachmentManager.Attachment]) {
        let message = inputBar.inputTextView.attributedText.string
        let attachments = attachments.compactMap { attachment -> ContentDescriptor? in
            switch attachment {
            case .image(let image):
                guard let data = image.jpegData(compressionQuality: 0.7) else {
                    return nil
                }
                
                let fileName = "\(UUID().uuidString).jpg"
                return ContentDescriptor(
                    data: data,
                    mimeType: "image/jpg",
                    fileName: fileName,
                    friendlyName: fileName
                )
            case .data(let data):
                let fileName = "\(UUID().uuidString).\(data.fileExtension)"
                return ContentDescriptor(
                    data: data,
                    mimeType: data.mimeType,
                    fileName: fileName,
                    friendlyName: fileName
                )
            case .url(let url):
                return ContentDescriptor(
                    url: url,
                    mimeType: url.mimeType,
                    fileName: "\(UUID().uuidString).\(url.pathExtension)",
                    friendlyName: url.lastPathComponent
                )
            }
        }
        
        send(OutboundMessage(text: message, attachments: attachments), for: inputBar)
    }
    
    @objc
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        send(OutboundMessage(text: text), for: inputBar)
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {
        if timer != nil {
            if textInputWaitTime >= 5 {
                timer?.invalidate()
                textInputWaitTime = 0
                timer = nil
            }
        } else {
            do {
                try CXoneChat.shared.threads.reportTypingStart(true, in: presenter.thread)
            } catch {
                error.logError()
            }
            
            self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
                self?.textInputWaitTime += 1
                
                if let self = self, self.textInputWaitTime >= 5 {
                    self.textInputWaitTime = 0
                    timer.invalidate()
                    self.timer = nil
                    
                    do {
                        try CXoneChat.shared.threads.reportTypingStart(false, in: self.presenter.thread)
                    } catch {
                        error.logError()
                    }
                }
            }
        }
    }
}

// MARK: - Private methods

private extension ThreadDetailViewController {
    
    func send(_ message: OutboundMessage, for inputBar: InputBarAccessoryView) {
        inputBar.invalidatePlugins()
        inputBar.inputTextView.text = String()
        inputBar.inputTextView.resignFirstResponder()
        inputBar.sendButton.startAnimating()
        inputBar.inputTextView.placeholder = L10n.ThreadDetail.Messaging.sendingPlaceholder
        
        Task { @MainActor in
            do {
                try await presenter.onSendMessage(message)
                
                messagesCollectionView.refreshSectionToAddNewItem(presenter.thread.messages.count - 1)
            } catch {
                error.logError()
                showAlert(title: L10n.Common.oops, message: L10n.Common.genericError)
            }
            
            inputBar.sendButton.stopAnimating()
            inputBar.inputTextView.placeholder = "Aa"
        }
    }

    func handleView(with entity: ThreadDetailVO) {
        title = entity.title
        
        myView.refreshControl.endRefreshing()
        
        let isButtonPresented = navigationItem.rightBarButtonItems?.first { $0.image == Asset.Chat.editCustomFields } != nil
        if !entity.isEditButtonHidden && !isButtonPresented {
            navigationItem.rightBarButtonItems?.append(
                UIBarButtonItem(image: Asset.Chat.editCustomFields, style: .plain, target: self, action: #selector(onButtonTapped))
            )
        }
        if let brandLogo = entity.brandLogo, navigationItem.titleView == nil {
            let imageView = UIImageView(image: brandLogo)
            imageView.contentMode = . scaleAspectFit
            navigationItem.titleView = imageView
        }
        if isTypingIndicatorHidden != !entity.isAgentTyping {
            setTypingIndicatorViewHidden(!entity.isAgentTyping, animated: true)
            messagesCollectionView.scrollToLastItem()
        }
        if entity.shouldReloadData {
            messagesCollectionView.reloadData()
            messagesCollectionView.scrollToLastItem()
        }
    }
    
    func setupSubviews() {
        myView.backgroundColor = ChatAppearance.backgroundColor
        messagesCollectionView.backgroundColor = ChatAppearance.backgroundColor
        
        scrollsToLastItemOnKeyboardBeginsEditing = true
        showMessageTimestampOnSwipeLeft = true
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
        messageInputBar.delegate = self
    }
}
