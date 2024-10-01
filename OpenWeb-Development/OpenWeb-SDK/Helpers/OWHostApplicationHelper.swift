//
//  OWHostApplicationHelper.swift
//  OpenWebSDK
//
//  Created by Alon Haiut on 01/08/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation

protocol OWHostApplicationHelperProtocol {
    static func isOpenWebSampleApp() -> Bool
}

class OWHostApplicationHelper: OWHostApplicationHelperProtocol {
    private struct Metrics {
        static let openWebSampleAppScheme: String = "im.spot.demo"
    }

    private static let shared = OWHostApplicationHelper()
    private let hostAppScheme: String

    private init() {
        hostAppScheme = Bundle.main.bundleIdentifier ?? "na"
    }

    static func isOpenWebSampleApp() -> Bool {
        return shared.hostAppScheme == Metrics.openWebSampleAppScheme
    }
 }
