//
//  SampleAppDeeplink.swift
//  OpenWeb-SampleApp
//
//  Created by Alon Haiut on 12/08/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

import Foundation

enum SampleAppDeeplink: Int, Codable {
    static func deeplink(fromIndex index: Int) -> SampleAppDeeplink {
        return Self(rawValue: index) ?? `default`
    }

    case none
    case about
    case testAPI
    case settings
    case authentication

    var index: Int {
        return rawValue
    }

    var toDeepLinkOptions: DeepLinkOptions? {
        switch self {
        case .none: return nil
        case .about: return .about
        case .testAPI: return .testAPI
        case .settings: return .settings
        case .authentication: return .authenticationPlayground
        }
    }

    static let `default`: SampleAppDeeplink = .none
}
