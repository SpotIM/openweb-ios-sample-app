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
    
    
    static func basic(with spotId: String, postId: String = "default") -> HTTPHeaders {
        let iosVersion = UIDevice.current.systemVersion
        let frameworkVersion = OWSettingsWrapper.sdkVersion() ?? "na"
        let hostVerion = Bundle.main.shortVersion ?? "na"
        let scheme = Bundle.main.bundleIdentifier ?? "na"
        let agent = extendedAgent()

        let pageViewId = SPAnalyticsHolder.default.pageViewId
        
        var headers: HTTPHeaders = ["Content-Type": "application/json",
                                    "x-spot-id": spotId,
                                    "x-post-id": postId,
                                    "x-platform": UIDevice.current.deviceTypeXPlatformHeader(),
                                    "x-moblie-gw-version": "v1.0.0",
                                    "x-platform-version": iosVersion,
                                    "x-sdk-version": frameworkVersion,
                                    "x-app-version": hostVerion,
                                    "x-app-scheme": scheme,
                                    "User-Agent": agent,
                                    "x-spotim-page-view-id": pageViewId]
        
        if let userId = SPUserSessionHolder.session.guid, !userId.isEmpty {
            headers[APIHeadersConstants.guid] = userId
        }

        if let token = SPUserSessionHolder.session.token, !token.isEmpty {
            headers[APIHeadersConstants.authorization] = token
        }
        
        if let openwebToken = SPUserSessionHolder.session.openwebToken, !openwebToken.isEmpty {
            headers[APIHeadersConstants.openwebTokenHeader] = openwebToken
        }
        
        return headers
    }

    private static func extendedAgent() -> String {
        var agent = HTTPHeaders.default.dictionary["User-Agent"] ?? "na"
        let device = UIDevice.modelIdentifier()
        agent.insert(contentsOf: device.appending(" "), at: agent.startIndex)
        return agent
    }
}

internal extension Dictionary where Key == AnyHashable, Value == Any {
    var authorizationHeader: String? {
        return self[APIHeadersConstants.authorization] as? String
    }
    
    var openwebTokenHeader: String? {
        return self[APIHeadersConstants.openwebTokenHeader] as? String
    }

    var guidHeader: String? {
        return self[APIHeadersConstants.guid] as? String
    }
}
