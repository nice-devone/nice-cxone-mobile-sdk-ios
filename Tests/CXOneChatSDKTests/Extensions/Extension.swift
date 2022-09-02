import XCTest

extension XCTestCase {
    func loadStubFromBundle(withName name: String, extension: String) ->  Data {
        let url = URL(forResource: name, type: `extension`)
        return try! Data(contentsOf: url)
    }
}

fileprivate let _resources: URL = {
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
    let resourceComponents = rootComponents + trailingComponents[0...1] + ["Resources"]
    return URL(fileURLWithPath: resourceComponents.joined(separator: "/"), isDirectory: true)
}()

extension URL {
    init(forResource name: String, type: String) {
        let url = _resources.appendingPathComponent("\(name).\(type)", isDirectory: false)
        self = url
    }
}
