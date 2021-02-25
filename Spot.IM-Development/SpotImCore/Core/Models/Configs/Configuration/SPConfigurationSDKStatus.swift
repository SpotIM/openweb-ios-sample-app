//
//  SPConfigurationSDKStatus.swift
//  Spot.IM-Core
//
//  Created by Eugene on 8/29/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation

struct SPConfigurationSDKStatus: Decodable {
    let enabled: Bool?
    let locale: String?
    let realtimeEnabled: Bool?
    let loginUiEnabled: Bool?
    let disableInterstitialOnLogin: Bool?
    let openwebWebsiteUrl: String
    let openwebPrivacyUrl: String
    let openwebTermsUrl: String
    let googleAdsProviderRequired: Bool?
    let disableAdsForSubscribers: Bool?
}
