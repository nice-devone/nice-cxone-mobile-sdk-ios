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

import Foundation
import InputBarAccessoryView
import MobileCoreServices
import UIKit

// MARK: - Protocol

protocol MessagesInputBarAccessoryDelegate: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: MessagesInputBarAccessoryView, didPressSendButtonWith attachments: [ChatAttachmentManager.Attachment])
    func inputBar(_ inputBar: MessagesInputBarAccessoryView, didRecordAudioMessage audioMessage: ChatAttachmentManager.Attachment)
}

// MARK: - Implementation

class MessagesInputBarAccessoryView: InputBarAccessoryView {
    
    // MARK: - Properties
    
    lazy var audioRecorder = AudioRecorder()
    
    lazy var attachmentManager: ChatAttachmentManager = { [unowned self] in
        let manager = ChatAttachmentManager()
        manager.delegate = self
        return manager
    }()
    
    private let recordAudioButton = InputBarButtonItem()
    
    // MARK: - Init
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupSubviews()
    }
    
    deinit {
        try? audioRecorder.stop()
    }
    
    // MARK: - Methods
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        backgroundView.backgroundColor = ChatAppearance.navigationBarColor
    }
    
    override func didSelectSendButton() {
        if !attachmentManager.attachments.isEmpty, let delegate = delegate as? MessagesInputBarAccessoryDelegate {
            delegate.inputBar(self, didPressSendButtonWith: attachmentManager.attachments)
        } else {
            delegate?.inputBar(self, didPressSendButtonWith: inputTextView.text)
        }
        
        attachmentManager.invalidate()
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate

extension MessagesInputBarAccessoryView: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc
    func showAttachmentsPicker() {
        inputTextView.resignFirstResponder()
        
        let fileAction = UIAlertAction(title: L10n.FileLoader.fileManager, style: .default) { [weak self] _ in
            let documentPicker: UIDocumentPickerViewController
            
            if #available(iOS 14.0, *) {
                documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.image, .video, .audio, .pdf])
            } else {
                documentPicker = UIDocumentPickerViewController(documentTypes: [kUTTypeImage, kUTTypeVideo, kUTTypeAudio, kUTTypePDF] as [String], in: .open)
            }
            
            documentPicker.delegate = self
            documentPicker.allowsMultipleSelection = true
            documentPicker.modalPresentationStyle = .overFullScreen
            
            UIApplication.shared.rootViewController?.present(documentPicker, animated: true)
        }
        let photoLibraryAction = UIAlertAction(title: L10n.FileLoader.imageFromLibrary, style: .default) { [weak self] _ in
            self?.showImagePickerController(sourceType: .photoLibrary)
        }
        let cameraAction = UIAlertAction(title: L10n.FileLoader.camera, style: .default) { [weak self] _ in
            self?.showImagePickerController(sourceType: .camera)
        }
        let cancelAction = UIAlertAction(title: L10n.Common.cancel, style: .cancel)
        
        UIAlertController.show(
            .actionSheet,
            title: L10n.FileLoader.title,
            message: nil,
            actions: [fileAction, photoLibraryAction, cameraAction, cancelAction]
        )
    }
    
    func showImagePickerController(sourceType: UIImagePickerController.SourceType) {
        let controller = UIImagePickerController()
        controller.delegate = self
        controller.allowsEditing = true
        controller.sourceType = sourceType
        inputAccessoryView?.isHidden = true
        
        UIApplication.shared.rootViewController?.present(controller, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            attachmentManager.insertAttachment(.image(editedImage), at: attachmentManager.attachments.count)
        } else if let originImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            attachmentManager.insertAttachment(.image(originImage), at: attachmentManager.attachments.count)
        }
        
        picker.dismiss(animated: true)
        inputAccessoryView?.isHidden = false
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
        
        inputAccessoryView?.isHidden = false
    }
}

// MARK: - UIDocumentPickerDelegate

extension MessagesInputBarAccessoryView: UIDocumentPickerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        urls.forEach { url in
            attachmentManager.insertAttachment(.url(url), at: attachmentManager.attachments.count)
        }
    }
}

// MARK: - ChatAttachmentManagerDelegate

extension MessagesInputBarAccessoryView: ChatAttachmentDelegate {
    
    func attachmentManager(_ manager: ChatAttachmentManager, shouldBecomeVisible: Bool) {
        let topStackView = self.topStackView
        
        if shouldBecomeVisible && !topStackView.arrangedSubviews.contains(attachmentManager.attachmentView) {
            topStackView.insertArrangedSubview(attachmentManager.attachmentView, at: topStackView.arrangedSubviews.count)
        } else if !shouldBecomeVisible && topStackView.arrangedSubviews.contains(attachmentManager.attachmentView) {
            topStackView.removeArrangedSubview(attachmentManager.attachmentView)
        }
        
        topStackView.layoutIfNeeded()
    }
    
    func attachmentManager(_ manager: ChatAttachmentManager, didReloadTo attachments: [ChatAttachmentManager.Attachment]) {
        sendButton.isEnabled = !manager.attachments.isEmpty
    }
    
