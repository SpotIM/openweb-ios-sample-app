//
//  OWSupportedLanguage+Extensions.swift
//  OpenWeb-Development
//
//  Created by Refael Sommer on 01/03/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation
import OpenWebSDK

extension OWSupportedLanguage {
    static var defaultLanguage: OWSupportedLanguage {
        .english
    }

    var languageName: String {
        switch self {
        case .hebrew:
            return "Hebrew"
        case .english:
            return "English"
        case .arabic:
            return "Arabic"
        case .spanish:
            return "Spanish"
        case .portuguese:
            return "Portoguese"
        case .french:
            return "French"
        case .dutch:
            return "Dutch"
        default:
            return "English"
        }
    }

    init(languageName: String) {
        switch languageName {
        case OWSupportedLanguage.hebrew.languageName:
            self = OWSupportedLanguage.hebrew
        case OWSupportedLanguage.english.languageName:
            self = OWSupportedLanguage.english
        case OWSupportedLanguage.arabic.languageName:
            self = OWSupportedLanguage.arabic
        case OWSupportedLanguage.spanish.languageName:
            self = OWSupportedLanguage.spanish
        case OWSupportedLanguage.portuguese.languageName:
            self = OWSupportedLanguage.portuguese
        case OWSupportedLanguage.french.languageName:
            self = OWSupportedLanguage.french
        case OWSupportedLanguage.dutch.languageName:
            self = OWSupportedLanguage.dutch
        default:
            self = OWSupportedLanguage.english
        }
    }

    enum CodingKeys: String, CodingKey {
        case hebrew
        case english
        case arabic
        case spanish
        case portuguese
        case french
        case dutch
    }
}
