//
//  SPConfigsDataSource.swift
//  Spot.IM-Core
//
//  Created by Andriy Fedin on 16/08/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation

internal final class SPConfigsDataSource {

    static var appConfig: SPSpotConfiguration? {
        didSet {
            NotificationCenter.default.post(name: .spotIMConfigLoaded, object: nil)
            SPAnalyticsHolder.default.domain = appConfig?.initialization?.websiteUrl
        }
    }

    static var adsConfig: SPAdsConfiguration?
}

public extension NSNotification.Name {
    static let spotIMConfigLoaded = Notification.Name("SPConfigLoaded")
}
