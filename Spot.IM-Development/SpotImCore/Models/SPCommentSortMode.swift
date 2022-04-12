//
//  SPCommentSortMode.swift
//  Spot.IM-Core
//
//  Created by Andriy Fedin on 23/06/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation

internal enum SPCommentSortMode: String, CaseIterable, Decodable {
    
    case best
    case newest
    case oldest

    static var initial: SPCommentSortMode {
        return .best
    }

    var title: String {
        if let customTitle = getCustomSortByModeTitleIfExists() {
            return customTitle
        }
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
    
    private func getCustomSortByModeTitleIfExists() -> String? {
        switch self {
        case .best:
            return SpotIm.customSortByOptionText[.best]
        case .newest:
            return SpotIm.customSortByOptionText[.newest]
        case .oldest:
            return SpotIm.customSortByOptionText[.oldest]
        }
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
}
