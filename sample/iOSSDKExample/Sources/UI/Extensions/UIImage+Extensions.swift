import SwiftUI
import UIKit

extension UIImage {
    
    // MARK: - Methods
    
    static func load(_ named: String, from directory: FileManager.SearchPathDirectory) throws -> UIImage {
        guard var path = FileManager.default.urls(for: directory, in: .userDomainMask).first else {
            throw CommonError.unableToParse("documentsUrl")
        }
        
        path = path.appendingPathComponent(named)
        
        guard let image = UIImage(contentsOfFile: path.relativePath) else {
            throw CommonError.failed("Unable to get image named: \(named) from directory: \(path.relativePath).")
        }
        
        return image
    }
}
