import SwiftUI
import UIKit

extension UIColor {
    
    // MARK: - Static Properties
    
    static var backgroundColor: UIColor = .systemBackground
    static var headlineColor: UIColor = .themedColor(light: .lightGray, dark: lightGray.withAlphaComponent(0.8))
    static var textColor: UIColor = .themedColor(light: .darkGray, dark: .lightGray)
    static var valueColor: UIColor = .themedColor(light: .black, dark: .white)
    static var primaryButtonColor: UIColor = .systemBlue
    
    // MARK: - Properties
    
    var color: Color {
        Color(self)
    }
    
    // MARK: - Init
    
    convenience init(rgb red: CGFloat, _ green: CGFloat, _ blue: CGFloat, alpha: CGFloat = 1) {
        self.init(red: red / 255, green: green / 255, blue: blue / 255, alpha: alpha)
    }
    
    convenience init?(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        
        guard hex.count == 3 || hex.count == 6 else {
            return nil
        }
        
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
    
    // MARK: - Static methods
    
    static func themedColor(light: UIColor, dark: UIColor) -> UIColor {
        UIApplication.isDarkModeActive ? dark : light
    }
    
    // MARK: - Methods

    var toHexString: String {
        guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) else {
            return "#000000"
        }

        let cgColorInRGB = cgColor.converted(to: colorSpace, intent: .defaultIntent, options: nil) ?? UIColor.white.cgColor
        let colorRef = cgColorInRGB.components
        let r = colorRef?[0] ?? 0
        let g = colorRef?[1] ?? 0
        let b = ((colorRef?.count ?? 0) > 2 ? colorRef?[2] : g) ?? 0
        let a = cgColor.alpha

        var color = String(
            format: "#%02lX%02lX%02lX",
            r.intColorComponent(),
            g.intColorComponent(),
            b.intColorComponent()
        )

        if a < 1 {
            color += String(
                format: "%02lX",
                a.intColorComponent()
            )
        }

        return color
    }
}

// MARK: - Codable

extension UIColor: Codable { }

extension Decodable where Self: UIColor {

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let components = try container.decode([CGFloat].self)
        
        self = Self(red: components[0], green: components[1], blue: components[2], alpha: components[3])
    }
}

extension Encodable where Self: UIColor {
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        var r, g, b, a: CGFloat
        (r, g, b, a) = (0, 0, 0, 0)
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        try container.encode([r, g, b, a])
    }
}
