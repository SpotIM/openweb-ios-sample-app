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
    let spotId: String
    let postId: String
    let articleUrl: String
    let pageViewId: String
    let userStatus: String
    let userId: String
    let deviceId: String
    let guid: String
    let platform: String
    let platformVersion: String
    let sdkVersion: String
    let hostAppVersion: String
    let hostAppScheme: String
    let deviceType: String
    let layoutStyle: String
}
