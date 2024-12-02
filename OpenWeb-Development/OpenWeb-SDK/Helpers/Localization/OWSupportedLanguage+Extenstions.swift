//
//  OWSupportedLanguage+Extenstions.swift
//  OpenWebSDK
//
//  Created by Alon Haiut on 26/02/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
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
        case .portuguesePortugal:
            return "pt-PT"
        case .french:
            return "fr"
        case .dutch:
            return "nl"
        case .german:
            return "de"
        case .hungarian:
            return "hu"
        case .indonesian:
            return "id"
        case .italian:
            return "it"
        case .japanese:
            return "ja"
        case .korean:
            return "ko"
        case .portugueseBrazil:
            return "pt-BR"
        case .portugueseOther:
            return "pt"
        case .thai:
            return "th"
        case .turkish:
            return "tr"
        case .vietnamese:
            return "vi"
        }
    }

    var userBadgeCode: String {
        switch self {
        case .spanish:
            return "es-ES"
        default:
            return self.rawValue
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
