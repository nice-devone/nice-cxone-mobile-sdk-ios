import AVFoundation
import UIKit

// MARK: - Delegate

protocol AudioRecorderDelegate: AnyObject {
    func audioRecorder(_ recorder: AudioRecorder, didFinishPlaying successfully: Bool)
}

// MARK: - Implementation

class AudioRecorder: NSObject {
    
    // MARK: - Properties
    
    private let recordName = "voiceMessage"
    
    private let audioSession = AVAudioSession.sharedInstance()
    
    private var audioRecorder: AVAudioRecorder?
    
    private var audioPlayer = AVAudioPlayer()
    
    private var timer: Timer?
    
    private var time: TimeInterval = 0
    
    var isPlaying = false
    
    var isRecording = false
    
    var url: URL?
    
    var timeDidChange: ((_ progress: Float, _ formattedTimer: String) -> Void)?
    
    weak var delegate: AudioRecorderDelegate?
    
    var formattedCurrentTime: String {
        let components = DateComponentsFormatter()
        components.allowedUnits = time >= 3600 ? [.hour, .minute, .second] : [.minute, .second]
        components.zeroFormattingBehavior = .pad
        
        return components.string(from: time) ?? ""
    }
    
    // MARK: - Init
    
    deinit {
        stopPlaying()
        try? stop()
    }
    
    // MARK: - Methods
    
    func record() async throws {
        guard await isRecordPermissionGranted() else {
            throw CommonError.failed("Record permission not granted.")
        }
        
        try setupRecorder()
        
        if !isRecording, let recorder = self.audioRecorder {
            try audioSession.setActive(true)
            
            time = 0
            timeDidChange?(0, formattedCurrentTime)
            
            timer = Timer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
            recorder.record()
            
            isRecording = true
        }
    }
    
    func pause() {
        isPlaying = false
        audioPlayer.pause()
        timer?.invalidate()
    }
    
    func stop() throws {
        isRecording = false
        audioRecorder?.stop()
        
        try audioSession.setActive(false)
    }
    
    func play() throws {
        guard !isRecording && !isPlaying else {
            throw CommonError.failed("Recording or already playing.")
        }
        guard let recorder = audioRecorder else {
            throw CommonError.unableToParse("audioRecorder")
        }
        
        if let url, recorder.url == url, audioPlayer.currentTime != 0 {
            isPlaying = audioPlayer.play()
        } else {
            audioPlayer = try AVAudioPlayer(contentsOf: recorder.url)
            audioPlayer.delegate = self as AVAudioPlayerDelegate
            url = audioRecorder?.url
            isPlaying = audioPlayer.play()
        }
        
        if isPlaying {
            if audioPlayer.currentTime == 0 {
                time = 0
                timeDidChange?(0, formattedCurrentTime)
            }
            
            timer = .scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        }
    }
    
    func delete() throws {
        guard let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw CommonError.unableToParse("path")
        }
        
        let bundle = path.appendingPathComponent(recordName.appending(".m4a"))
        let manager = FileManager.default
        
        if manager.fileExists(atPath: bundle.path) {
            try manager.removeItem(at: bundle)
        } else {
            throw CommonError.failed("File does not exist.")
        }
    }
    
    func stopPlaying() {
        audioPlayer.stop()
        isPlaying = false
    }
}

// MARK: - Actions

private extension AudioRecorder {
    
    @objc
    func updateTimer() {
        time += 1
        
        timeDidChange?(Float(time / audioPlayer.duration.rounded()), formattedCurrentTime)
    }
}

// MARK: - AVAudioRecorderDelegate

extension AudioRecorder: AVAudioRecorderDelegate {
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        timeDidChange?(1, formattedCurrentTime)
        isRecording = false
        
        timer?.invalidate()
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        error?.logError()
        
        isRecording = false
        timer?.invalidate()
    }
}

// MARK: - AVAudioPlayerDelegate

extension AudioRecorder: AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        timer?.invalidate()
        isPlaying = false
        
        delegate?.audioRecorder(self, didFinishPlaying: flag)
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        error?.logError()
    }
}

// MARK: - Private methods

private extension AudioRecorder {
    
    func isRecordPermissionGranted() async -> Bool {
        guard AVAudioSession.sharedInstance().recordPermission != .granted else {
            return true
        }
        
        return await withCheckedContinuation { continuation in
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
    }
    
    /// Prepare `AVAudioRecorder` for recording and audio session for play and record actions.
    func setupRecorder() throws {
        guard let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw CommonError.unableToParse("path")
        }
        let fileName = path.appendingPathComponent(recordName.appending(".m4a"))
        
        try audioSession.setCategory(.playAndRecord, options: .defaultToSpeaker)
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        audioRecorder = try AVAudioRecorder(url: fileName, settings: settings)
        audioRecorder?.delegate = self as AVAudioRecorderDelegate
        audioRecorder?.isMeteringEnabled = true
        audioRecorder?.prepareToRecord()
        url = audioRecorder?.url
    }
}
