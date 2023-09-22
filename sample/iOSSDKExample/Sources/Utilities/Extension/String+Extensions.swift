import UIKit

extension String {
    
    func mapNonEmpty(_ transform: (String) throws -> String) rethrows -> String? {
        guard self != "" else {
            return nil
        }
        
        return try? transform(self)
    }
    
    func substring(from: String) -> String? {
        guard let range = self.range(of: from) else {
            return nil
        }
        
        return String(self[range.upperBound...])
    }
    
    func substring(to: String) -> String? {
        guard let range = self.range(of: to) else {
            return nil
        }
        
        return String(self[..<range.lowerBound])
    }
    
    func substring(from: String, to: String) -> String? {
        guard let range = self.range(of: from) else {
            return nil
        }
        
        let subString = String(self[range.upperBound...])
        
        guard let range = subString.range(of: to) else {
            return nil
        }
        
        return String(subString[..<range.lowerBound])
    }
    
    func toInt() -> Int? {
        Int(self)
    }
    
    func height(withConstrainedWidth width: CGFloat, font: UIFont.TextStyle) -> CGFloat {
        self.height(withConstrainedWidth: width, font: .preferredFont(forTextStyle: font))
    }
    
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(
            with: constraintRect,
            options: .usesLineFragmentOrigin,
            attributes: [.font: font],
            context: nil
        )
    
        return ceil(boundingBox.height)
    }
}
