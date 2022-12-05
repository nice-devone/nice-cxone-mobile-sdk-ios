import Foundation


// MARK: - ISO8601DateFormatter

extension ISO8601DateFormatter {
	convenience init(_ formatOptions: Options) {
		self.init()
        
		self.formatOptions = formatOptions
	}
}


// MARK: - Formatter

extension Formatter {
    static let iso8601withFractionalSeconds = ISO8601DateFormatter([.withInternetDateTime, .withFractionalSeconds])
}


// MARK: - Date

extension Date {
	var iso8601withFractionalSeconds: String {
        Formatter.iso8601withFractionalSeconds.string(from: self)
    }
}


// MARK: - String

extension String {
	var iso8601withFractionalSeconds: Date? {
        Formatter.iso8601withFractionalSeconds.date(from: self)
    }
}
