import Foundation


extension HTTPURLResponse {
    
    func log(data: Data?, error: Error?, fun: StaticString = #function, file: StaticString = #file, line: UInt = #line) {
        guard let urlString = url?.absoluteString else {
            return
        }
        
        var output = "\(statusCode) \(urlString)\n"
        
        output += "Headers: {\n"
        for (key, value) in allHeaderFields {
            output += "  \(key): \(value)\n"
        }
        output += "}\n"
        
        output += "Body: "
        if let data, let formattedJSON = String(data: data, encoding: .utf8)?.formattedJSON {
            output += "\(formattedJSON)\n"
        }
        if let error {
            output += "\nError: \(error.localizedDescription)\n"
        }
        
        LogManager.info(output, fun: fun, file: file, line: line)
    }
}
