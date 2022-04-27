//
//  OWLogger.swift
//  SpotImCore
//
//  Created by Alon Haiut on 26/04/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import os.log

enum OWLogLevel {
    case none, error, medium, verbose
    
    // Description exposed for outside use as well
    var description: String {
        switch self {
        case .none:
            return "n"
        case .error:
            return "e"
        case .medium:
            return "m"
        case .verbose:
            return "v"
        }
    }
    
    fileprivate var rank: Int {
        switch self {
        case .none:
            return 0
        case .error:
            return 1
        case .medium:
            return 2
        case .verbose:
            return 3
        }
    }
    
    fileprivate var osLevel: OSLogType {
        switch self {
        case .none:
            return .default
        case .error:
            return .error
        case .medium:
            return .debug
        case .verbose:
            return .info
        }
    }
}

enum OWLogMethod {
    case console, file
}

class OWLogger {
    fileprivate let logLevel: OWLogLevel
    fileprivate let logMethod: OWLogMethod
    fileprivate let queue: DispatchQueue
    fileprivate let prefix: String
    fileprivate var osLoggers = [String :OSLog]()
    fileprivate let osLoggersSubsystem = "com.OpenWeb.sdk"
    fileprivate let sdkVer: String
    
    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        // Output example 26/4/22
        formatter.dateStyle = .short
        // Output example 1:26:32 PM
        formatter.timeStyle = .medium
        // UTC time zone - intentionally force to UTC and not the user time zone
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        return formatter
    }()
    
    init(logLevel: OWLogLevel, logMethod: OWLogMethod,
         queue: DispatchQueue = DispatchQueue(label: "OpenWebLoggerQueue", qos: .utility),
         prefix: String = "OpenWebLogger", sdkVer: String = (Bundle.spot.shortVersion ?? "na")) {
        self.logLevel = logLevel
        self.logMethod = logMethod
        self.queue = queue
        self.prefix = prefix
        self.sdkVer = sdkVer
        if logMethod == .file {
            osLoggers[prefix] = OSLog(subsystem: osLoggersSubsystem, category: prefix)
        }
    }
    
    func log(level: OWLogLevel, prefix: String? = nil, queue: DispatchQueue? = nil,
             _ text: String , file: String = #file, line: Int = #line) {
        let runQueue = queue ?? self.queue
        
        runQueue.async { [weak self] in
            guard let self = self else { return }
            guard level != .none && self.logLevel != .none else { return } // Continue only if the log level is different than none
            guard level.rank <= self.logLevel.rank else { return } // Continue only if the log level rank appropriate
            
            let loggerPrefix = prefix ?? self.prefix
            self.log(level: level, prefix: loggerPrefix, text, file: file, line: line)
        }
    }
}

fileprivate extension OWLogger {
    func time() -> String {
        let date = Date()
        return dateFormatter.string(from: date)
    }
    
    func log(level: OWLogLevel, prefix: String, _ text: String , file: String = #file, line: Int = #line) {
        let fileName: String
        if let startIndex = file.range(of: "/", options: .backwards)?.upperBound {
            fileName = String(file[startIndex...])
        } else {
            fileName = file
        }
        
        switch logMethod {
        case .console:
            let info = "\(prefix) -\(level)) ver \(sdkVer) \(fileName) line (\(line)): "
            NSLog(info + text)
        case .file:
            // Time and other info taking care by os_log, we only add the sdk version
            let osLogger = osLoggers[prefix] ?? OSLog(subsystem: osLoggersSubsystem, category: prefix)
            let info = "Ver \(sdkVer) \(fileName) line (\(line)): "
            let textToLog = info + text
            os_log("%@", log: osLogger, type: level.osLevel, textToLog)
        }
    }
}

