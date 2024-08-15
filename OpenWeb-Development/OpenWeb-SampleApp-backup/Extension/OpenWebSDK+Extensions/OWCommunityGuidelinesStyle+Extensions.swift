//
//  OWCommunityGuidelinesStyle+Extensions.swift
//  OpenWeb-Development
//
//  Created by Refael Sommer on 23/03/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation
import OpenWebSDK

extension OWCommunityGuidelinesStyle {
    init(index: Int) {
        switch index {
        case OWCommunityGuidelinesStyle.none.index: self = .none
        case OWCommunityGuidelinesStyle.regular.index: self = .regular
        case OWCommunityGuidelinesStyle.compact.index: self = .compact
        default:
            self = .none
        }
    }

    static var `default`: OWCommunityGuidelinesStyle {
        return .regular
    }

    var index: Int {
        switch self {
        case .none: return 0
        case .regular: return 1
        case .compact: return 2
        default: return OWCommunityQuestionStyle.`default`.index
        }
    }

    enum CodingKeys: String, CodingKey {
        case none
        case regular
        case compact
    }
}
