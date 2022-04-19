//
//  Created by Customer Dynamics Development on 9/2/21.
//

import AVFoundation
import MessageKit

/// The `BasicAudioController` update UI for current audio cell that is playing a sound
/// and also creates and manage an `AVAudioPlayer` states, play, pause and stop.
open class BasicAudioController: NSObject, AVAudioPlayerDelegate {

	/// The `AVAudioPlayer` that is playing the sound
	open var audioPlayer: AVAudioPlayer?

	/// The `AudioMessageCell` that is currently playing sound
	open weak var playingCell: AudioMessageCell?

	/// The `MessageType` that is currently playing sound
	open var playingMessage: MessageType?

	/// Specify if current audio controller state: playing, in pause or none
	open private(set) var state: PlayerState = .stopped

	// The `MessagesCollectionView` where the playing cell exist
	public weak var messageCollectionView: MessagesCollectionView?

	/// The `Timer` that update playing progress
	internal var progressTimer: Timer?

	// MARK: - Init Methods
	public init(messageCollectionView: MessagesCollectionView) {
		self.messageCollectionView = messageCollectionView
		super.init()
	}

	// MARK: - Methods
	/// Used to configure the audio cell UI:
	/// -   play button selected state;
	/// -   progresssView progress;
	/// -  durationLabel text;
	///
	/// - Parameters:
	///   - cell: The `AudioMessageCell` that needs to be configure.
	///   - message: The `MessageType` that configures the cell.
	///
	/// - Note: This protocol method is called by MessageKit every time an audio cell needs to be configure
	open func configureAudioCell(_ cell: AudioMessageCell, message: MessageType) {
		if playingMessage?.messageId == message.messageId, let collectionView = messageCollectionView, let player = audioPlayer {
			playingCell = cell
			cell.progressView.progress = (player.duration == 0) ? 0 : Float(player.currentTime/player.duration)
			cell.playButton.isSelected = (player.isPlaying == true) ? true : false
			guard let displayDelegate = collectionView.messagesDisplayDelegate else {
				fatalError("MessagesDisplayDelegate has not been set.")
			}
			cell.durationLabel.text = displayDelegate.audioProgressTextFormat(Float(player.currentTime), for: cell, in: collectionView)
		}
	}

	/// Used to start play audio sound
	///
	/// - Parameters:
	///   - message: The `MessageType` that contain the audio item to be played.
	///   - audioCell: The `AudioMessageCell` that needs to be updated while audio is playing.
	open func playSound(for message: MessageType, in audioCell: AudioMessageCell) {
		switch message.kind {
		case .audio(let item):
			playingCell = audioCell
			playingMessage = message
			guard let player = try? AVAudioPlayer(contentsOf: item.url) else {
				return
			}
			audioPlayer = player
			audioPlayer?.prepareToPlay()
			audioPlayer?.delegate = self
			audioPlayer?.play()
			state = .playing
			audioCell.playButton.isSelected = true  
			startProgressTimer()
			audioCell.delegate?.didStartAudio(in: audioCell)
        default: break
			
		}
	}

	/// Used to pause the audio sound
	///
	/// - Parameters:
	///   - message: The `MessageType` that contain the audio item to be pause.
	///   - audioCell: The `AudioMessageCell` that needs to be updated by the pause action.
	open func pauseSound(for message: MessageType, in audioCell: AudioMessageCell) {
		audioPlayer?.pause()
		state = .pause
		audioCell.playButton.isSelected = false // show play button on audio cell
		progressTimer?.invalidate()
		if let cell = playingCell {
			cell.delegate?.didPauseAudio(in: cell)
		}
	}

	/// Stops any ongoing audio playing if exists
	open func stopAnyOngoingPlaying() {
		guard let player = audioPlayer, let collectionView = messageCollectionView else { return }
		player.stop()
		state = .stopped
		if let cell = playingCell {
			cell.progressView.progress = 0.0
			cell.playButton.isSelected = false
			guard let displayDelegate = collectionView.messagesDisplayDelegate else {
				fatalError("MessagesDisplayDelegate has not been set.")
			}
			cell.durationLabel.text = displayDelegate.audioProgressTextFormat(Float(player.duration), for: cell, in: collectionView)
			cell.delegate?.didStopAudio(in: cell)
		}
		progressTimer?.invalidate()
		progressTimer = nil
		audioPlayer = nil
		playingMessage = nil
		playingCell = nil
	}

	/// Resume a currently pause audio sound
	open func resumeSound() {
		guard let player = audioPlayer, let cell = playingCell else {
			stopAnyOngoingPlaying()
			return
		}
		player.prepareToPlay()
		player.play()
		state = .playing
		startProgressTimer()
		cell.playButton.isSelected = true
		cell.delegate?.didStartAudio(in: cell)
	}

	// MARK: - Fire Methods
	@objc private func didFireProgressTimer(_ timer: Timer) {
		guard let player = audioPlayer, let collectionView = messageCollectionView, let cell = playingCell else {
			return
		}
		if let playingCellIndexPath = collectionView.indexPath(for: cell) {
			let currentMessage = collectionView.messagesDataSource?.messageForItem(at: playingCellIndexPath, in: collectionView)
			if currentMessage != nil && currentMessage?.messageId == playingMessage?.messageId {
				cell.progressView.progress = (player.duration == 0) ? 0 : Float(player.currentTime/player.duration)
				guard let displayDelegate = collectionView.messagesDisplayDelegate else {
					fatalError("MessagesDisplayDelegate has not been set.")
				}
				cell.durationLabel.text = displayDelegate.audioProgressTextFormat(Float(player.currentTime), for: cell, in: collectionView)
			} else {
				stopAnyOngoingPlaying()
			}
		}
	}

	// MARK: - Private Methods
	private func startProgressTimer() {
		progressTimer?.invalidate()
		progressTimer = nil
		progressTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(BasicAudioController.didFireProgressTimer(_:)), userInfo: nil, repeats: true)
	}

	// MARK: - AVAudioPlayerDelegate
	open func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
		stopAnyOngoingPlaying()
	}

	open func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
		stopAnyOngoingPlaying()
	}

}

