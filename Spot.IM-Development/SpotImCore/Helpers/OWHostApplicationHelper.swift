//
//  OWHostApplicationHelper.swift
//  SpotImCore
//
//  Created by Alon Haiut on 01/08/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

class OWHostApplicationHelper {
    fileprivate struct Metrics {
        static let openWebSampleAppScheme: String = "im.spot.demo"
    }

    fileprivate static let shared = OWHostApplicationHelper()
    fileprivate let hostAppScheme: String

    private init() {
        hostAppScheme = Bundle.main.bundleIdentifier ?? "na"
    }

    static func isOpenWebSampleApp() -> Bool {
        return shared.hostAppScheme == Metrics.openWebSampleAppScheme
    }
 }
