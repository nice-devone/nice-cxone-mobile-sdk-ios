//
//  Created by Customer Dynamics Development on 9/22/21.
//

import Foundation
import CoreLocation
import UIKit
import MessageKit


/// The struct of a location message
public struct CoordinateItem: LocationItem {

	public var location: CLLocation
	public var size: CGSize

	init(location: CLLocation) {
		self.location = location
		self.size = CGSize(width: 240, height: 240)
	}

}
