//
//  OWMonetization.swift
//  OpenWebSDKAdapter
//
//  Created by Alon Shprung on 14/10/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

import Foundation

#if canImport(OpenWebIAUSDK)

import OpenWebIAUSDK

public protocol OWMonetization {
    var ui: OWIAUUI { get }
    var analytics: OWIAUAnalytics { get }
    var helpers: OWIAUHelpers { get }
    func setSettings(_ settings: OWIAUSettingsProtocol)
}

#else

public protocol OWMonetization {}

#endif
