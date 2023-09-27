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

class AudioPreviewView: BaseView {
    
    // MARK: - Views
    
    let contentView = UIView()
    
    private let handleView = UIView()
    private let titleLabel = UILabel()
    
    private let audioContentView = UIView()
    let controlButton = UIButton()
    let recordingIndicatorView = UIView()
    let progressView = UIProgressView(progressViewStyle: .default)
    let timeLabel = UILabel()
    
    let deleteButton = UIButton()
    let recordControlButton = UIButton()
    let sendButton = UIButton()
    
    // MARK: - Properties
    
    private var isRecording = false
    
    private var isPlaying = false
    
    private let symbolConfig = UIImage.SymbolConfiguration(scale: .large)
    
    // MARK: - Init
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(frame: .zero)
        
        addSubviews()
        setupSubviews()
        setupConstraints()
        setupColors()
    }
    
    // MARK: - Lifecycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        audioContentView.layer.cornerRadius = 12
        contentView.roundCorners([.topLeft, .topRight], radius: 10)
    }
    
    override func setupColors() {
        contentView.backgroundColor = .systemBackground
        handleView.backgroundColor = .lightGray
        titleLabel.textColor = .lightGray
        audioContentView.backgroundColor = .lightGray.withAlphaComponent(0.2)
        controlButton.tintColor = .themedColor(light: .black, dark: .white)
        progressView.tintColor = .themedColor(light: .black, dark: .white)
        deleteButton.tintColor = .red
        recordControlButton.tintColor = .systemBlue
        sendButton.tintColor = .systemBlue
    }
}

// MARK: - Actions

private extension AudioPreviewView {
    
    @objc
    func controlButtonDidTap() {
        isPlaying.toggle()
        
        controlButton.setImage(
            isPlaying ? Asset.Message.pause.withConfiguration(symbolConfig) : Asset.Message.play.withConfiguration(symbolConfig),
            for: .normal
        )
    }
    
    @objc
    func recordControlButtonDidTap() {
        isRecording.toggle()
        
        titleLabel.text = isRecording ? L10n.AudioPreview.recording : L10n.AudioPreview.reviewRecordedMessage
        progressView.tintColor = isRecording ? .black.withAlphaComponent(0.25) : .black
        
        controlButton.isEnabled = !isRecording
        deleteButton.isEnabled = !isRecording
        sendButton.isEnabled = !isRecording
        
        recordControlButton.setImage(
            isRecording ? Asset.Message.record.withConfiguration(symbolConfig) : Asset.Message.restartRecording.withConfiguration(symbolConfig),
            for: .normal
        )
    }
}

// MARK: - Private methods

private extension AudioPreviewView {

    func addSubviews() {
        addSubview(contentView)
        contentView.addSubviews(handleView, titleLabel, audioContentView, deleteButton, recordControlButton, sendButton)
        audioContentView.addSubviews(controlButton, progressView, timeLabel)
    }
    
    func setupSubviews() {
        handleView.layer.cornerRadius = 2
        
        titleLabel.text = L10n.AudioPreview.reviewRecordedMessage
        titleLabel.textAlignment = .center
        titleLabel.font = .preferredFont(forTextStyle: .footnote, compatibleWith: UITraitCollection(legibilityWeight: .bold))
        
        controlButton.setImage(Asset.Message.play.applyingSymbolConfiguration(symbolConfig), for: .normal)
        controlButton.addTarget(self, action: #selector(controlButtonDidTap), for: .touchUpInside)
        
        progressView.progress = 1
        
        timeLabel.font = .preferredFont(forTextStyle: .body, compatibleWith: UITraitCollection(legibilityWeight: .bold))
        
        deleteButton.setImage(Asset.Message.trash.applyingSymbolConfiguration(symbolConfig), for: .normal)
        deleteButton.imageView?.contentMode = .scaleAspectFit
        deleteButton.contentEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        
        recordControlButton.setImage(Asset.Message.restartRecording.applyingSymbolConfiguration(symbolConfig), for: .normal)
        recordControlButton.imageView?.contentMode = .scaleAspectFit
        recordControlButton.contentEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        recordControlButton.addTarget(self, action: #selector(recordControlButtonDidTap), for: .touchUpInside)
        
        sendButton.setImage(Asset.Message.send.applyingSymbolConfiguration(symbolConfig), for: .normal)
        sendButton.imageView?.contentMode = .scaleAspectFit
        
        sendButton.contentEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
    }
    
    func setupConstraints() {
        contentView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
        }
        handleView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(4)
            make.centerX.equalToSuperview()
            make.height.equalTo(4)
            make.width.equalTo(32)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(handleView.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        audioContentView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(24)
            make.leading.trailing.equalTo(titleLabel)
        }
        controlButton.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview().inset(12)
        }
        progressView.snp.makeConstraints { make in
            make.centerY.equalTo(controlButton)
            make.leading.lessThanOrEqualTo(controlButton.snp.trailing).offset(10)
        }
        timeLabel.snp.makeConstraints { make in
            make.centerY.equalTo(progressView)
            make.leading.equalTo(progressView.snp.trailing).offset(10)
            make.trailing.equalToSuperview().inset(12)
        }
        deleteButton.snp.makeConstraints { make in
            make.top.equalTo(audioContentView.snp.bottom).offset(40)
            make.leading.equalToSuperview().inset(24)
            make.bottom.equalTo(safeAreaLayoutGuide).inset(10)
        }
        recordControlButton.snp.makeConstraints { make in
            make.centerY.equalTo(deleteButton)
            make.leading.equalTo(deleteButton.snp.trailing).offset(4)
        }
        sendButton.snp.makeConstraints { make in
            make.centerY.equalTo(deleteButton)
            make.trailing.equalTo(titleLabel)
        }
    }
}
