//
//  OWMonetizationLayer.swift
//  OpenWebSDKAdapter
//
//  Created by Alon Shprung on 14/10/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

import Foundation

public protocol OWMonetizationInternalProtocol {
    func setSpotId(_ spotId: String)
}

#if canImport(OpenWebIAUSDK)

@_exported import OpenWebIAUSDK
public class OWMonetizationLayer: OWMonetization {
    public var ui: OpenWebIAUSDK.OWIAUUI
    public var analytics: OpenWebIAUSDK.OWIAUAnalytics
    public var helpers: OpenWebIAUSDK.OWIAUHelpers
    var manager = OpenWebIAU.manager
    
    public init() {
        self.ui = manager.ui
        self.analytics = manager.analytics
        self.helpers = manager.helpers
    }
  
    public func setSettings(_ settings: OWIAUSettingsProtocol) {
        manager.settings = settings
    }
}

extension OWMonetizationLayer: OWMonetizationInternalProtocol {
    public func setSpotId(_ spotId: OWIAUSpotId) {
        manager.spotId = spotId
    }
}

#else

public class OWMonetizationLayer: OWMonetization, OWMonetizationInternalProtocol {
    public init() {}
    
    public func setSpotId(_ spotId: String) {}
}

#endif

