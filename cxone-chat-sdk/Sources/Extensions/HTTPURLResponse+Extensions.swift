import Foundation

extension HTTPURLResponse {
    
    func log(data: Data?, error: Error?, fun: StaticString = #function, file: StaticString = #file, line: UInt = #line) {
        guard let urlString = url?.absoluteString else {
            return
        }
        
        var output = "[RESPONSE] \(statusCode) \(urlString)\n"
        
        if !allHeaderFields.isEmpty {
            output += "Headers: {\n"
            for (key, value) in allHeaderFields {
                output += "  \(key): \(value)\n"
            }
            output += "}\n"
        }
        
        if let data, let formattedJSON = String(data: data, encoding: .utf8)?.formattedJSON {
            output += "Body: \(formattedJSON)\n"
        }
        
        if let error {
            output += "\nError: \(error.localizedDescription)\n"
        }
        
        LogManager.info(output, fun: fun, file: file, line: line)
    }
}
