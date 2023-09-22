import Foundation

extension Data {
    /// Create a Data object by reading the contents of an InputStream
    ///
    /// - parameter reading: InputStream to read
    init(stream input: InputStream) throws {
        self.init()

        input.open()
        defer { input.close() }

        let bufferSize = 1024
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        defer { buffer.deallocate() }

        while input.hasBytesAvailable {
            let read = input.read(buffer, maxLength: bufferSize)
            if read < 0 {
                // Stream error occured
                throw input.streamError!
            } else if read == 0 {
                // EOF
                break
            }
            self.append(buffer, count: read)
        }
    }
}
