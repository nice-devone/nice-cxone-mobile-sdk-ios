import Foundation

extension URLRequest {
    
    // MARK: - Init
    
    init(url: URL, method: HTTPMethod, contentType: String) {
        self.init(url: url)
        
        httpMethod = method.rawValue
        setValue(contentType, forHTTPHeaderField: "Content-Type")
    }
    
    // MARK: - Methods
    
    func log(fun: StaticString = #function, file: StaticString = #file, line: UInt = #line) {
        guard let urlString = url?.absoluteString else {
            return
        }
        var output = "[REQUEST]"
        
        output += httpMethod.map { method in
            " \(method) \(urlString)\n"
        } ?? " \(urlString)\n"
        
        if let allHTTPHeaderFields, !allHTTPHeaderFields.isEmpty {
            output += "Headers: {\n"
            
            for (key, value) in allHTTPHeaderFields {
                output += "  \(key): \(value)\n"
            }
            
            output += "}\n"
        }
        
        if let httpBody, let formattedJSON = String(data: httpBody, encoding: .utf8)?.formattedJSON {
            output += "Body: \(formattedJSON)\n"
        }
        
        LogManager.info(output, fun: fun, file: file, line: line)
    }
}
