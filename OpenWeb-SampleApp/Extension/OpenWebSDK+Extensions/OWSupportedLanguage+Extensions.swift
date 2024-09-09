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
        case .portuguesePortugal:
            return "Portoguese (Portugal)"
        case .portugueseBrazil:
            return "Portoguese (Brazil)"
        case .french:
            return "French"
        case .dutch:
            return "Dutch"
        case .german:
            return "German"
        case .hungarian:
            return "Hungarian"
        case .indonesian:
            return "Indonesian"
        case .italian:
            return "Italian"
        case .japanese:
            return "Japanese"
        case .korean:
            return "Korean"
        case .thai:
            return "Thai"
        case .turkish:
            return "Turkish"
        case .vietnamese:
            return "Vietnamese"
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
        case OWSupportedLanguage.french.languageName:
            self = OWSupportedLanguage.french
        case OWSupportedLanguage.dutch.languageName:
            self = OWSupportedLanguage.dutch
        case OWSupportedLanguage.german.languageName:
            self = OWSupportedLanguage.german
        case OWSupportedLanguage.hungarian.languageName:
            self = OWSupportedLanguage.hungarian
        case OWSupportedLanguage.indonesian.languageName:
            self = OWSupportedLanguage.indonesian
        case OWSupportedLanguage.italian.languageName:
            self = OWSupportedLanguage.italian
        case OWSupportedLanguage.japanese.languageName:
            self = OWSupportedLanguage.japanese
        case OWSupportedLanguage.korean.languageName:
            self = OWSupportedLanguage.korean
        case OWSupportedLanguage.portugueseBrazil.languageName:
            self = OWSupportedLanguage.portugueseBrazil
        case OWSupportedLanguage.portuguesePortugal.languageName:
            self = OWSupportedLanguage.portuguesePortugal
        case OWSupportedLanguage.thai.languageName:
            self = OWSupportedLanguage.thai
        case OWSupportedLanguage.turkish.languageName:
            self = OWSupportedLanguage.turkish
        case OWSupportedLanguage.vietnamese.languageName:
            self = OWSupportedLanguage.vietnamese
        default:
            self = OWSupportedLanguage.english
        }
    }

    enum CodingKeys: String, CodingKey {
        case hebrew
        case english
        case arabic
        case spanish
        case french
        case dutch
        case german
        case hungarian
        case indonesian
        case italian
        case japanese
        case korean
        case portugueseBrazil
        case portuguesePortugal
        case thai
        case turkish
        case vietnamese
    }
}
