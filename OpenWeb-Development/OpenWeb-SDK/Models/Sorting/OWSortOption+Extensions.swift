//
//  OWSortOption+Title.swift
//  OpenWebSDK
//
//  Created by Alon Haiut on 09/02/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation

extension OWSortOption {
    var title: String {
        switch self {
        case .best:
            return OWLocalize.string("Best")
        case .newest:
            return OWLocalize.string("Newest")
        case .oldest:
            return OWLocalize.string("Oldest")
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
