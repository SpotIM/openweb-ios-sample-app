//
//  InputConfiguration.swift
//  SpotImCore
//
//  Created by Eugene on 04.11.2019.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation

enum SupportedLanguage: String {
    case hebrew = "he"
    case english = "en"
    
    func isRightToLeft() -> Bool {
        return self == .hebrew
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
