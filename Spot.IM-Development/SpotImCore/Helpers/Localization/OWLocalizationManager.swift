//
//  OWLocalizationManager.swift
//  SpotImCore
//
//  Created by Alon Haiut on 26/02/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

protocol OWLocalizationManagerProtocol {
    func localizedString(key: String) -> String
    var locale: Locale { get }
    var semanticAttribute: UISemanticContentAttribute { get }
    var textAlignment: NSTextAlignment { get }
}

protocol OWLocalizationManagerConfigurable {
    func configure(forSpotId spotId: OWSpotId)
    func changeLanguage(strategy: OWLanguageStrategy)
    func changeLocale(strategy: OWLocaleStrategy)
}

class OWLocalizationManager: OWLocalizationManagerProtocol, OWLocalizationManagerConfigurable {

    fileprivate struct Metrics {
        static let defaultLocaleIdentifier: String = "en-US"
        static let localizationFileType: String = "lproj"
    }

    static let shared: OWLocalizationManagerProtocol & OWLocalizationManagerConfigurable = OWLocalizationManager()

    fileprivate unowned let servicesProvider: OWSharedServicesProviding
    fileprivate let disposeBag = DisposeBag()

    fileprivate var spotId: OWSpotId? = nil
    fileprivate var _locale = Locale(identifier: Metrics.defaultLocaleIdentifier)
    fileprivate var localizationBundle: Bundle? = nil

    fileprivate let _languageStrategy = BehaviorSubject<OWLanguageStrategy>(value: OWLanguageStrategy.default)
    fileprivate var languageStrategy: Observable<OWLanguageStrategy> {
        return _languageStrategy
            .distinctUntilChanged()
    }

    fileprivate let _localeStrategy = BehaviorSubject<OWLocaleStrategy>(value: OWLocaleStrategy.default)
    fileprivate var localeStrategy: Observable<OWLocaleStrategy> {
        return _localeStrategy
            .distinctUntilChanged()
    }

    fileprivate var _currentLanguageNonRx: OWSupportedLanguage = OWSupportedLanguage.default
    fileprivate let _currentLanguage = BehaviorSubject<OWSupportedLanguage?>(value: nil)
    fileprivate var currentLanguage: Observable<OWSupportedLanguage> {
        return _currentLanguage
            .unwrap()
    }

    fileprivate let _currentLocale = BehaviorSubject<Locale?>(value: nil)
    fileprivate var currentLocale: Observable<Locale> {
        return _currentLocale
            .unwrap()
    }

    private init(servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.servicesProvider = servicesProvider
        setupObservers()
    }

    func changeLanguage(strategy: OWLanguageStrategy) {
        _languageStrategy.onNext(strategy)
    }

    func changeLocale(strategy: OWLocaleStrategy) {
        _localeStrategy.onNext(strategy)
    }

    func configure(forSpotId spotId: OWSpotId) {
        self.spotId = spotId
        _ = dictateLanguage(forSpotId: spotId)
            .take(1)
            .do(onNext: { [weak self] language in
                self?._currentLanguage.onNext(language)
            })
            .flatMap { [weak self] _ -> Observable<Locale> in
                return self?.dictateLocale(forSpotId: spotId) ?? .empty()
            }
            .take(1)
            .do(onNext: { [weak self] locale in
                self?._currentLocale.onNext(locale)
            })
            .subscribe()
    }

    func localizedString(key: String) -> String {
        guard let localizationBundle = self.localizationBundle else {
            return NSLocalizedString(key, comment: "")
        }

        return localizationBundle.localizedString(forKey: key, value: "", table: nil)
    }

    var locale: Locale {
        return _locale
    }

    var semanticAttribute: UISemanticContentAttribute {
        return _currentLanguageNonRx.semanticAttribute
    }
    
    var textAlignment: NSTextAlignment {
        switch semanticAttribute {
        case .forceLeftToRight:
            return .left
        case .forceRightToLeft:
            return .right
        default:
            return .natural
        }
    }
}

