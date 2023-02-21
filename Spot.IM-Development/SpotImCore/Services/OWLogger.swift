//
//  OWLogger.swift
//  SpotImCore
//
//  Created by Alon Haiut on 26/04/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import os.log
import RxSwift

#if NEW_API
public enum OWLogLevel {
    case none, error, medium, verbose
}

public enum OWLogMethod {
    case nsLog, osLog, file(maxFilesNumber: Int)
}
#else
enum OWLogLevel {
    case none, error, medium, verbose
}

enum OWLogMethod {
    case nsLog, osLog, file(maxFilesNumber: Int)
}
#endif

extension OWLogLevel {

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

    static var defaultLevelToUse: OWLogLevel {
        return .verbose
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

extension OWLogMethod {
    static var defaultMethodsToUse: [OWLogMethod] {
        return [.nsLog, .file(maxFilesNumber: OWLogger.Metrics.defaultLogFilesNumber)]
    }
}

#if NEW_API
extension OWLogMethod: Hashable {
    public func hash(into hasher: inout Hasher) {
        switch self {
        case .nsLog:
            return hasher.combine(1)
        case .osLog:
            return hasher.combine(2)
        case .file(_):
            return hasher.combine(3)
        }
    }
}
#else
extension OWLogMethod: Hashable {
    func hash(into hasher: inout Hasher) {
        switch self {
        case .nsLog:
            return hasher.combine(1)
        case .osLog:
            return hasher.combine(2)
        case .file(_):
            return hasher.combine(3)
        }
    }
}
#endif

class OWLogger {
    struct Metrics {
        static let logFileName = "OpenWeb_SDK_log"
        static let defaultLogFilesNumber = 20
    }

    fileprivate struct PrivateMetrics {
        static let osLoggersSubsystem = "com.OpenWeb.sdk"
        static let failedToWriteLogFileDescription = "Failure when trying to write log file"
        static let failedToDeleteLogFileDescription = "Failure when trying to delete log file"
        static let maxAllowedLogFilesNumber = 200
        static let minAllowedLogFilesNumber = 1
    }

    fileprivate let logLevel: OWLogLevel
    fileprivate let logMethods: [OWLogMethod]
    fileprivate let queue: DispatchQueue
    fileprivate let appLifeCycle: OWRxAppLifeCycleProtocol
    fileprivate let prefix: String
    fileprivate var osLoggers = [String: OSLog]()
    fileprivate let sdkVer: String
    fileprivate let hostBundleName: String
    fileprivate let maxItemsPerLogFile: Int
    fileprivate var maxLogFilesNumber: Int
    fileprivate var logItems = [String]()
    // Non DI as those should be constant
    fileprivate let fileCreationQueue = DispatchQueue(label: "OpenWebSDKLoggerFileCreationQueue", qos: .background) // Serial queue
    fileprivate let disposeBag = DisposeBag()

    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        // UTC time zone - intentionally force to UTC and not the user time zone
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        // Example 2022-04-27 18:03:56.204
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter
    }()

    init(logLevel: OWLogLevel, logMethods: [OWLogMethod],
         queue: DispatchQueue = DispatchQueue(label: "OpenWebSDKLoggerQueue", qos: .utility),
         appLifeCycle: OWRxAppLifeCycleProtocol = OWSharedServicesProvider.shared.appLifeCycle(),
         prefix: String = "OpenWebSDKLogger", sdkVer: String = (OWSettingsWrapper.sdkVersion() ?? "na"),
         hostBundleName: String = Bundle.main.bundleName ?? "",
         maxItemsPerLogFile: Int = 100) {
        self.logLevel = logLevel
        self.logMethods = Array(Set(logMethods))
        self.queue = queue
        self.prefix = prefix
        self.sdkVer = sdkVer
        self.hostBundleName = hostBundleName
        self.maxItemsPerLogFile = maxItemsPerLogFile
        self.appLifeCycle = appLifeCycle

        if self.logMethods.contains(.osLog) {
            osLoggers[prefix] = OSLog(subsystem: PrivateMetrics.osLoggersSubsystem, category: prefix)
        }

        self.maxLogFilesNumber = Metrics.defaultLogFilesNumber
        if self.logMethods.contains(where: { method in
            if case .file(let maxFilesNum) = method {
                self.maxLogFilesNumber = validateMaxNumberOfLogFiles(number: maxFilesNum)
                return true
            }
            return false
        }) {
            // Make sure we don't have a greater log files which exist than the requested new max of log files
            fileCreationQueue.async { [weak self] in
                guard let self = self else { return }
                self.removeExceedingLogFilesIfNeeded()
            }
        }

        setupObservers()
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

    // Deinit
    // Will be called if the logger configuration was changed because we creating a new logger in such case
    // I intentionally decided to do nothing in such case, i.e NOT saving the log in case the publisher decided to change configuration
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
                NSLog("%@%@", info, text)
            case .osLog:
                let osLogger = osLoggers[prefix] ?? OSLog(subsystem: PrivateMetrics.osLoggersSubsystem, category: prefix)
                let textToLog = format + text
                os_log("%@", log: osLogger, type: level.osLevel, textToLog)
            case .file(_):
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
        let filename = "\(Metrics.logFileName)_\(Date.timeIntervalSinceReferenceDate).txt"
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
            NSLog(info + PrivateMetrics.failedToWriteLogFileDescription)
        }
    }

