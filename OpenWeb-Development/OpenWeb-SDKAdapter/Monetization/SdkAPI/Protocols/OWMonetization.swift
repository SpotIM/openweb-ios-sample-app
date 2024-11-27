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
    var settings: OWIAUSettingsProtocol { get set }
    var helpers: OWIAUHelpers { get }
}

#else

public protocol OWMonetization {

}

#endif
