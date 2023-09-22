import AVFoundation
import MessageKit
import UIKit

/// The `AudioPlayer` update UI for current audio cell that is playing a sound
/// and also creates and manage an `AVAudioPlayer` states, play, pause and stop.
class AudioPlayer: NSObject, AVAudioPlayerDelegate {

    // MARK: - Enums
    
    /// The `AudioState` indicates the current audio controller state
    enum AudioState {

        /// The audio controller is currently playing a sound
        case playing

        /// The audio controller is currently in pause state
        case pause

        /// The audio controller is not playing any sound and audioPlayer is nil
        case stopped
    }
    
    // MARK: - Properties
    
    /// The `AVPlayer` that is playing the sound
    var avPlayer: AVPlayer?
    
    /// The `Timer` that update playing progress
    var progressTimer: Timer?
    
    /// The `MessageType` that is currently playing sound
    var playingMessage: MessageType?
    
    /// The `notificationObserver` that is for the AVPlayer
    var observerDidPlayToEndTime: NSObjectProtocol?
    
    var observerFailedToPlayToEndTime: NSObjectProtocol?
    
    var observerNewErrorLogEntry: NSObjectProtocol?
    
    /// The `AudioMessageCell` that is currently playing sound
    weak var playingCell: AudioMessageCell?

    // The `MessagesCollectionView` where the playing cell exist
    weak var messageCollectionView: MessagesCollectionView?

    /// Specify if current audio controller state: playing, in pause or none
    private(set) var state: AudioState = .stopped

    // MARK: - Init

    init(messageCollectionView: MessagesCollectionView) {
        self.messageCollectionView = messageCollectionView
        super.init()
    }

    // MARK: - Methods

    /// Used to configure the audio cell UI:
    ///     1. play button selected state;
    ///     2. progressView progress;
    ///     3. durationLabel text;
    ///
    /// - Parameters:
    ///   - cell: The `AudioMessageCell` that needs to be configure.
    ///   - message: The `MessageType` that configures the cell.
    ///
    /// - Note:
    ///   This protocol method is called by MessageKit every time an audio cell needs to be configure
    func configureAudioCell(_ cell: AudioMessageCell, message: MessageType) {
        guard let collectionView = messageCollectionView, let displayDelegate = collectionView.messagesDisplayDelegate else {
            fatalError("MessagesDisplayDelegate has not been set.")
        }
        
        if playingMessage?.messageId == message.messageId {
            guard let player = avPlayer, let assetDuration = player.currentItem?.asset.duration else {
                Log.error(.failed("Could not get properties to configure audio cell."))
                return
            }
            
            playingCell = cell
            
            let duration = Double(CMTimeGetSeconds((assetDuration)))
            let currentTime = Double(CMTimeGetSeconds(player.currentTime()))
            
            cell.progressView.progress = duration == 0 ? 0 : Float(currentTime/duration)
            cell.playButton.isSelected = player.rate != 0 && player.error == nil
            
            cell.durationLabel.text = displayDelegate.audioProgressTextFormat(Float(currentTime), for: cell, in: collectionView)
        }
    }