    func removeOldestLogFileIfNeeded() {
        let numberOfLogsWritten = retrieveNumberOfSavedLogs()
        if (numberOfLogsWritten >= maxLogFilesNumber) {
            // Remove oldest
            removeOldestLogFiles(numOfFilesToRemove: 1)
        }
    }

    func removeExceedingLogFilesIfNeeded() {
        let numberOfLogsWritten = retrieveNumberOfSavedLogs()
        if (numberOfLogsWritten > maxLogFilesNumber) {
            // Remove exceeding
            let numToRemove = numberOfLogsWritten - maxLogFilesNumber
            removeOldestLogFiles(numOfFilesToRemove: numToRemove)
        }
    }

    func retrieveNumberOfSavedLogs() -> Int {
        let numberOfElements = OWFiles.elementsName(folder: OWFiles.Metrics.OpenSDKWebFolder,
                                                    subfolder: OWFiles.Metrics.LogsSubfolder)

        return numberOfElements
            .filter { $0.contains(Metrics.logFileName) }
            .count
    }

    func removeOldestLogFiles(numOfFilesToRemove: Int) {
        var savedFilenames = OWFiles.elementsName(folder: OWFiles.Metrics.OpenSDKWebFolder,
                                                  subfolder: OWFiles.Metrics.LogsSubfolder)

        savedFilenames = savedFilenames
            .filter { $0.contains(Metrics.logFileName) }

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

        var timestamps = Array(mapper.keys)
        timestamps.sort { $0 < $1 }

        // Taking the min number so we won't exceed boundary
        let numberOfFilesToRemove = min(timestamps.count, numOfFilesToRemove)
        for _ in 1...numberOfFilesToRemove {
            // Find filename of the oldest log
            guard let oldestTimestamp = timestamps.first,
                  let filenameToRemove = mapper[oldestTimestamp] else { return }

            let result = OWFiles.remove(filename: filenameToRemove, folder: OWFiles.Metrics.OpenSDKWebFolder,
                                        subfolder: OWFiles.Metrics.LogsSubfolder)

            if !result {
                // Failed to remove log file. NSlog for internal debugging
                let info = "\(self.prefix) -\(OWLogLevel.error.description) ver \(sdkVer): "
                NSLog(info + PrivateMetrics.failedToDeleteLogFileDescription)
            }

            timestamps.removeFirst()
        }
    }

    func validateMaxNumberOfLogFiles(number: Int) -> Int {
        guard number <= PrivateMetrics.maxAllowedLogFilesNumber && number >= PrivateMetrics.minAllowedLogFilesNumber else { return Metrics.defaultLogFilesNumber}
        return number
    }
}

// Rx
fileprivate extension OWLogger {
    func setupObservers() {
        appLifeCycle.didEnterBackground
            .filter { [weak self] in
                guard let self = self else { return false }
                return self.needsToWriteLogFile()
            }
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.fileCreationQueue.async { [weak self] in
                    guard let self = self else { return }
                    self.writeLogFile()
                }
            })
            .disposed(by: disposeBag)
    }

    func needsToWriteLogFile() -> Bool {
        return !logItems.isEmpty && self.logMethods.contains(where: { method in
            if case .file = method {
                return true
            }
            return false
        })
    }
}

