//
//  OWVersion.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 26/06/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

class OWVersion: Decodable {
    fileprivate let major: Int
    fileprivate let minor: Int
    fileprivate let patch: Int

    init(from versionString: String) throws {
        let versionDelimiter = "."
        let versions = versionString.components(separatedBy: versionDelimiter)
        guard let major = Int(versions[0]),
              let minor = versions.count > 1 ? Int(versions[1]) : 0,
              let patch = versions.count > 2 ? Int(versions[2]) : 0 else {
            throw OWParserError.generalParseError
        }
        self.major = major
        self.minor = minor
        self.patch = patch
    }

    required convenience init(from decoder: Decoder) throws {
        guard let versionString = try? decoder.singleValueContainer().decode(String.self) else {
            throw OWParserError.generalParseError
        }
        do {
            try self.init(from: versionString)
        } catch let err {
            throw err
        }

    }
}

extension OWVersion: Comparable, Equatable {
    static func < (lhs: OWVersion, rhs: OWVersion) -> Bool {
        if lhs.major != rhs.major {
            return lhs.major < rhs.major
        } else if lhs.minor != rhs.minor {
            return lhs.minor < rhs.minor
        } else {
            return lhs.patch < rhs.patch
        }
    }

    static func == (lhs: OWVersion, rhs: OWVersion) -> Bool {
        return lhs.major == rhs.major && lhs.minor == rhs.minor && lhs.patch == rhs.patch
    }
}

extension OWVersion: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(major.hashValue)
        hasher.combine(minor.hashValue)
        hasher.combine(patch.hashValue)
    }
}
