//
//  OWSettingsWrapper.swift
//  SpotImCore
//
//  Created by Alon Haiut on 20/11/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

class OWSettingsWrapper {
    fileprivate struct Metrics {
        static let sdkVersionKey: String = "sdkVersion"
        static let plistSuffix: String = "plist"
        static let openWebSettingsResource: String = "OpenWebSettings"
    }

    fileprivate static let shared = OWSettingsWrapper()
    fileprivate var sdkVersion: String?

    private init() {
        if let path = Bundle.spot.path(forResource: Metrics.openWebSettingsResource, ofType: Metrics.plistSuffix) {
            let dictionary: NSDictionary?
            dictionary = NSDictionary(contentsOfFile: path)
            sdkVersion = dictionary?[Metrics.sdkVersionKey] as? String
        }
    }

    static func sdkVersion() -> String? {
        return shared.sdkVersion
    }
 }
