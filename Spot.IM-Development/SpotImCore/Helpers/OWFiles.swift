//
//  OWFiles.swift
//  SpotImCore
//
//  Created by Alon Haiut on 28/04/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

class OWFiles {
    struct Metrics {
        static let OpenSDKWebFolder: String = "OpenWebSdk"
        static let LogsSubfolder: String = "Logs"
    }

    // Return true if exist
    static func isFileExist(filename: String, folder: String?, subfolder: String?) -> Bool {
        // Path before the file
        guard let url = url(forFolder: folder, subfolder: subfolder) else { return false }
        // File path
        let filePath = url.appendingPathComponent(filename).path
        if FileManager.default.fileExists(atPath: filePath) {
            return true
        } else {
            return false
        }
    }

    // Return true if wrote successfully
    static func write(text: String, filename: String, folder: String?, subfolder: String?) -> Bool {
        // Path before the file
        guard let url = url(forFolder: folder, subfolder: subfolder) else { return false }

        // Create directory if needed
        if let folder = folder, !FileManager.default.fileExists(atPath: url.path) {
            let dirCreationResult = createFolder(folder, subfolder: subfolder)
            if !dirCreationResult { return false }
        }

        // File url
        let fileUrl = url.appendingPathComponent(filename)
        do {
            try text.write(to: fileUrl, atomically: false, encoding: .utf8)
            return true
        } catch {
            // Just return false
            return false
        }
    }

    // Return true if removed successfully
    static func remove(filename: String, folder: String?, subfolder: String?) -> Bool {
        // Path before the file
        guard let url = url(forFolder: folder, subfolder: subfolder) else { return false }
        // File url
        let fileUrl = url.appendingPathComponent(filename)
        do {
            try FileManager.default.removeItem(atPath: fileUrl.path)
            return true
        } catch {
            // Just return false
            return false
        }
    }

    // Return number of files / elements in path
    static func numOfElements(folder: String, subfolder: String?) -> Int {
        // Path before the file
        guard let url = url(forFolder: folder, subfolder: subfolder),
              let dirContents = try? FileManager.default.contentsOfDirectory(atPath: url.path) else {
                  return 0
              }
        return dirContents.count
    }

    // Return file names in path ()
    static func elementsName(folder: String, subfolder: String?) -> [String] {
        // Path before the file
        guard let url = url(forFolder: folder, subfolder: subfolder),
              let dirContents = try? FileManager.default.contentsOfDirectory(atPath: url.path) else {
                  return []
              }
        return dirContents
    }
}

fileprivate extension OWFiles {
    static func url(forFolder folder: String?, subfolder: String?) -> URL? {
        // Documnet path
        guard var url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        // Adding folder and subfoler if exist
        if let folder = folder {
            url = url.appendingPathComponent("\(folder)/")
            // Adding subfolder only if folder exist
            if let subfolder = subfolder {
                url = url.appendingPathComponent("\(subfolder)/")
            }
        }
        return url
    }

    static func createFolder(_ folder: String, subfolder: String?, withIntermediateDirectories: Bool = true) -> Bool {
        guard let url = url(forFolder: folder, subfolder: subfolder) else { return false }
        do {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: withIntermediateDirectories, attributes: nil)
            return true
        } catch {
            // Just return false
            return false
        }
    }
}
