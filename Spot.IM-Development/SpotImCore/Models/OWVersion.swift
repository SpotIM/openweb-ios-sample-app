//
//  OWVersion.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 26/06/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

class OWVersion {
    fileprivate let major: Int
    fileprivate let minor: Int
    fileprivate let patch: Int

    init?(from versionString: String) {
        do {
            let versionDelimiter = "."
            let versions = versionString.components(separatedBy: versionDelimiter)
            major = Int(versions[0])!
            minor = versions.count > 1 ? Int(versions[1])! : 0
            patch = versions.count > 2 ? Int(versions[2])! : 0
        } catch {
            // TODO: Throw error?
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
