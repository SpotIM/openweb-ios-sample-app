//
//  OWSupportedLanguage+Extenstions.swift
//  SpotImCore
//
//  Created by Alon Haiut on 26/02/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import UIKit

extension OWSupportedLanguage {
    static var `default`: OWSupportedLanguage {
        // This will be returned as a default strategy
        return OWSupportedLanguage.english
    }

    var stringsFileSuffix: String {
        switch self {
        case .hebrew:
            return "he"
        case .english:
            return "en"
        case .arabic:
            return "ar-001"
        case .spanish:
            return "es"
        case .portuguese:
            return "pt-PT"
        case .french:
            return "fr"
        }
    }

    var semanticAttribute: UISemanticContentAttribute {
        switch self {
        case .hebrew, .arabic:
            return .forceRightToLeft
        default:
            return .forceLeftToRight
        }
    }
}
