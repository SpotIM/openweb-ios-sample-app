//
//  OWSettingsWrapper.swift
//  OpenWebSDK
//
//  Created by Alon Haiut on 20/11/2022.
//  Copyright © 2022 OpenWeb. All rights reserved.
//

import Foundation

class OWSettingsWrapper {
    private struct Metrics {
        static let sdkVersionKey: String = "sdkVersion"
        static let plistSuffix: String = "plist"
        static let openWebSettingsResource: String = "OpenWebSettings"
    }

    private static let shared = OWSettingsWrapper()
    private var sdkVersion: String?

    private init() {
        if let path = Bundle.openWeb.path(forResource: Metrics.openWebSettingsResource, ofType: Metrics.plistSuffix) {
            let dictionary: NSDictionary?
            dictionary = NSDictionary(contentsOfFile: path)
            sdkVersion = dictionary?[Metrics.sdkVersionKey] as? String
        }
    }

    static func sdkVersion() -> String? {
        return shared.sdkVersion
    }
 }
