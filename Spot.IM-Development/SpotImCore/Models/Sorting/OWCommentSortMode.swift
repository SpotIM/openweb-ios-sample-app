//
//  OWCommentSortMode.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 04/01/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

enum OWCommentSortMode: String, CaseIterable, Decodable {
    
    case best
    case newest
    case oldest
    
    init(from sortByOption: OWSortOption) {
        switch sortByOption {
        case .best:
            self = .best
        case .newest:
            self = .newest
        case .oldest:
            self = .oldest
        case .default:
            // TODO: where do we save the default sort?
            self = .best
        }
    }
//    TODO: should title be here or from OWSortingCustomizer?
//    var title: String {
//        if let customTitle = getCustomSortByModeTitleIfExists() {
//            return customTitle
//        }
//        var title = ""
//        switch self {
//        case .best:
//            title = "Best"
//        case .newest:
//            title = "Newest"
//        case .oldest:
//            title = "Oldest"
//        }
//        return LocalizationManager.localizedString(key: title)
//    }
//
//    private func getCustomSortByModeTitleIfExists() -> String? {
//        switch self {
//        case .best:
//            return SpotIm.customSortByOptionText[.best]
//        case .newest:
//            return SpotIm.customSortByOptionText[.newest]
//        case .oldest:
//            return SpotIm.customSortByOptionText[.oldest]
//        }
//    }
}
