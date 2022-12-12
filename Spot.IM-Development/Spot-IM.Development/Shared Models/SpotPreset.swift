//
//  SpotPreset.swift
//  Spot-IM.Development
//
//  Created by Revital Pisman on 11/12/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

struct SpotPreset {
    let displayName: String
    let spotId: String
    let postId: String
}

extension SpotPreset {
    static let mockModels = Self.createMockModels()
    
    static func createMockModels() -> [SpotPreset] {
    #if PUBLIC_DEMO_APP
        return []
    #else
        return [
            SpotPreset(displayName: "Demo Spot",
                       spotId: "sp_eCIlROSD",
                       postId: "sdk1"),
            
            SpotPreset(displayName: "FOX News",
                       spotId: "sp_ANQXRpqH",
                       postId: ""),
            
            SpotPreset(displayName: "mobile SSO",
                       spotId: "sp_mobileSSO",
                       postId: ""),
            
            SpotPreset(displayName: "mobile Guest",
                       spotId: "sp_mobileGuest",
                       postId: ""),
            
            SpotPreset(displayName: "mobile Social",
                       spotId: "sp_mobileSocial",
                       postId: ""),
            
            SpotPreset(displayName: "mobile Social Guest",
                       spotId: "sp_mobileSocialGuest",
                       postId: ""),
            ]
    #endif
    }
}
