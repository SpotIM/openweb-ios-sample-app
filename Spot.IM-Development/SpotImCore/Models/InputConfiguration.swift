//
//  InputConfiguration.swift
//  SpotImCore
//
//  Created by Eugene on 04.11.2019.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit

enum SupportedLanguage: String {
    case hebrew = "he"
    case english = "en"
    case arabic = "ar"
    case spanish = "es"
    case portoguese = "pt"
    case french = "fr"

    var langStringsPath: String {
        switch self {
        case .hebrew:
            return "he"
        case .english:
            return "en"
        case .arabic:
            return "ar-001"
        case .spanish:
            return "es"
        case .portoguese:
            return "pt-PT"
        case .french:
            return "fr"
        }
    }

    var isRightToLeft: Bool {
        return self == .hebrew || self == .arabic
    }

    var customSemanticAttribute: UISemanticContentAttribute {
        return isRightToLeft ? .forceRightToLeft : .forceLeftToRight
    }

}

public struct InputConfiguration {

    let language: SupportedLanguage
    let locale: Locale

    /// Please provide application language in format `en_US`, `he_IL`, etc.
    public init(appLanguage: String) {
        locale = Locale(identifier: appLanguage)
        language = SupportedLanguage(rawValue: locale.languageCode ?? "") ?? .english
    }
}
