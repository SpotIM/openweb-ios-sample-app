//
//  OWAnalyticEventServerGeneralData.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 17/07/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import UIKit

struct OWAnalyticEventServerGeneralData: Encodable {
    var spotId: String = OWManager.manager.spotId
    var postId: String = OWManager.manager.postId ?? ""
    var articleUrl: String
    var pageViewId: String = "" // TODO: we should create the correct logic for pageViewId in OWAnalyticsService
    var userStatus: String
    var userId: String // in case user is connected
    var deviceId: String = UIDevice.current.identifierForVendor?.uuidString ?? ""
    var guid: String
    var platform: String = "ios_phone"
    var platformVersion: String = UIDevice.current.systemVersion
    var sdkVersion: String = OWSettingsWrapper.sdkVersion() ?? ""
    var hostAppVersion: String = Bundle.main.shortVersion ?? ""
    var hostAppScheme: String = Bundle.main.bundleIdentifier ?? ""
    var deviceType: String = UIDevice.current.deviceName()
    var layoutStyle: String
}
