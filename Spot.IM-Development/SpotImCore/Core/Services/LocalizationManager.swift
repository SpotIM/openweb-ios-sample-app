//
//  LocalizationManager.swift
//  SpotImCore
//
//  Created by Eugene on 05.11.2019.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation

final class LocalizationManager {
    
    static var currentLanguage: SupportedLanguage = .english
    static var locale: Locale = Locale.current
    
    static func localizedString(key: String) -> String {
        guard
            let localizationPath = Bundle.spot.path(
                forResource: currentLanguage.rawValue,
                ofType: "lproj"
            ),
            let localizationBundle = Bundle(path: localizationPath)
            else { return NSLocalizedString(key, comment: "") }
        
        return localizationBundle.localizedString(forKey: key, value: "", table: nil)
    }
}
