import Foundation
import MobileCoreServices
import UniformTypeIdentifiers

extension URL {
    
    // MARK: - Properties
    
    var mimeType: String {
        if #available(iOS 14.0, *) {
            let uttype = UTType(filenameExtension: pathExtension)
            
            return uttype?.preferredMIMEType ?? "application/octet-stream"
        } else {
            guard let pathExtension = NSURL(fileURLWithPath: path).pathExtension,
                  let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as NSString, nil)?.takeRetainedValue(),
                  let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue()
            else {
                return "application/octet-stream"
            }
            
            return mimetype as String
        }
    }
}
