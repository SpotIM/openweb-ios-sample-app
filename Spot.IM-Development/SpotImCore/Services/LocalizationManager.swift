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
            let localizationPath = Bundle.openWeb.path(
                forResource: language.langStringsPath,
                ofType: "lproj"
            ),
            let localizationBundle = Bundle(path: localizationPath)
            else { return NSLocalizedString(key, comment: "") }

        return localizationBundle.localizedString(forKey: key, value: "", table: nil)
    }

    static func getTextAlignment() -> NSTextAlignment {
        guard let isRTL = currentLanguage?.isRightToLeft else {
            return .natural
        }

        return isRTL ? .right : .left
    }

    /// Update with locale from client app config `InputConfiguration`
    static func updateLocalizationConfiguration(_ config: InputConfiguration) {
        guard !isConfigured else { return }

        isConfigured = true
        currentLanguage = config.language
        locale = config.locale
    }

    /// Update with locale from server config
    static func setLocale(_ localeId: String) {
        let config = InputConfiguration(appLanguage: localeId)
        updateLocalizationConfiguration(config)
    }

    static func reset() {
        isConfigured = false
        let config = InputConfiguration(appLanguage: "en")
        currentLanguage = config.language
        locale = config.locale
    }

    static func getLanguageCode() -> String {
        let currentLanguage = self.currentLanguage ?? SupportedLanguage.english
        return currentLanguage.rawValue
    }
}
