//
//  SampleAppDeeplink.swift
//  OpenWeb-SampleApp
//
//  Created by Alon Haiut on 12/08/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

import Foundation

enum SampleAppDeeplink: Codable {
    static func deeplink(fromIndex index: Int) -> SampleAppDeeplink {
        switch index {
        case SampleAppDeeplink.none.index: return .none
        case SampleAppDeeplink.about.index: return .about
        case SampleAppDeeplink.testAPI.index: return .testAPI
        case SampleAppDeeplink.settings.index: return .settings
        case SampleAppDeeplink.authentication.index: return .authentication
        default: return `default`
        }
    }

    case none
    case about
    case testAPI
    case settings
    case authentication

    var index: Int {
        switch self {
        case .none: return 0
        case .about: return 1
        case .testAPI: return 2
        case .settings: return 3
        case .authentication: return 4
        }
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

    static var `default`: SampleAppDeeplink {
        return .none
    }
}
