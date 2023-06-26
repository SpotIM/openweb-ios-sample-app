//
//  OWVersion.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 26/06/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

class OWVersion {
    fileprivate major: Int
    fileprivate minor: Int
    fileprivate patch: Int

    init?(from versionString: String) {
        do {
            let versionDelimiter = "."
            let versions = versionString.components(separatedBy: versionDelimiter)
            if let a = versions[0] {
                major = Int(major)
            }
        } catch {
            // TODO: Throw error?
        }
    }
}
