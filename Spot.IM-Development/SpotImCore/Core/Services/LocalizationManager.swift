//
//  LocalizationManager.swift
//  SpotImCore
//
//  Created by Eugene on 05.11.2019.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation
import UIKit

final class LocalizationManager {
    
    static private(set) var currentLanguage: SupportedLanguage?
    static private(set) var locale: Locale?
    static private var isConfigured = false
    
    static func localizedString(key: String) -> String {
        guard
            let language = currentLanguage,
            let localizationPath = Bundle.spot.path(
                forResource: language.rawValue,
                ofType: "lproj"
            ),
            let localizationBundle = Bundle(path: localizationPath)
            else { return NSLocalizedString(key, comment: "") }
        
        return localizationBundle.localizedString(forKey: key, value: "", table: nil)
    }
    
    /// Update with locale from client app config `InputConfiguration`
    static func updateLocalizationConfiguration(_ config: InputConfiguration?) {
        guard let config = config, !isConfigured else { return }
        
        isConfigured = true
        currentLanguage = config.language
        locale = config.locale
        
        UIView.appearance().semanticContentAttribute = config.language.isRightToLeft() ?
            .forceRightToLeft :
            .forceLeftToRight
    }
    
    /// Update with locale from server config
    static func setLocale(_ localeId: String?) {
        guard let localeId = localeId else { return }
        
        let config = InputConfiguration(appLanguage: localeId)
        updateLocalizationConfiguration(config)
    }
}
