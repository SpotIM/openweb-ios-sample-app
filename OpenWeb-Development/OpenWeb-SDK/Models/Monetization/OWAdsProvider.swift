//
//  OWAdsProvider.swift
//  OpenWebSDK
//
//  Created by Alon Haiut on 07/11/2022.
//  Copyright © 2022 OpenWeb. All rights reserved.
//

import Foundation

// TODO: Should be public once the new API is ready
enum OWAdsProvider {
    case none // default
    case googleAdsProvider(_ googleAds: OWGoogleAdsProvider)
}
