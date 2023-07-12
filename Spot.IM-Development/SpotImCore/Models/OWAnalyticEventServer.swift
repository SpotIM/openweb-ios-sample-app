//
//  OWAnalyticEventServer.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 12/07/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import UIKit

struct OWAnalyticEventServer: Decodable {
    var eventName: String
    var eventGroup: String
    var eventTimestamp: String
    var productName: String = "conversation"
    var componentName: String
//    var payload: Any // TODO: maybe some protocol
    var generalData: OWAnalyticEventServerGeneralData
    var abTests: OWAnalyticEventServerAbTest = OWAnalyticEventServerAbTest()
}

struct OWAnalyticEventServerGeneralData: Decodable {
    var spotId: String = OWManager.manager.spotId
    var postId: String = OWManager.manager.postId ?? ""
    var articleUrl: String // TODO: string or URL?
    var pageViewId: String = "" // TODO: add to analyticsService?
    var userStatus: String
    var userId: String // in case user is connected
    var deviceId: String = UIDevice.current.identifierForVendor?.uuidString ?? ""
    var guid: String
    var platform: String = "ios_phone"
    var platformVersion: String = UIDevice.current.systemVersion
    var sdkVersion: String = OWSettingsWrapper.sdkVersion() ?? ""
    var hostAppVersion: String = Bundle.main.shortVersion ?? ""
    var hostAppScheme: String = Bundle.main.bundleIdentifier ?? ""
    var deviceType: String = "" // TODO: where do we get it from?
    var layoutStyle: String
}

struct OWAnalyticEventServerAbTest: Decodable {
    var selectedTests: [Dictionary<String, String>] = []
    var affectiveTests: [Dictionary<String, String>] = []
}
