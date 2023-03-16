//
//  OWHTTPHeaderRequestMiddleware.swift
//  SpotImCore
//
//  Created by Alon Haiut on 19/04/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import UIKit

struct OWHTTPHeaderName {
    static let contentType = "Content-Type"
    static let userAgent = "User-Agent"
    static let authorization = "Authorization"
    static let spotId = "x-spot-id"
    static let postId = "x-post-id"
    static let platform = "x-platform"
    static let platformVersion = "x-platform-version"
    static let moblieGWVersion = "x-moblie-gw-version"
    static let sdkVersion = "x-sdk-version"
    static let appVersion = "x-app-version"
    static let appScheme = "x-app-scheme"
    static let pageViewId = "x-spotim-page-view-id"
    static let openWebToken = "x-openweb-token"
    static let guid = "x-guid"
}

struct OWHTTPHeaderContent {
    static let json = "application/json"
}

class OWHTTPHeaderRequestMiddleware: OWRequestMiddleware {

    fileprivate let servicesProvider: OWSharedServicesProviding

    init(servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.servicesProvider = servicesProvider
    }

    func process(request: URLRequest) -> URLRequest {

        var headers: OWNetworkHTTPHeaders = [
            OWHTTPHeaderName.contentType: OWHTTPHeaderContent.json,
            OWHTTPHeaderName.spotId: OWManager.manager.spotId,
            OWHTTPHeaderName.postId: OWManager.manager.postId ?? "default",
            OWHTTPHeaderName.platform: UIDevice.current.deviceTypeXPlatformHeader(),
            OWHTTPHeaderName.moblieGWVersion: "v1.0.0",
            OWHTTPHeaderName.platformVersion: UIDevice.current.systemVersion,
            OWHTTPHeaderName.sdkVersion: OWSettingsWrapper.sdkVersion() ?? "na",
            OWHTTPHeaderName.appVersion: Bundle.main.shortVersion ?? "na",
            OWHTTPHeaderName.appScheme: Bundle.main.bundleIdentifier ?? "na",
            OWHTTPHeaderName.userAgent: extendedAgent(),
            OWHTTPHeaderName.pageViewId: SPAnalyticsHolder.default.pageViewId
        ]

        let authenticationManager = servicesProvider.authenticationManager()
        let cerdentials = authenticationManager.networkCredentials

        if let guid = cerdentials.guid, !guid.isEmpty {
            headers[OWHTTPHeaderName.guid] = guid
        }

        if let authorization = cerdentials.authorization, !authorization.isEmpty {
            headers[OWHTTPHeaderName.authorization] = authorization
        }

        if let openwebToken = cerdentials.openwebToken, !openwebToken.isEmpty {
            headers[OWHTTPHeaderName.openWebToken] = openwebToken
        }

        var newRequest = request

        headers.dictionary.forEach { header, content in
            newRequest.setValue(content, forHTTPHeaderField: header)
        }

        return newRequest
    }
}

fileprivate extension OWHTTPHeaderRequestMiddleware {
    func extendedAgent() -> String {
        var agent = OWNetworkHTTPHeaders.default.dictionary["User-Agent"] ?? "na"
        let device = UIDevice.modelIdentifier()
        agent.insert(contentsOf: device.appending(" "), at: agent.startIndex)
        return agent
    }
}
