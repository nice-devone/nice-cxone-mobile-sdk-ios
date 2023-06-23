import Foundation


extension URL {
    
    // MARK: - Properties
    
    private static let _resources: URL = {
        func packageRoot(of file: String) -> URL? {
            func isPackageRoot(_ url: URL) -> Bool {
                let filename = url.appendingPathComponent("Package.swift", isDirectory: false)
                
                return FileManager.default.fileExists(atPath: filename.path)
            }

            var url = URL(fileURLWithPath: file, isDirectory: false)
            
            repeat {
                url = url.deletingLastPathComponent()
                if url.pathComponents.count <= 1 {
                    return nil
                }
            } while !isPackageRoot(url)
            
            return url
        }

        guard let root = packageRoot(of: #file) else {
            fatalError("\(#file) must be contained in a Swift Package Manager project.")
        }
        
        let fileComponents = URL(fileURLWithPath: #file, isDirectory: false).pathComponents
        let rootComponents = root.pathComponents
        let trailingComponents = Array(fileComponents.dropFirst(rootComponents.count))
        let resourceComponents = rootComponents + trailingComponents[0...1] + ["Examples"]
        
        return URL(fileURLWithPath: resourceComponents.joined(separator: "/"), isDirectory: true)
    }()
    
    
    // MARK: - Init
    
    init(forResource name: String, type: String) {
        self = Self._resources.appendingPathComponent("\(name).\(type)", isDirectory: false)
    }
}
