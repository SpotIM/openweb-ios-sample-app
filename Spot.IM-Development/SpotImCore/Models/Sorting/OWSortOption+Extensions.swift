//
//  OWSortOption+Title.swift
//  SpotImCore
//
//  Created by Alon Haiut on 09/02/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

extension OWSortOption {
    var title: String {
        switch self {
        case .best:
            return LocalizationManager.localizedString(key:"Best")
        case .newest:
            return LocalizationManager.localizedString(key:"Newest")
        case .oldest:
            return LocalizationManager.localizedString(key:"Oldest")
        case .`default`:
            // Will never be used
            return ""
        }
    }
    
    static var validPresentationalOptions: [OWSortOption] = [.best, .newest, .oldest]
}
