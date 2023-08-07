//
//  OWCommunityQuestionsStyle+Extensions.swift
//  Spot-IM.Development
//
//  Created by Refael Sommer on 23/03/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import SpotImCore

#if NEW_API

extension OWCommunityQuestionStyle {
    init(index: Int) {
        switch index {
        case OWCommunityQuestionStyle.none.index: self = .none
        case OWCommunityQuestionStyle.regular.index: self = .regular
        case OWCommunityQuestionStyle.compact.index: self = .compact
        default:
            self = .none
        }
    }

    static var `default`: OWCommunityQuestionStyle {
        return .regular
    }

    enum CodingKeys: String, CodingKey {
        case none
        case regular
        case compact
    }

    var index: Int {
        switch self {
        case .none: return 0
        case .regular: return 1
        case .compact: return 2
        default: return OWCommunityQuestionStyle.`default`.index
        }
    }
}

#endif
