//
//  Logger.swift
//  Core
//

import Foundation

struct OWLogger {
    
    enum Level: String, CustomStringConvertible {
        
        case verbose, success, warning, failure
        
        var description: String {
            switch self {
            case .verbose:
                return "V"
            case .success:
                return "S"
            case .warning:
                return "W"
            case .failure:
                return "E"
            }
        }
    }
    
    private init() {}
    
    static func success(_ string: @autoclosure () -> String, file: String = #file, line: Int = #line) {
        log(.success, string(), file: file, line: line)
    }
    
    static func error(_ string: @autoclosure () -> String, file: String = #file, line: Int = #line) {
        log(.failure, string(), file: file, line: line)
    }
    
    static func verbose(_ string: @autoclosure () -> String, file: String = #file, line: Int = #line) {
        log(.verbose, string(), file: file, line: line)
    }
    
    static func warn(_ string: @autoclosure () -> String, file: String = #file, line: Int = #line) {
        log(.warning, string(), file: file, line: line)
    }
    
    private static func log(_ level: Level, _ string: @autoclosure () -> String, file: String = #file,
                            line: Int = #line) {
        #if DEBUG
        let startIndex = file.range(of: "/", options: .backwards)?.upperBound
        let fileName = file[startIndex!...]
        print("\(printTime()): \(level.description)/\(fileName)(\(line)): \(string())")
        #endif
    }
    
    private static func printTime() -> String {
        let date = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour,.minute,.second], from: date)
        let hour = components.hour
        let minutes = components.minute
        let second = components.second
        
        return "\(hour ?? 0):\(minutes ?? 0):\(second ?? 0)"
    }
}

extension OWLogger {
    
    static func error(_ error: Error, file: String = #file, line: Int = #line) {
        self.error("\(error)", file: file, line: line)
    }
    
    static func warn(_ error: Error, file: String = #file, line: Int = #line) {
        self.warn("\(error)", file: file, line: line)
    }
    
}
