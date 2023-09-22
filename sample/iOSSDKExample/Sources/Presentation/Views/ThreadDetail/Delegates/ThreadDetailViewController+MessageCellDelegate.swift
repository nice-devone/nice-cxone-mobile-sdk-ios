import ALProgressView
import AVKit
import MessageKit

extension ThreadDetailViewController: MessageCellDelegate {
    
    func didTapAvatar(in cell: MessageCollectionViewCell) {
        Log.info("Avatar tapped")
    }
    
    func didTapMessage(in cell: MessageCollectionViewCell) {
        Log.info("Message tapped")
        
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else {
            Log.error(CommonError.unableToParse("indexPath", from: messagesCollectionView))
            return
        }
        guard let message = presenter.thread.messages[safe: indexPath.section] else {
            Log.error(CommonError.unableToParse("message", from: messagesCollectionView))
            return
        }
        
        if let attachment = message.attachments.first, let url = URL(string: attachment.url) {
            present(WKWebViewController(url: url), animated: true)
        }
        
        switch message.contentType {
        case .plugin:
            UIAlertController.show(.alert, title: "Alert", message: "Plugin has been tapped")
        case .richLink(let entity):
            modalPresentationStyle = .fullScreen
            present(WKWebViewController(url: entity.url), animated: true)
        default:
            Log.warning(.failed("Did tap on unsupported message type."))
        }
    }
    
    func didTapImage(in cell: MessageCollectionViewCell) {
        Log.info("image tapped")
        
        guard let mediaCell = cell as? MediaMessageCell else {
            Log.error(CommonError.unableToParse("mediaCell", from: cell))
            return
        }
        
        if !mediaCell.playButtonView.isHidden {
            guard let index = messagesCollectionView.indexPath(for: cell) else {
                Log.error(CommonError.unableToParse("index", from: messagesCollectionView))
                return
            }
            guard let message = presenter.thread.messages[safe: index.section],
                  let urlString = message.attachments.first?.url,
                  let url = URL(string: urlString)
            else {
                Log.error(CommonError.unableToParse("url", from: presenter.thread.messages[index.section].attachments))
                return
            }
            
            DispatchQueue.main.async {
                self.myView.progressRing.isHidden = false
                try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            }
            
            let task = handleAttachmentTask(with: url)
            
            observation = task.progress.observe(\.fractionCompleted) { progress, _ in
                print("progress: ", progress.fractionCompleted)
                
                DispatchQueue.main.async {
                    self.myView.progressRing.setProgress(Float(progress.fractionCompleted), animated: true)
                }
            }
            
            task.resume()
        } else if let image = mediaCell.imageView.image {
            let newImageView = UIImageView(image: image)
            newImageView.frame = UIScreen.main.bounds
            newImageView.backgroundColor = .black
            newImageView.contentMode = .scaleAspectFit
            newImageView.isUserInteractionEnabled = true
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
            newImageView.addGestureRecognizer(tap)
            
            view.addSubview(newImageView)
            
            messageInputBar.isHidden = true
            navigationController?.isNavigationBarHidden = true
        }
    }
    
    func didTapCellTopLabel(in cell: MessageCollectionViewCell) {
        Log.info("Top cell label tapped")
    }
    
    func didTapCellBottomLabel(in cell: MessageCollectionViewCell) {
        Log.info("Bottom cell label tapped")
    }
    
    func didTapMessageTopLabel(in cell: MessageCollectionViewCell) {
        Log.info("Top message label tapped")
    }
    
    func didTapMessageBottomLabel(in cell: MessageCollectionViewCell) {
        Log.info("Bottom label tapped")
    }
    
    func didTapAccessoryView(in cell: MessageCollectionViewCell) {
        Log.info("Accessory view tapped")
    }
    
    func didTapPlayButton(in cell: AudioMessageCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell),
              let message = messagesCollectionView.messagesDataSource?.messageForItem(at: indexPath, in: messagesCollectionView)
        else {
            Log.error(.failed("Failed to identify message when audio cell receive tap gesture"))
            return
        }
        guard audioPlayer.state != .stopped else {
            audioPlayer.playSound(for: message, in: cell)
            return
        }
        if audioPlayer.playingMessage?.messageId == message.messageId {
            if audioPlayer.state == .playing {
                audioPlayer.pauseSound(for: message, in: cell)
            } else {
                audioPlayer.resumeSound()
            }
        } else {
            audioPlayer.stopAnyOngoingPlaying()
            audioPlayer.playSound(for: message, in: cell)
        }
    }
    
    func didTapBackground(in cell: MessageCollectionViewCell) {
        messageInputBar.inputTextView.resignFirstResponder()
    }
}

// MARK: - Actions

private extension ThreadDetailViewController {
    
    @objc
    func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        navigationController?.isNavigationBarHidden = false
        messageInputBar.isHidden = false
        
        sender.view?.removeFromSuperview()
    }
}

// MARK: - Private methods

private extension ThreadDetailViewController {

    func handleAttachmentTask(with url: URL) -> URLSessionDownloadTask {
        URLSession.shared.downloadTask(with: url) { [weak self] url, _, _ in
            let documentURL = try? FileManager.default
                .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            
            guard let url = url, let savedURL = documentURL?.appendingPathComponent("video.mp4") else {
                Log.error(CommonError.unableToParse("savedURL", from: documentURL))
                return
            }
            
            do {
                try FileManager.default.moveItem(at: url, to: savedURL)
                
                DispatchQueue.main.async {
                    let player = AVPlayerViewController()
                    let avPlayer = AVPlayer(url: savedURL)
                    avPlayer.volume = 1.0
                    avPlayer.isMuted = false
                    
                    player.player = avPlayer
                    player.player?.play()
                    self?.myView.progressRing.removeFromSuperview()
                    
                    self?.present(player, animated: true) {
                        try? FileManager.default.removeItem(at: savedURL)
                    }
                }
            } catch {
                error.logError()
            }
        }
    }
}
