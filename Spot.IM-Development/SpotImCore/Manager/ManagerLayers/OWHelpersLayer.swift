//
//  OWHelpersInternal.swift
//  SpotImCore
//
//  Created by Alon Haiut on 20/07/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

protocol OWHelpersInternalProtocol {
    var shouldSuppressFinmbFilter: Bool { get }
}

class OWHelpersLayer: OWHelpers, OWHelpersInternalProtocol {

    fileprivate let localizationManager: OWLocalizationManagerConfigurable
    fileprivate var configurations: [OWAdditionalConfiguration] = []
    fileprivate var loggerConfigurationLayer: OWLoggerConfiguration = OWLoggerConfigurationLayer()
    fileprivate var _languageStrategy: OWLanguageStrategy = OWLanguageStrategy.default
    fileprivate var _localeStrategy: OWLocaleStrategy = OWLocaleStrategy.default

    init(localizationManager: OWLocalizationManagerConfigurable = OWLocalizationManager.shared) {
        self.localizationManager = localizationManager
    }

    var shouldSuppressFinmbFilter: Bool {
        return configurations.contains(.suppressFinmbFilter)
    }
}

// Will be public extension
extension OWHelpersLayer {
    func conversationCounters(forPostIds postIds: [OWPostId],
                              completion: OWConversationCountersCompletion) {

    }

    var additionalConfigurations: [OWAdditionalConfiguration] {
        get {
           return configurations
        }
        set(newConfigurations) {
            configurations = Array(Set(newConfigurations))
        }
    }

    var loggerConfiguration: OWLoggerConfiguration {
        return loggerConfigurationLayer
    }

    var languageStrategy: OWLanguageStrategy {
        get {
           return _languageStrategy
        }
        set(newLanguageStrategy) {
            _languageStrategy = newLanguageStrategy
            localizationManager.changeLanguage(strategy: _languageStrategy)
        }
    }

    var localeStrategy: OWLocaleStrategy {
        get {
           return _localeStrategy
        }
        set(newLocaleStrategy) {
            _localeStrategy = newLocaleStrategy
            localizationManager.changeLocale(strategy: newLocaleStrategy)
        }
    }
}
