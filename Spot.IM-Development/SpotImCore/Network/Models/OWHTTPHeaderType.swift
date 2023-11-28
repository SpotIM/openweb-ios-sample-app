//
//  OWHTTPHeaderType.swift
//  SpotImCore
//
//  Created by Alon Haiut on 16/03/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

enum OWHTTPHeaderType: String {
    case contentType = "Content-Type"
    case userAgent = "User-Agent"
    case authorization = "Authorization"
    case spotId = "x-spot-id"
    case postId = "x-post-id"
    case platform = "x-platform"
    case platformVersion = "x-platform-version"
    case moblieGWVersion = "x-moblie-gw-version"
    case sdkVersion = "x-sdk-version"
    case appVersion = "x-app-version"
    case appScheme = "x-app-scheme"
    case pageViewId = "x-spotim-page-view-id"
    case openWebToken = "x-openweb-token"
    case guid = "x-guid"
}
