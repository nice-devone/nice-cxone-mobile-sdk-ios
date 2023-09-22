import AVFoundation
import CXoneChatSDK
import UIKit

class AudioPreviewController: UIViewController {
    
    // MARK: - Properties
    
    private let myView = AudioPreviewView()
    private let audioRecorder: AudioRecorder
    
    var willSendAttachment: ((ChatAttachmentManager.Attachment) -> Void)?
    
    // MARK: - Init
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(audioRecorder: AudioRecorder) {
        self.audioRecorder = audioRecorder
        super.init(nibName: nil, bundle: nil)
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myView.timeLabel.text = audioRecorder.formattedCurrentTime
        
        audioRecorder.timeDidChange = { [weak myView, weak audioRecorder] progress, formattedTime in
            myView?.timeLabel.text = formattedTime
            
            if let audioRecorder, !audioRecorder.isRecording {
                myView?.progressView.progress = progress
            }
        }
    }
    
    override func loadView() {
        super.loadView()
        
        self.view = myView
        
        audioRecorder.delegate = self
        
        myView.controlButton.addTarget(self, action: #selector(controlButtonDidTap), for: .touchUpInside)
        myView.deleteButton.addTarget(self, action: #selector(deleteButtonDidTap), for: .touchUpInside)
        myView.recordControlButton.addTarget(self, action: #selector(recordControlButtonDidTap), for: .touchUpInside)
        myView.sendButton.addTarget(self, action: #selector(sendButtonDidTap), for: .touchUpInside)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        guard let location = touches.first?.location(in: myView) else {
            return
        }
        
        if !myView.contentView.frame.contains(location) {
            audioRecorder.stopPlaying()
            try? audioRecorder.stop()
            try? audioRecorder.delete()
            
            dismiss(animated: true)
        }
    }
}

// MARK: - Actions

private extension AudioPreviewController {
    
    @objc
    func controlButtonDidTap() {
        if audioRecorder.isPlaying {
            audioRecorder.pause()
        } else {
            do {
                try audioRecorder.play()
            } catch {
                error.logError()
            }
        }
    }
    
    @objc
    func deleteButtonDidTap() {
        do {
            try audioRecorder.delete()
        } catch {
            error.logError()
        }
        
        dismiss(animated: true)
    }
    
    @objc
    func recordControlButtonDidTap() {
        do {
            if audioRecorder.isRecording {
                try audioRecorder.stop()
            } else {
                Task { @MainActor in
                    try await audioRecorder.record()
                }
            }
        } catch {
            error.logError()
        }
    }
    
    @objc
    func sendButtonDidTap() {
        guard let url = audioRecorder.url else {
            Log.error(.unableToParse("url", from: audioRecorder))
            return
        }
        
        dismiss(animated: true) {
            self.willSendAttachment?(.url(url))
        }
    }
}

// MARK: - AudioRecorderDelegate

extension AudioPreviewController: AudioRecorderDelegate {
    
    func audioRecorder(_ recorder: AudioRecorder, didFinishPlaying successfully: Bool) {
        myView.progressView.progress = 1
        myView.controlButton.setImage(Asset.Message.play, for: .normal)
    }
}
