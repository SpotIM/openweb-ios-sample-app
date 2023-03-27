//
//  OWHTTPHeaderRequestMiddleware.swift
//  SpotImCore
//
//  Created by Alon Haiut on 19/04/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import UIKit

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
            OWHTTPHeaderType.contentType.rawValue: OWHTTPHeaderContent.json,
            OWHTTPHeaderType.spotId.rawValue: OWManager.manager.spotId,
            OWHTTPHeaderType.postId.rawValue: OWManager.manager.postId ?? "default",
            OWHTTPHeaderType.platform.rawValue: UIDevice.current.deviceTypeXPlatformHeader(),
            OWHTTPHeaderType.moblieGWVersion.rawValue: "v1.0.0",
            OWHTTPHeaderType.platformVersion.rawValue: UIDevice.current.systemVersion,
            OWHTTPHeaderType.sdkVersion.rawValue: OWSettingsWrapper.sdkVersion() ?? "na",
            OWHTTPHeaderType.appVersion.rawValue: Bundle.main.shortVersion ?? "na",
            OWHTTPHeaderType.appScheme.rawValue: Bundle.main.bundleIdentifier ?? "na",
            OWHTTPHeaderType.userAgent.rawValue: extendedAgent(),
            OWHTTPHeaderType.pageViewId.rawValue: SPAnalyticsHolder.default.pageViewId
        ]

        let authenticationManager = servicesProvider.authenticationManager()
        let cerdentials = authenticationManager.networkCredentials

        if let guid = cerdentials.guid, !guid.isEmpty {
            headers[OWHTTPHeaderType.guid.rawValue] = guid
        }

        if let authorization = cerdentials.authorization, !authorization.isEmpty {
            headers[OWHTTPHeaderType.authorization.rawValue] = authorization
        }

        if let openwebToken = cerdentials.openwebToken, !openwebToken.isEmpty {
            headers[OWHTTPHeaderType.openWebToken.rawValue] = openwebToken
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
