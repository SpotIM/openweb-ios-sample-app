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
            return LocalizationManager.localizedString(key: "Best")
        case .newest:
            return LocalizationManager.localizedString(key: "Newest")
        case .oldest:
            return LocalizationManager.localizedString(key: "Oldest")
        }
    }

    static var `default`: OWSortOption {
        // This will be returned as a default sort option
        return OWSortOption.best
    }

    // TODO: Remove once we will remove old `SPCommentSortMode` class
    init(fromOldSortType oldSortType: SPCommentSortMode) {
        switch oldSortType {
        case .best:
            self = .best
        case .newest:
            self = .newest
        case .oldest:
            self = .oldest
        }
    }
}
