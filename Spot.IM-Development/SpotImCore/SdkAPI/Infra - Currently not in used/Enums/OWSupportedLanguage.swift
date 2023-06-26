//
//  OWSupportedLanguage.swift
//  SpotImCore
//
//  Created by Alon Haiut on 26/02/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public enum OWSupportedLanguage: String, Codable, CaseIterable {
    case hebrew = "he"
    case english = "en"
    case arabic = "ar"
    case spanish = "es"
    case portuguese = "pt"
    case french = "fr"

    var userBadgeCode: String {
        switch self {
        case .spanish:
            return "es-ES"
        default:
            return self.rawValue
        }
    }
}
#else
enum OWSupportedLanguage: String, Codable, CaseIterable {
    case hebrew = "he"
    case english = "en"
    case arabic = "ar"
    case spanish = "es"
    case portuguese = "pt"
    case french = "fr"

    var userBadgeCode: String {
        switch self {
        case .spanish:
            return "es-ES"
        default:
            return self.rawValue
        }
    }
}
#endif
