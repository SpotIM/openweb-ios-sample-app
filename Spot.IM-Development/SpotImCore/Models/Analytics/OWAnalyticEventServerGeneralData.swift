//
//  OWAnalyticEventServerGeneralData.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 17/07/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import UIKit

struct OWAnalyticEventServerGeneralData: Decodable {
    var spotId: String = OWManager.manager.spotId
    var postId: String = OWManager.manager.postId ?? ""
    var articleUrl: String
    var pageViewId: String = "" // TODO: add to analyticsService? (currently in SPAnalyticsService, what the meaning? when do we change it?)
    var userStatus: String
    var userId: String // in case user is connected
    var deviceId: String = UIDevice.current.identifierForVendor?.uuidString ?? ""
    var guid: String
    var platform: String = "ios_phone"
    var platformVersion: String = UIDevice.current.systemVersion
    var sdkVersion: String = OWSettingsWrapper.sdkVersion() ?? ""
    var hostAppVersion: String = Bundle.main.shortVersion ?? ""
    var hostAppScheme: String = Bundle.main.bundleIdentifier ?? ""
    var deviceType: String = UIDevice.modelName // TODO: where do we get it from?
    var layoutStyle: String
}
