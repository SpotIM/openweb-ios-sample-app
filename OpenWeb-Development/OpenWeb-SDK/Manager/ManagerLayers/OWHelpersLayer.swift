//
//  OWHelpersInternal.swift
//  OpenWebSDK
//
//  Created by Alon Haiut on 20/07/2022.
//  Copyright © 2022 OpenWeb. All rights reserved.
//

import Foundation

protocol OWHelpersInternalProtocol {
    var shouldSuppressFinmbFilter: Bool { get }
}

class OWHelpersLayer: OWHelpers, OWHelpersInternalProtocol {

    private let localizationManager: OWLocalizationManagerConfigurable
    private var configurations: [OWAdditionalConfiguration] = []
    private var loggerConfigurationLayer: OWLoggerConfiguration = OWLoggerConfigurationLayer()
    private var _languageStrategy: OWLanguageStrategy = OWLanguageStrategy.default
    private var _localeStrategy: OWLocaleStrategy = OWLocaleStrategy.default
    private var _orientationEnforcement: OWOrientationEnforcement = OWOrientationEnforcement.enableAll
    private let sharedServicesProvider: OWSharedServicesProviding

    init(localizationManager: OWLocalizationManagerConfigurable = OWLocalizationManager.shared,
         sharedServicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.localizationManager = localizationManager
        self.sharedServicesProvider = sharedServicesProvider
    }

    var shouldSuppressFinmbFilter: Bool {
        return configurations.contains(.suppressFinmbFilter)
    }
}

// Will be public extension
extension OWHelpersLayer {
    func conversationCounters(forPostIds postIds: [OWPostId],
                              completion: @escaping OWConversationCountersCompletion) {
        guard validateSpotIdExist(completion: completion) else { return }

        _ = sharedServicesProvider.networkAPI()
            .conversation
            .commentsCounters(conversationIds: postIds)
            .response
            .take(1)
            .subscribe(onNext: { res in
                let counts: [String: OWConversationCounter] = Dictionary(uniqueKeysWithValues: res.counts.map { key, value in
                    (key.decoded, value)
                })
                completion(.success(counts))
            },
            onError: { _ in
                completion(.failure(OWError.conversationCounters))
            })
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
            sendEvent(for: .configureLanguageStrategy(strategy: newLanguageStrategy))
        }
    }

    var localeStrategy: OWLocaleStrategy {
        get {
           return _localeStrategy
        }
        set(newLocaleStrategy) {
            _localeStrategy = newLocaleStrategy
            localizationManager.changeLocale(strategy: newLocaleStrategy)
            sendEvent(for: .localeStrategy(strategy: newLocaleStrategy))
        }
    }

    var orientationEnforcement: OWOrientationEnforcement {
        get {
            return _orientationEnforcement
        }
        set(newOrientationEnforcement) {
            _orientationEnforcement = newOrientationEnforcement
            sendEvent(for: .orientationEnforcement(enforcement: newOrientationEnforcement))
        }
    }
}

private extension OWHelpersLayer {
    func validateSpotIdExist<T: Any>(completion: @escaping (Result<T, OWError>) -> Void) -> Bool {
        let spotId = OpenWeb.manager.spotId
        guard !spotId.isEmpty else {
            completion(.failure(.missingSpotId))
            return false
        }

        return true
    }

    func event(for eventType: OWAnalyticEventType) -> OWAnalyticEvent {
        return sharedServicesProvider
            .analyticsEventCreatorService()
            .analyticEvent(
                for: eventType,
                articleUrl: "",
                layoutStyle: .none,
                component: .none)
    }

    func sendEvent(for eventType: OWAnalyticEventType) {
        let event = event(for: eventType)
        sharedServicesProvider
            .analyticsService()
            .sendAnalyticEvents(events: [event])
    }
}