    func attachmentManager(_ manager: ChatAttachmentManager, didInsert attachment: ChatAttachmentManager.Attachment, at index: Int) {
        sendButton.isEnabled = !manager.attachments.isEmpty
    }
    
    func attachmentManager(_ manager: ChatAttachmentManager, didRemove attachment: ChatAttachmentManager.Attachment, at index: Int) {
        sendButton.isEnabled = !manager.attachments.isEmpty
    }
    
    func attachmentManager(_ manager: ChatAttachmentManager, didSelectAddAttachmentAt index: Int) {
        showAttachmentsPicker()
    }
}

// MARK: - Private methods

private extension MessagesInputBarAccessoryView {
    
    func setupSubviews() {
        backgroundView.backgroundColor = ChatAppearance.navigationBarColor
        
        isTranslucent = true
        separatorLine.isHidden = true
        inputPlugins = [attachmentManager]
        
        setupLeftInputButtons()
        setupSendInputButton()
        setupInputTextView()
        setupCharCountInputButton()
    }
    
    func setupLeftInputButtons() {
        setLeftStackViewWidthConstant(to: 64, animated: false)
        
        let attachmentsButton = InputBarButtonItem()
            .configure {
                $0.image = Asset.Message.attachments
                $0.setSize(CGSize(width: 32, height: 38), animated: false)
            }
            .onSelected {
                $0.tintColor = .darkGray
            }
            .onDeselected {
                $0.tintColor = ChatAppearance.navigationElementsColor
            }
            .onTouchUpInside { [weak self] _ in
                self?.showAttachmentsPicker()
            }
        
        recordAudioButton
            .configure {
                $0.image = Asset.Message.record
                $0.setSize(CGSize(width: 32, height: 38), animated: false)
            }
            .onSelected {
                $0.tintColor = .darkGray
            }
            .onDeselected {
                $0.tintColor = ChatAppearance.navigationElementsColor
            }
            .onTouchUpInside { [weak self] item in
                guard let self else {
                    return
                }
                
                Task { @MainActor in
                    do {
                        if self.audioRecorder.isRecording {
                            self.inputTextView.placeholder = "Aa"
                            try self.audioRecorder.stop()
                            
                            if let url = self.audioRecorder.url, let delegate = self.delegate as? MessagesInputBarAccessoryDelegate {
                                delegate.inputBar(self, didRecordAudioMessage: .url(url))
                            }
                        } else {
                            try await self.audioRecorder.record()
                            
                            self.inputTextView.placeholder = L10n.AudioPreview.recording
                        }
                        
                        item.image = self.audioRecorder.isRecording ? Asset.Message.stopRecord : Asset.Message.record
                    } catch {
                        error.logError()
                    }
                }
            }
        
        setStackViewItems([attachmentsButton, recordAudioButton], forStack: .left, animated: false)
    }
    
    func setupInputTextView() {
        inputTextView.textContainerInset.left = 12
        inputTextView.textContainerInset.right = 38
        inputTextView.placeholderLabelInsets.left = 16
        inputTextView.textColor = ChatAppearance.navigationElementsColor
        inputTextView.placeholderTextColor = ChatAppearance.navigationElementsColor.withAlphaComponent(0.5)
        inputTextView.layer.borderColor = ChatAppearance.navigationElementsColor.cgColor
        inputTextView.layer.borderWidth = 1
        inputTextView.layer.cornerRadius = 19
        inputTextView.scrollIndicatorInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
    }
    
    func setupSendInputButton() {
        middleContentViewPadding.right = -38
        setRightStackViewWidthConstant(to: 38, animated: false)
        
        sendButton
            .configure {
                $0.setTitle(nil, for: .normal)
                $0.image = Asset.Message.send
                $0.imageView?.snp.makeConstraints { make in
                    make.size.equalTo(38)
                }
            }
            .onEnabled { item in
                item.imageView?.tintColor = ChatAppearance.navigationElementsColor
            }
            .onDisabled { item in
                item.imageView?.tintColor = ChatAppearance.navigationElementsColor.withAlphaComponent(0.5)
            }
        
        setStackViewItems([sendButton], forStack: .right, animated: false)
    }
    
    func setupCharCountInputButton() {
        let charCountButton = InputBarButtonItem()
            .configure {
                $0.title = "0/140"
                $0.contentHorizontalAlignment = .right
                $0.setTitleColor(ChatAppearance.navigationElementsColor, for: .normal)
                $0.titleLabel?.font = .preferredFont(forTextStyle: .caption2, compatibleWith: UITraitCollection(legibilityWeight: UILegibilityWeight.bold))
            }
            .onTextViewDidChange { item, textView in
                item.title = "\(textView.text.count)/140"
                let isOverLimit = textView.text.count > 140
                
                item.inputBarAccessoryView?.shouldManageSendButtonEnabledState = !isOverLimit
                item.inputBarAccessoryView?.sendButton.isEnabled = !isOverLimit
                item.setTitleColor(isOverLimit ? .red : ChatAppearance.navigationElementsColor, for: .normal)
            }
        charCountButton.isUserInteractionEnabled = false
        
        setStackViewItems([charCountButton], forStack: .bottom, animated: false)
    }
}
