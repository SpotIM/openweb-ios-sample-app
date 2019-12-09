//
//  SPCommentSortMode.swift
//  Spot.IM-Core
//
//  Created by Andriy Fedin on 23/06/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation

internal enum SPCommentSortMode: String, CaseIterable, SPKebabable {
    
    case best
    case newest
    case oldest

    static var initial: SPCommentSortMode {
        return .best
    }

    var title: String {
        var title = ""
        switch self {
        case .best:
            title = "Best"
        case .newest:
            title = "Newest"
        case .oldest:
            title = "Oldest"
        }
        return LocalizationManager.localizedString(key: title)
    }

    var kebabValue: String {
        switch self {
        case .best:
            return "best"
        case .newest:
            return "newest"
        case .oldest:
            return "oldest"
        }
    }

    var backEndTitle: String {
        switch self {
        case .best:
            return "best"
        case .newest:
            return "newest"
        case .oldest:
            return "oldest"
        }
    }
    
}
