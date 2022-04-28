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
            return .info
        case .verbose:
            return .debug
        }
    }
}

enum OWLogMethod {
    case nsLog, osLog, file
}

class OWLogger {
    fileprivate struct Metircs {
        static let osLoggersSubsystem = "com.OpenWeb.sdk"
        static let logFileName = "OpenWeb_SDK_log"
        static let failedToWriteLogFileDescription = "Failure when trying to write log file"
        static let failedToDeleteLogFileDescription = "Failure when trying to delete log file"
    }
    
    fileprivate let logLevel: OWLogLevel
    fileprivate let logMethods: [OWLogMethod]
    fileprivate let queue: DispatchQueue
    fileprivate let prefix: String
    fileprivate var osLoggers = [String :OSLog]()
    fileprivate let sdkVer: String
    fileprivate let hostBundleName: String
    fileprivate let maxItemsPerLogFile: Int
    fileprivate let maxLogFilesNumber: Int
    fileprivate var logItems = [String]()
    // Non DI as those should be constant
    fileprivate let fileCreationQueue = DispatchQueue(label: "OpenWebSDKLoggerFileCreationQueue", qos: .background) // Serial queue
    
    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        // UTC time zone - intentionally force to UTC and not the user time zone
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        // Example 2022-04-27 18:03:56.204
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter
    }()
    
    init(logLevel: OWLogLevel, logMethods: [OWLogMethod],
         queue: DispatchQueue = DispatchQueue(label: "OpenWebSDKLoggerQueue", qos: .utility, attributes: .concurrent),
         prefix: String = "OpenWebSDKLogger", sdkVer: String = (Bundle.spot.shortVersion ?? "na"),
         hostBundleName: String = Bundle.main.bundleName ?? "",
         maxItemsPerLogFile: Int = 100, maxLogFilesNumber: Int = 50) {
        self.logLevel = logLevel
        self.logMethods = Array(Set(logMethods))
        self.queue = queue
        self.prefix = prefix
        self.sdkVer = sdkVer
        self.hostBundleName = hostBundleName
        self.maxItemsPerLogFile = maxItemsPerLogFile
        self.maxLogFilesNumber = maxLogFilesNumber

        if self.logMethods.contains(.osLog) {
            osLoggers[prefix] = OSLog(subsystem: Metircs.osLoggersSubsystem, category: prefix)
        }
    }
    
    func log(level: OWLogLevel, _ text: String, prefix: String? = nil, queue: DispatchQueue? = nil,
             file: String = #file, line: Int = #line) {
        let runQueue = queue ?? self.queue
        
        runQueue.async { [weak self] in
            guard let self = self else { return }
            guard level != .none && self.logLevel != .none else { return } // Continue only if the log level is different than none
            guard level.rank <= self.logLevel.rank else { return } // Continue only if the log level rank appropriate
            
            let loggerPrefix = prefix ?? self.prefix
            self.log(level: level, text, prefix: loggerPrefix, file: file, line: line)
        }
    }
}

fileprivate extension OWLogger {
    func log(level: OWLogLevel, _ text: String, prefix: String, file: String = #file, line: Int = #line) {
        let fileName: String
        if let startIndex = file.range(of: "/", options: .backwards)?.upperBound {
            fileName = String(file[startIndex...])
        } else {
            fileName = file
        }
        
        let format = "-\(level.description) ver \(sdkVer) \(fileName) line (\(line)): "
        
        logMethods.forEach { logMethod in
            switch logMethod {
            case .nsLog:
                let info = "\(prefix) \(format)"
                NSLog(info + text)
            case .osLog:
                let osLogger = osLoggers[prefix] ?? OSLog(subsystem: Metircs.osLoggersSubsystem, category: prefix)
                let textToLog = format + text
                os_log("%@", log: osLogger, type: level.osLevel, textToLog)
            case .file:
                let textToLog = "\(time()) \(hostBundleName) \(prefix) \(format)\(text)"
                // Write on the file creation serial queue
                fileCreationQueue.async { [weak self] in
                    guard let self = self else { return }
                    self.logItems.append(textToLog)
                    // Write lof file if needed
                    guard self.logItems.count >= self.maxItemsPerLogFile else { return }
                    self.writeLogFile()
                }
            }
        }
    }
    
    func time() -> String {
        let date = Date()
        return dateFormatter.string(from: date)
    }
    
    func writeLogFile() {
        let filename = "\(Metircs.logFileName)_\(Date.timeIntervalSinceReferenceDate).txt"
        // Prepare entire log
        let logText = logItems.reduce("") { log, line in
            return "\(log)\(line)\n"
        }
        
        // Delete oldest log if we reach the max log numbers
        removeOldestLogFileIfNeeded()
        
        // Save new file
        let result = OWFiles.write(text: logText, filename: filename, folder: OWFiles.Metrics.OpenSDKWebFolder,
                                   subfolder: OWFiles.Metrics.LogsSubfolder)
        if result {
            // Clean log items in memory
            logItems.removeAll()
        } else {
            // Failed to write log into file. NSlog for internal debugging
            let info = "\(self.prefix) -\(OWLogLevel.error.description) ver \(sdkVer): "
            NSLog(info + Metircs.failedToWriteLogFileDescription)
        }
    }
    
    func removeOldestLogFileIfNeeded() {
        let numberOfLogsWritten = OWFiles.numOfElements(folder: OWFiles.Metrics.OpenSDKWebFolder,
                                                       subfolder: OWFiles.Metrics.LogsSubfolder)
        if (numberOfLogsWritten >= maxLogFilesNumber) {
            //Remove oldest
            let savedFilenames = OWFiles.elementsName(folder: OWFiles.Metrics.OpenSDKWebFolder,
                                                   subfolder: OWFiles.Metrics.LogsSubfolder)
            
            // Creating mapper between the timestamp to the full name
            var mapper = [Double: String]()
            let characterSet = CharacterSet.decimalDigits.union(CharacterSet(charactersIn: "."))
            savedFilenames.forEach { filename in
                // Removing file surfix first
                var components = filename.components(separatedBy: ".")
                guard components.count > 1 else { return }
                components.removeLast()
                let filenameWithoutSurfix = components.joined(separator: ".")
                // Keeping only digits and decimal point
                let timestampString = filenameWithoutSurfix.trimmingCharacters(in: characterSet.inverted)
                guard let timestamp = Double(timestampString) else { return }
                mapper[timestamp] = filename
            }
            
            let timestamps = mapper.keys
            
            // Find filename of the oldest log
            guard let oldestTimestamp = timestamps.min(),
                    let filenameToRemove = mapper[oldestTimestamp] else { return }
            
            let result = OWFiles.remove(filename: filenameToRemove, folder: OWFiles.Metrics.OpenSDKWebFolder,
                           subfolder: OWFiles.Metrics.LogsSubfolder)
            
            if !result {
                // Failed to remove log file. NSlog for internal debugging
                let info = "\(self.prefix) -\(OWLogLevel.error.description) ver \(sdkVer): "
                NSLog(info + Metircs.failedToDeleteLogFileDescription)
            }
        }
    }
}

// RX
fileprivate extension OWLogger {
    func setupObservers() {
        // TODO: Bind to RX service of lifecycle events in the application
        if logMethods.contains(.file) && !logItems.isEmpty {
            writeLogFile()
        }
    }
}

