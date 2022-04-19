//
//  Created by Customer Dynamics Development on 9/22/21.
//

import Foundation
import MessageKit
import AVFoundation


/// The struct for an Audio Message received.
public struct MockAudioItem: AudioItem {

	public var url: URL
	public var size: CGSize
	public var duration: Float

	init(url: URL) {
		self.url = url
		self.size = CGSize(width: 160, height: 35)
		// compute duration
		let audioAsset = AVURLAsset(url: url)
		self.duration = Float(CMTimeGetSeconds(audioAsset.duration))
	}
}
