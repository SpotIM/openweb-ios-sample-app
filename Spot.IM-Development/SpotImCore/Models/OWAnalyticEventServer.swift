//
//  OWAnalyticEventServer.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 12/07/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

struct OWAnalyticEventServer: Decodable {
    var eventName: String
    var eventGroup: String
    var eventTimestamp: TimeInterval
    var productName: String = "conversation"
    var componentName: String
//    var payload: Any // TODO: maybe some protocol
    var generalData: OWAnalyticEventServerGeneralData
    var abTests: OWAnalyticEventServerAbTest
}

struct OWAnalyticEventServerGeneralData: Decodable {
    var spotId: String
    var postId: String
    var articleUrl: String // TODO: string or URL?
    var pageViewId: String
    var userStatus: String
    var userId: String // in case user is connected
    var deviceId: String
    var guid: String
    var platform: String = "ios_phone"
    var platformVersion: String
    var sdkVersion: String
    var hostAppVersion: String
    var hostAppScheme: String
    var deviceType: String
    var layoutStyle: String
//    var ip: String
}

struct OWAnalyticEventServerAbTest: Decodable {
    var selectedTests: [Dictionary<String, String>] = []
    var affectiveTests: [Dictionary<String, String>] = []
}
