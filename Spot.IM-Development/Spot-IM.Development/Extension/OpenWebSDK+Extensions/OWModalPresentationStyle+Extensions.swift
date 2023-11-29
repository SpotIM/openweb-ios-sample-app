//
//  OWModalPresentationStyle+Extensions.swift
//  Spot-IM.Development
//
//  Created by Refael Sommer on 23/01/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import SpotImCore

extension OWModalPresentationStyle {
    static func presentationStyle(fromIndex index: Int) -> OWModalPresentationStyle {
        switch index {
        case OWModalPresentationStyle.fullScreen.index: return .fullScreen
        case OWModalPresentationStyle.pageSheet.index: return .pageSheet
        default: return `default`
        }
    }

    static var `default`: OWModalPresentationStyle {
        return .fullScreen
    }

    var index: Int {
        switch self {
        case .fullScreen: return 0
        case .pageSheet: return 1
        default: return OWModalPresentationStyle.`default`.index
        }
    }
}
