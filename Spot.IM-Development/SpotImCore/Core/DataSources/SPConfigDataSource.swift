//
//  SPConfigDataSource.swift
//  Spot.IM-Core
//
//  Created by Andriy Fedin on 16/08/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation

internal final class SPConfigDataSource {

    static var config: SPSpotConfiguration? {
        didSet {
            NotificationCenter.default.post(name: .spotIMConfigLoaded, object: nil)
            SPAnalyticsHolder.default.domain = config?.initialization?.websiteUrl
        }
    }
}

public extension NSNotification.Name {
    static let spotIMConfigLoaded = Notification.Name("SPConfigLoaded")
}
