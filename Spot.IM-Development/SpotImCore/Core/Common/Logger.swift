//
//  Logger.swift
//  Core
//

import Foundation

struct Logger {
    
    enum Level: String {
        
        case verbose, success, warning, failure
        
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
        print(" \(level.rawValue.uppercased()) [\(NSDate())] \(fileName)(\(line)) | \(string())")
        #endif
    }
}

extension Logger {
    
    static func error(_ error: Error, file: String = #file, line: Int = #line) {
        self.error("\(error)", file: file, line: line)
    }
    
    static func warn(_ error: Error, file: String = #file, line: Int = #line) {
        self.warn("\(error)", file: file, line: line)
    }
    
}