    /// Used to start play audio sound
    ///
    /// - Parameters:
    ///   - message: The `MessageType` that contain the audio item to be played.
    ///   - audioCell: The `AudioMessageCell` that needs to be updated while audio is playing.
    func playSound(for message: MessageType, in audioCell: AudioMessageCell) {
        guard case .audio(let item) = message.kind else {
            Log.error(.failed("AudioPlayer failed play sound because given message kind is not Audio"))
            return
        }
        guard let localUrl = (item as? MessageAudioItem)?.localUrl else {
            Log.error(.unableToParse("localUrl", from: item))
            return
        }
        
        self.playingCell = audioCell
        self.playingMessage = message
        
        if avPlayer != nil {
            stopAnyOngoingPlaying()
        }

        let playerItem = AVPlayerItem(url: localUrl)
        avPlayer = AVPlayer(playerItem: playerItem)
        avPlayer?.play()
        
        state = .playing
        startProgressTimer()
        audioCell.playButton.isSelected = true
        audioCell.delegate?.didStartAudio(in: audioCell)
        
        self.observerDidPlayToEndTime = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: playerItem,
            queue: nil
        ) { [weak self] _ in
            self?.stopAnyOngoingPlaying()
        }
        self.observerFailedToPlayToEndTime = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemFailedToPlayToEndTime,
            object: playerItem,
            queue: nil
        ) { [weak self] _ in
            self?.stopAnyOngoingPlaying()
        }
        self.observerNewErrorLogEntry = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemNewErrorLogEntry,
            object: playerItem,
            queue: nil
        ) { [weak self] _ in
            self?.stopAnyOngoingPlaying()
        }
    }

    /// Used to pause the audio sound
    ///
    /// - Parameters:
    ///   - message: The `MessageType` that contain the audio item to be pause.
    ///   - audioCell: The `AudioMessageCell` that needs to be updated by the pause action.
    func pauseSound(for message: MessageType, in audioCell: AudioMessageCell) {
        avPlayer?.pause()
        state = .pause
        audioCell.playButton.isSelected = false
        progressTimer?.invalidate()
        
        if let cell = playingCell {
            cell.delegate?.didPauseAudio(in: cell)
        }
    }

    /// Stops any ongoing audio playing if exists
    func stopAnyOngoingPlaying() {
        guard let player = avPlayer, let collectionView = messageCollectionView else {
            Log.error(.failed("Could not get properties to stop player."))
            return
        }
        
        player.seek(to: CMTime.zero)
        player.pause()

        state = .stopped
        
        if let cell = playingCell {
            guard let displayDelegate = collectionView.messagesDisplayDelegate, let assetDuration = player.currentItem?.asset.duration else {
                fatalError("MessagesDisplayDelegate has not been set.")
            }
            
            cell.progressView.progress = 0.0
            cell.playButton.isSelected = false
            
            let duration = Double(CMTimeGetSeconds((assetDuration)))
            cell.durationLabel.text = displayDelegate.audioProgressTextFormat(Float(duration), for: cell, in: collectionView)
            cell.delegate?.didStopAudio(in: cell)
        }
        
        progressTimer?.invalidate()
        progressTimer = nil
       
        if avPlayer != nil {
            avPlayer?.replaceCurrentItem(with: nil)
            avPlayer = nil
            
            if let observerDidPlayToEndTime {
                NotificationCenter.default.removeObserver(observerDidPlayToEndTime)
            }
            if let observerFailedToPlayToEndTime {
                NotificationCenter.default.removeObserver(observerFailedToPlayToEndTime)
            }
            if let observerNewErrorLogEntry {
                NotificationCenter.default.removeObserver(observerNewErrorLogEntry)
            }
        }
        
        playingMessage = nil
        playingCell = nil
    }

    /// Resume a currently pause audio sound
    func resumeSound() {
        guard let player = avPlayer, let cell = playingCell else {
            stopAnyOngoingPlaying()
            return
        }
        
        player.play()
        state = .playing
        startProgressTimer()
        cell.playButton.isSelected = true
        cell.delegate?.didStartAudio(in: cell)
    }
}

// MARK: - Actions

private extension AudioPlayer {
    
    @objc
    func didFireProgressTimer(_ timer: Timer) {
        guard let player = avPlayer, let collectionView = messageCollectionView, let cell = playingCell else {
            Log.error(.failed("Could not get properties to handle progress timer."))
            return
        }
        guard let playingCellIndexPath = collectionView.indexPath(for: cell) else {
            return
        }
        
        let currentMessage = collectionView.messagesDataSource?.messageForItem(at: playingCellIndexPath, in: collectionView)
        
        if currentMessage != nil && currentMessage?.messageId == playingMessage?.messageId {
            guard let displayDelegate = collectionView.messagesDisplayDelegate else {
                fatalError("MessagesDisplayDelegate has not been set.")
            }
            guard let assetDuration = player.currentItem?.asset.duration else {
                Log.error(.unableToParse("duration", from: player.currentItem))
                return
            }
            
            let duration = Double(CMTimeGetSeconds((assetDuration)))
            let currentTime = Double(CMTimeGetSeconds(player.currentTime()))

            cell.progressView.progress = duration == 0 || currentTime == 0 ? 0 : Float(currentTime / duration)
            cell.durationLabel.text = displayDelegate.audioProgressTextFormat(Float(currentTime), for: cell, in: collectionView)
        } else {
            stopAnyOngoingPlaying()
        }
    }
}

// MARK: - Private Methods

private extension AudioPlayer {
    
    func startProgressTimer() {
        progressTimer?.invalidate()
        progressTimer = nil
        progressTimer = .scheduledTimer(timeInterval: 1, target: self, selector: #selector(didFireProgressTimer), userInfo: nil, repeats: true)
    }
}
