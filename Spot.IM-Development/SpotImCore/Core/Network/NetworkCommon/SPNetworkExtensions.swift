//
//  SPNetworkExtensions.swift
//  Spot.IM-Core
//
//  Created by Andriy Fedin on 18/06/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation
import Alamofire

internal extension HTTPHeaders {
    static func basic(with spotId: String,
                      _ postId: String) -> HTTPHeaders {
        var headers = unauthorized(with: spotId, postId: postId)
        if let userId = SPUserSessionHolder.session.guid, !userId.isEmpty {
            headers["x-guid"] = userId
        }

        if let token = SPUserSessionHolder.session.token, !token.isEmpty {
            headers["Authorization"] = token
        }
        
        return headers
    }

    static func unauthorized(with spotId: String, postId: String) -> HTTPHeaders {
        let iosVersion = UIDevice.current.systemVersion
        let frameworkVersion = Bundle.spot.shortVersion() ?? "na"
        let hostVerion = Bundle.main.shortVersion() ?? "na"
        let scheme = Bundle.main.infoDictionary?[kCFBundleIdentifierKey as String] as? String ?? "na"
        let agent = extendedAgent()

        let pageViewId = SPAnalyticsHolder.default.pageViewId
        return ["Content-Type": "application/json",
                "x-spot-id": spotId,
                "x-post-id": postId,
                "x-platform": UIDevice.current.deviceTypeXPlatformHeader(),
                "x-moblie-gw-version": "v1.0.0",
                "x-platform-version": iosVersion,
                "x-sdk-version": frameworkVersion,
                "x-app-version": hostVerion,
                "x-app-scheme": scheme,
                "User-Agent": agent,
                "x-spotim-page-view-id": pageViewId
        ]
    }

    private static func extendedAgent() -> String {
        var agent = Alamofire.SessionManager.defaultHTTPHeaders["User-Agent"] ?? "na"
        let device = UIDevice.modelIdentifier()
        agent.insert(contentsOf: device.appending(" "), at: agent.startIndex)
        return agent
    }
}

internal extension Dictionary where Key == AnyHashable, Value == Any {
    var authorizationHeader: String? {
        return self["Authorization"] as? String
    }

    var userIdHeader: String? {
        return self["x-guid"] as? String
    }
}
