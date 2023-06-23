@testable import CXoneChatSDK
import XCTest


class LogManagerTests: XCTestCase {
    
    // MARK: - Properties
    
    private let traceEmoji = "❇️"
    private let dateProvider = DateProviderMock()
    
    private var levelTestCases = [(LogManager.Level, String)]()
    private var verbosityTestCases = [(LogManager.Verbosity, String)]()
    
    private let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        
        return formatter
    }()
    
    
    // MARK: - Lifecycle
    
    override  func setUp() {
        super.setUp()
        
        levelTestCases = [
            (.error, "Error message"),
            (.warning, "Warning message"),
            (.info, "Info message"),
            (.trace, "Trace message")
        ]
        verbosityTestCases = [
            (.simple, "message"),
            (.medium, "message"),
            (.full, "message")
        ]
    }
    
    
    // MARK: - Tests
    
    func testIgnoreDelegates() {
        var expectations = [XCTestExpectation]()
        
        levelTestCases.forEach { level, _ in
            let expectation = XCTestExpectation(description: "Delegate for level - \(level) called")
            expectation.isInverted = true
            let testClass = TestClass(expectation: expectation)
            expectations.append(expectation)
            
            testClass.fireDelegate(type: level)
        }
        
        wait(for: expectations, timeout: 1.0)
    }
    
    func testLowerLevels() {
        var expectations = [XCTestExpectation]()
        
        levelTestCases.removeFirst()
        levelTestCases.forEach { level, _ in
            let expectation = XCTestExpectation(description: "Delegate for level - \(level) called")
            expectation.isInverted = true
            let testClass = TestClass(expectation: expectation)
            let logLevel = LogManager.Level(rawValue: level.rawValue + 1) ?? .trace
            testClass.configureLogger(level: logLevel)
            expectations.append(expectation)
            
            testClass.fireDelegate(type: level)
        }
        
        wait(for: expectations, timeout: 1.0)
    }
    
    func testDelegates() {
        var expectations = [XCTestExpectation]()
        
        levelTestCases.forEach { level, message in
            let expectation = XCTestExpectation(description: "Delegate for level - \(level) called")
            let testClass = TestClass(expectation: expectation)
            testClass.configureLogger()
            expectations.append(expectation)
            
            testClass.fireDelegate(type: level)
            XCTAssertTrue(testClass.message.contains(message))
        }
        
        wait(for: expectations, timeout: 1.0)
    }
    
    func testVerbosity()  {
        var expectations = [XCTestExpectation]()
        
        verbosityTestCases.forEach { verbosity, message in
            let expectation = XCTestExpectation(description: "Delegate for verbosity - \(verbosity) called")
            let testClass = TestClass(expectation: expectation)
            testClass.configureLogger(verbosity: verbosity)
            expectations.append(expectation)
            
            testClass.fireDelegate(type: .trace)
            XCTAssertTrue(testClass.message.contains(message))
            
            let date = formatter.string(from: dateProvider.now)
            XCTAssertTrue(testClass.message.contains(date), "Mesage does not contain datetime. Message: \(testClass.message)")
            XCTAssertTrue(testClass.message.contains(traceEmoji), "Mesage does not contain emoji. Message: \(testClass.message)")
            
            switch verbosity {
            case .simple:
                XCTAssertFalse(testClass.message.contains("fireDelegate"), "Message with wrong param. Message: \(testClass.message)")
                XCTAssertFalse(testClass.message.contains("LogManagerTests"), "Message with wrong param. Message: \(testClass.message)")
            case .medium:
                XCTAssertTrue(testClass.message.contains("fireDelegate"), "Message with wrong param. Message: \(testClass.message)")
                XCTAssertFalse(testClass.message.contains("LogManagerTests"), "Message with wrong param. Message: \(testClass.message)")
            case .full:
                XCTAssertTrue(testClass.message.contains("fireDelegate"), "Message with wrong param. Message: \(testClass.message)")
                XCTAssertTrue(testClass.message.contains("LogManagerTests"), "Message with wrong param. Message: \(testClass.message)")
            }
        }
        
        wait(for: expectations, timeout: 1.0)
    }
}


// MARK: - Test Class

private class TestClass: NSObject {
    
    // MARK: - Properties
    
    var message = ""
    let expectation: XCTestExpectation
    
    
    // MARK: - Init
    
    init(expectation: XCTestExpectation) {
        self.expectation = expectation
        super.init()
    }
    
    
    // MARK: - Methods
    
    func configureLogger(level: LogManager.Level = .trace, verbosity: LogManager.Verbosity = .full) {
        LogManager.configure(level: level, verbosity: verbosity)
        LogManager.delegate = self
    }
    
    func fireDelegate(type level: LogManager.Level) {
        switch level {
        case .error:
            LogManager.error(CXoneChatError.missingParameter("Error message"))
        case .warning:
            LogManager.warning(CXoneChatError.missingParameter("Warning message"))
        case .info:
            LogManager.info("Info message")
        case .trace:
            LogManager.trace("Trace message")
        }
    }
}


// MARK: - LogDelegate

extension TestClass: LogDelegate {
    
    func logError(_ message: String) {
        expectation.fulfill()
        
        self.message = message
    }
    
    func logWarning(_ message: String) {
        expectation.fulfill()
        
        self.message = message
    }
    
    func logInfo(_ message: String) {
        expectation.fulfill()
        
        self.message = message
    }
    
    func logTrace(_ message: String) {
        expectation.fulfill()
        
        self.message = message
    }
}
