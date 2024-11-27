//
//  OWMonetizationLayer.swift
//  OpenWebSDKAdapter
//
//  Created by Alon Shprung on 14/10/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

import Foundation

#if canImport(OpenWebIAUSDK)

@_exported import OpenWebIAUSDK

public class OWMonetizationLayer: OWMonetization {
    public var ui: OpenWebIAUSDK.OWIAUUI
    public var analytics: OpenWebIAUSDK.OWIAUAnalytics
    public var settings: OpenWebIAUSDK.OWIAUSettingsProtocol
    public var helpers: OpenWebIAUSDK.OWIAUHelpers
    
    public init(ui: OpenWebIAUSDK.OWIAUUI = OpenWebIAU.manager.ui,
                analytics: OpenWebIAUSDK.OWIAUAnalytics = OpenWebIAU.manager.analytics,
                settings: OpenWebIAUSDK.OWIAUSettingsProtocol = OpenWebIAU.manager.settings,
                helpers: OpenWebIAUSDK.OWIAUHelpers = OpenWebIAU.manager.helpers) {
        self.ui = ui
        self.analytics = analytics
        self.settings = settings
        self.helpers = helpers
    }
}

#else

public class OWMonetizationLayer: OWMonetization {
    public init() {}
}

#endif