fileprivate extension OWLocalizationManager {
    func setupObservers() {
        languageStrategy
            .distinctUntilChanged()
            .flatMap { [weak self] _ -> Observable<OWSupportedLanguage> in
                /*
                 Guard will prevent us from immediately trying to dictate the language.
                 This way we allow changing the strategy before or after the `spotId` setup from `OpenWeb.Manager.spotId`
                 */
                guard let self = self,
                      let spotId = self.spotId,
                      spotId == OpenWeb.manager.spotId else { return .empty() }

                return self.dictateLanguage(forSpotId: spotId)
            }
            .subscribe(onNext: { [weak self] language in
                self?._currentLanguage.onNext(language)
            })
            .disposed(by: disposeBag)

        localeStrategy
            .distinctUntilChanged()
            .flatMap { [weak self] _ -> Observable<Locale> in
                /*
                 Guard will prevent us from immediately trying to dictate the locale.
                 This way we allow changing the strategy before or after the `spotId` setup from `OpenWeb.Manager.spotId`
                 */
                guard let self = self,
                      let spotId = self.spotId,
                      spotId == OpenWeb.manager.spotId else { return .empty() }

                return self.dictateLocale(forSpotId: spotId)
            }
            .subscribe(onNext: { [weak self] locale in
                self?._currentLocale.onNext(locale)
            })
            .disposed(by: disposeBag)

        currentLanguage
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] language in
                self?.configure(language: language)
            })
            .disposed(by: disposeBag)

        currentLocale
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] locale in
                self?.configure(locale: locale)
            })
            .disposed(by: disposeBag)
    }

    func dictateLanguage(forSpotId spotId: OWSpotId) -> Observable<OWSupportedLanguage> {
        // 1. Getting locale according to server config
        return servicesProvider.spotConfigurationService()
            .config(spotId: spotId)
            .map { $0.mobileSdk.locale ?? Metrics.defaultLocaleIdentifier }
            .flatMap { [weak self] serverLocaleIdentifier -> Observable<(OWLanguageStrategy, String)> in
                // 2. Take into account language strategy
                guard let self = self else { return .empty() }
                return self.languageStrategy
                    .take(1)
                    .map { ($0, serverLocaleIdentifier) }
            }
            .flatMap { touple -> Observable<OWSupportedLanguage> in
                // 3. Returning the supported language to use according to the desired strategy
                let strategy = touple.0
                let serverLocaleIdentifier = touple.1
                let supportedLanguage: OWSupportedLanguage

                switch strategy {
                case .useServerConfig:
                    // Server config locale expected to be in the following format `en_US`, `he_IL`, etc.
                    let serverLocale = Locale(identifier: serverLocaleIdentifier)
                    let languageCode = serverLocale.languageCode ?? OWSupportedLanguage.english.rawValue
                    supportedLanguage = OWSupportedLanguage(rawValue: languageCode) ?? OWSupportedLanguage.english
                case .useDevice:
                    if let languageCode = Locale.current.languageCode,
                       let language = OWSupportedLanguage(rawValue: languageCode) {
                        supportedLanguage = language
                    } else {
                        supportedLanguage = OWSupportedLanguage.english
                    }
                case .use(language: let language):
                    supportedLanguage = language
                }

                return .just(supportedLanguage)
            }
    }

    // This function will only finish after the `currentLanguage` variable have been set
    func dictateLocale(forSpotId spotId: OWSpotId) -> Observable<Locale> {
        // 1. Getting locale according to server config
        return servicesProvider.spotConfigurationService()
            .config(spotId: spotId)
            .map { $0.mobileSdk.locale ?? Metrics.defaultLocaleIdentifier }
            .flatMap { [weak self] serverLocaleIdentifier -> Observable<(OWLocaleStrategy, String)> in
                // 2. Take into account language strategy
                guard let self = self else { return .empty() }
                return self.localeStrategy
                    .take(1)
                    .map { ($0, serverLocaleIdentifier) }
            }
            .flatMap { touple -> Observable<Locale> in
                // 3. Returning the supported language to use according to the desired strategy
                let strategy = touple.0
                let serverLocaleIdentifier = touple.1
                let locale: Locale

                switch strategy {
                case .useServerConfig:
                    // Server config locale expected to be in the following format `en_US`, `he_IL`, etc.
                    if Locale.availableIdentifiers.contains(serverLocaleIdentifier) {
                        locale = Locale(identifier: serverLocaleIdentifier)
                    } else {
                        locale = Locale(identifier: Metrics.defaultLocaleIdentifier)
                    }
                case .useDevice:
                    locale = Locale.current
                case .use(locale: let localeToUse):
                    locale = localeToUse
                }

                return .just(locale)
            }
    }

    func configure(language: OWSupportedLanguage) {
        _currentLanguageNonRx = language

        guard let localizationFilePath = Bundle.openWeb.path(forResource: language.stringsFileSuffix,
                                                             ofType: Metrics.localizationFileType),
              let localizationBundle = Bundle(path: localizationFilePath) else {
            self.localizationBundle = nil
            return
        }

        self.localizationBundle = localizationBundle
    }

    func configure(locale: Locale) {
        _locale = locale
    }
}
