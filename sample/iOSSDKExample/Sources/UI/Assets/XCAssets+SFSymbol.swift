import SwiftUI
import UIKit

// TODO: - Replace custom `.systemImage` with native `Image(systemName:)`
extension Asset {
    
    enum Common {
        static let disconnectLegacy: UIImage = .systemImage(named: "bolt.slash.fill")
        static let share: UIImage = .systemImage(named: "square.and.arrow.up")
        static let copy: UIImage = .systemImage(named: "doc.on.doc")
        static let safari: UIImage = .systemImage(named: "safari")
        static let back: UIImage = .systemImage(named: "chevron.left")
        static let disclosure: UIImage = .systemImage(named: "chevron.right")
        static let check: UIImage = .systemImage(named: "checkmark")
        
        static let clear = Image(systemName: "xmark.circle.fill")
        static let success = Image(systemName: "checkmark.circle")
        static let settings = Image(systemName: "gear")
        static let disconnect = Image(systemName: "bolt.slash.fill")
    }
    
    enum Settings {
        static let brandLogoPlaceholder: Image = Image(systemName: "photo")
    }
    
    enum Chat {
        static let editThreadName: UIImage = .systemImage(named: "square.and.pencil")
        static let editCustomFields: UIImage = .systemImage(named: "pencil")
    }
    
    enum Message {
        static let send: UIImage = .systemImage(named: "arrow.up.circle.fill")
        static let attachments: UIImage = .systemImage(named: "arrow.up.doc")
        static let record: UIImage = .systemImage(named: "mic")
        static let stopRecord: UIImage = .systemImage(named: "mic.slash")
        static let play: UIImage = .systemImage(named: "play.fill")
        static let pause: UIImage = .systemImage(named: "pause.fill")
        static let restartRecording: UIImage = .systemImage(named: "arrow.2.circlepath.circle.fill")
        static let trash: UIImage = .systemImage(named: "trash.fill")
        static let link: UIImage = .systemImage(named: "link")
    }
    
    enum Store {
        static let search = Image(systemName: "magnifyingglass")
        static let cart = Image(systemName: "cart")
        
        enum Product {
            static let imagePlaceholder = Image(systemName: "photo")
            static let rating = Image(systemName: "star")
            static let add = Image(systemName: "plus.circle.fill")
            
        }
    }
}

// MARK: - Helpers

private extension UIImage {
    
    class BundleClass: Bundle { }
    
    static func systemImage(named: String) -> UIImage {
        guard let image = UIImage(systemName: named) else {
            fatalError("\(#function) failed: could not init image with name - \(named)")
        }
        
        return image
    }
}
