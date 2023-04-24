//
//  GeneralSettingsVM.swift
//  Spot-IM.Development
//
//  Created by Refael Sommer on 26/02/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift
import SpotImCore

#if NEW_API

protocol GeneralSettingsViewModelingInputs {
    var hideArticleHeaderToggled: PublishSubject<Bool> { get }
    var commentCreationNewDesignToggled: PublishSubject<Bool> { get }
    var readOnlyModeSelectedIndex: PublishSubject<Int> { get }
    var themeModeSelectedIndex: PublishSubject<Int> { get }
    var modalStyleSelectedIndex: PublishSubject<Int> { get }
    var initialSortSelectedIndex: PublishSubject<Int> { get }
    var fontGroupTypeSelectedIndex: BehaviorSubject<Int> { get }
    var customFontGroupSelectedName: BehaviorSubject<String> { get }
    var articleAssociatedSelectedURL: PublishSubject<String> { get }
    var languageStrategySelectedIndex: BehaviorSubject<Int> { get }
    var languageSelectedName: BehaviorSubject<String> { get }
    var localeStrategySelectedIndex: BehaviorSubject<Int> { get }
}

protocol GeneralSettingsViewModelingOutputs {
    var title: String { get }
    var hideArticleHeaderTitle: String { get }
    var commentCreationNewDesignTitle: String { get }
    var articleURLTitle: String { get }
    var readOnlyTitle: String { get }
    var readOnlySettings: [String] { get }
    var themeModeTitle: String { get }
    var themeModeSettings: [String] { get }
    var modalStyleTitle: String { get }
    var modalStyleSettings: [String] { get }
    var initialSortTitle: String { get }
    var fontGroupTypeTitle: String { get }
    var fontGroupTypeSettings: [String] { get }
    var initialSortSettings: [String] { get }
    var shouldHideArticleHeader: Observable<Bool> { get }
    var shouldCommentCreationNewDesign: Observable<Bool> { get }
    var readOnlyModeIndex: Observable<Int> { get }
    var themeModeIndex: Observable<Int> { get }
    var modalStyleIndex: Observable<Int> { get }
    var initialSortIndex: Observable<Int> { get }
    var fontGroupTypeIndex: Observable<Int> { get }
    var customFontGroupTypeNameTitle: String { get }
    var customFontGroupTypeName: Observable<String> { get }
    var showCustomFontName: Observable<Bool> { get }
    var articleAssociatedURL: Observable<String> { get }
    var shouldShowSetLanguage: Observable<Bool> { get }
    var supportedLanguageItems: [String] { get }
    var supportedLanguageTitle: String { get }
    var languageStrategyTitle: String { get }
    var languageStrategyIndex: Observable<Int> { get }
    var languageName: Observable<String> { get }
    var languageStrategySettings: [String] { get }

    var localeStrategyIndex: Observable<Int> { get }
    var localeStrategyTitle: String { get }
    var localeStrategySettings: [String] { get }
}

protocol GeneralSettingsViewModeling {
    var inputs: GeneralSettingsViewModelingInputs { get }
    var outputs: GeneralSettingsViewModelingOutputs { get }
}

class GeneralSettingsVM: GeneralSettingsViewModeling, GeneralSettingsViewModelingInputs, GeneralSettingsViewModelingOutputs {
    var inputs: GeneralSettingsViewModelingInputs { return self }
    var outputs: GeneralSettingsViewModelingOutputs { return self }

    var hideArticleHeaderToggled = PublishSubject<Bool>()
    var commentCreationNewDesignToggled = PublishSubject<Bool>()
    var readOnlyModeSelectedIndex = PublishSubject<Int>()
    var themeModeSelectedIndex = PublishSubject<Int>()
    var modalStyleSelectedIndex = PublishSubject<Int>()
    var initialSortSelectedIndex = PublishSubject<Int>()
    var fontGroupTypeSelectedIndex = BehaviorSubject<Int>(value: 0)
    var customFontGroupSelectedName = BehaviorSubject<String>(value: "")
    var articleAssociatedSelectedURL = PublishSubject<String>()
    var languageStrategySelectedIndex = BehaviorSubject<Int>(value: OWLanguageStrategy.defaultStrategyIndex)
    var languageSelectedName = BehaviorSubject<String>(value: OWSupportedLanguage.defaultLanguage.languageName)
    var localeStrategySelectedIndex = BehaviorSubject<Int>(value: OWLocaleStrategy.defaultLocaleIndex)

    fileprivate var userDefaultsProvider: UserDefaultsProviderProtocol
    fileprivate var manager: OWManagerProtocol

    fileprivate lazy var fontGroupTypeObservable =
    Observable.combineLatest(fontGroupTypeSelectedIndex, customFontGroupSelectedName) { index, name -> OWFontGroupFamily in
        return OWFontGroupFamily.fontGroupFamily(fromIndex: index, name: name)
    }
    .skip(2)
    .asObservable()

    fileprivate lazy var languageStrategyObservable =
    Observable.combineLatest(languageStrategySelectedIndex, languageSelectedName) { index, languageName -> OWLanguageStrategy in
        return OWLanguageStrategy.languageStrategy(fromIndex: index, language: OWSupportedLanguage(languageName: languageName))
    }
    .skip(2)
    .asObservable()

    fileprivate lazy var localeStrategyObservable =
    localeStrategySelectedIndex
        .map { index in
            return OWLocaleStrategy.localeStrategy(fromIndex: index)
        }
        .skip(1)
        .asObservable()

    var shouldHideArticleHeader: Observable<Bool> {
        return userDefaultsProvider.values(key: .hideArticleHeader, defaultValue: false)
    }

    var shouldCommentCreationNewDesign: Observable<Bool> {
        return userDefaultsProvider.values(key: .showCommentCreationNewDesign, defaultValue: false)
    }

    var readOnlyModeIndex: Observable<Int> {
        return userDefaultsProvider.values(key: .readOnlyModeIndex, defaultValue: OWReadOnlyMode.defaultIndex)
    }

    var themeModeIndex: Observable<Int> {
        return userDefaultsProvider.values(key: .themeModeIndex, defaultValue: OWThemeStyleEnforcement.defaultIndex)
    }

    var modalStyleIndex: Observable<Int> {
        return userDefaultsProvider.values(key: .modalStyleIndex, defaultValue: OWModalPresentationStyle.defaultIndex)
    }

    var initialSortIndex: Observable<Int> {
        return userDefaultsProvider.values(key: .initialSortIndex, defaultValue: OWInitialSortStrategy.defaultIndex)
    }

    var fontGroupTypeIndex: Observable<Int> {
        return userDefaultsProvider.values(key: .fontGroupType, defaultValue: OWFontGroupFamily.default)
            .map { fontGroupFamily in
                switch fontGroupFamily {
                case .`default`:
                    return 0
                case .custom(fontFamily: _):
                    return 1
                default:
                    return 0
                }
            }
            .asObservable()
    }

    var customFontGroupTypeName: Observable<String> {
        return userDefaultsProvider.values(key: .fontGroupType, defaultValue: OWFontGroupFamily.default)
            .map { fontGroupFamily in
                switch fontGroupFamily {
                case .custom(fontFamily: let fontFamily):
                    return fontFamily
                default:
                    return ""
                }
            }
            .asObservable()
    }

    var articleAssociatedURL: Observable<String> {
        return userDefaultsProvider.values(key: .articleAssociatedURL)
    }

    var showCustomFontName: Observable<Bool> {
        return userDefaultsProvider.values(key: .fontGroupType, defaultValue: OWFontGroupFamily.default)
            .map { fontGroupFamily in
                switch fontGroupFamily {
                case .custom(fontFamily: _):
                    return true
                default:
                    return false
                }
            }
            .asObservable()
    }

    var localeStrategyIndex: Observable<Int> {
        return userDefaultsProvider.values(key: .localeStrategy, defaultValue: OWLocaleStrategy.default)
            .map { localeStrategy in
                switch localeStrategy {
                case .useDevice:
                    return 0
                case .useServerConfig:
                    return 1
                default:
                    return OWLocaleStrategy.defaultLocaleIndex
                }
            }
            .asObservable()
    }

    var languageStrategyIndex: Observable<Int> {
        return userDefaultsProvider.values(key: .languageStrategy, defaultValue: OWLanguageStrategy.default)
            .map { languageStrategy in
                switch languageStrategy {
                case .useDevice:
                    return 0
                case .useServerConfig:
                    return 1
                case .use(language: _):
                    return 2
                default:
                    return OWLanguageStrategy.defaultStrategyIndex
                }
            }
            .asObservable()
    }

    var languageName: Observable<String> {
        return userDefaultsProvider.values(key: .languageStrategy, defaultValue: OWLanguageStrategy.default)
            .map { languageStrategy in
                switch languageStrategy {
                case .use(language: let language):
                    return language.languageName
                default:
                    return OWSupportedLanguage.defaultLanguage.languageName
                }
            }
            .asObservable()
    }

    var shouldShowSetLanguage: Observable<Bool> {
        return languageStrategyIndex
            .map { $0 == 2 }// Set language
            .asObservable()
    }

    fileprivate let disposeBag = DisposeBag()

    lazy var title: String = {
        return NSLocalizedString("GeneralSettings", comment: "")
    }()

    lazy var hideArticleHeaderTitle: String = {
        return NSLocalizedString("HideArticleHeader", comment: "")
    }()

    lazy var commentCreationNewDesignTitle: String = {
        return NSLocalizedString("CommentCreationNewDesign", comment: "")
    }()

    lazy var readOnlyTitle: String = {
        return NSLocalizedString("ReadOnlyMode", comment: "")
    }()

    lazy var articleURLTitle: String = {
        return NSLocalizedString("ArticleAssociatedURL", comment: "")
    }()

    lazy var readOnlySettings: [String] = {
        let _default = NSLocalizedString("Default", comment: "")
        let _enabled = NSLocalizedString("Enabled", comment: "")
        let _disabled = NSLocalizedString("Disabled", comment: "")

        return [_default, _enabled, _disabled]
    }()

    lazy var themeModeTitle: String = {
        return NSLocalizedString("ThemeMode", comment: "")
    }()

    lazy var themeModeSettings: [String] = {
        let _default = NSLocalizedString("Default", comment: "")
        let _light = NSLocalizedString("Light", comment: "")
        let _dark = NSLocalizedString("Dark", comment: "")

        return [_default, _light, _dark]
    }()

    lazy var modalStyleTitle: String = {
        return NSLocalizedString("ModalStyle", comment: "")
    }()

    lazy var modalStyleSettings: [String] = {
        let _fullScreen = NSLocalizedString("FullScreen", comment: "")
        let _pageSheet = NSLocalizedString("PageSheet", comment: "")

        return [_fullScreen, _pageSheet]
    }()

    lazy var initialSortTitle: String = {
        return NSLocalizedString("InitialSortMode", comment: "")
    }()

    lazy var initialSortSettings: [String] = {
        let _server = NSLocalizedString("Server", comment: "")
        let _best = NSLocalizedString("Best", comment: "")
        let _newest = NSLocalizedString("Newest", comment: "")
        let _oldest = NSLocalizedString("Oldest", comment: "")

        return [_server, _best, _newest, _oldest]
    }()

    lazy var fontGroupTypeTitle: String = {
        return NSLocalizedString("FontGroupType", comment: "")
    }()

    lazy var fontGroupTypeSettings: [String] = {
        let _default = NSLocalizedString("Default", comment: "")
        let _custom = NSLocalizedString("Custom", comment: "")

        return [_default, _custom]
    }()

    lazy var customFontGroupTypeNameTitle: String = {
        return NSLocalizedString("CustomFontGroupTypeName", comment: "")
    }()

    lazy var languageStrategySettings: [String] = {
            let _useDevice = NSLocalizedString("Device", comment: "")
            let _useServerConfig = NSLocalizedString("Server", comment: "")
            let _useLanguage = NSLocalizedString("SetLanguage", comment: "")
            return [_useDevice, _useServerConfig, _useLanguage]
        }()

    lazy var languageStrategyTitle: String = {
        return NSLocalizedString("LanguageStrategy", comment: "")
    }()

    lazy var localeStrategyTitle: String = {
        return NSLocalizedString("LocaleStrategy", comment: "")
    }()

    lazy var localeStrategySettings: [String] = {
            let _useDevice = NSLocalizedString("Device", comment: "")
            let _useServerConfig = NSLocalizedString("Server", comment: "")
            return [_useDevice, _useServerConfig]
        }()

    lazy var supportedLanguageTitle: String = {
        return NSLocalizedString("SupportedLanguages", comment: "")
    }()

    lazy var supportedLanguageItems: [String] = {
        return OWSupportedLanguage.allCases.map { $0.languageName }
    }()

    init(userDefaultsProvider: UserDefaultsProviderProtocol = UserDefaultsProvider.shared,
         manager: OWManagerProtocol = OpenWeb.manager) {
        self.userDefaultsProvider = userDefaultsProvider
        self.manager = manager
        setupObservers()
    }
}

extension GeneralSettingsVM {
    func setupObservers() {
        hideArticleHeaderToggled
            .skip(1)
            .bind(to: userDefaultsProvider.rxProtocol
            .setValues(key: UserDefaultsProvider.UDKey<Bool>.hideArticleHeader))
            .disposed(by: disposeBag)

        commentCreationNewDesignToggled
            .skip(1)
            .bind(to: userDefaultsProvider.rxProtocol
            .setValues(key: UserDefaultsProvider.UDKey<Bool>.showCommentCreationNewDesign))
            .disposed(by: disposeBag)

        readOnlyModeSelectedIndex
            .skip(1)
            .bind(to: userDefaultsProvider.rxProtocol
            .setValues(key: UserDefaultsProvider.UDKey<Int>.readOnlyModeIndex))
            .disposed(by: disposeBag)

        themeModeSelectedIndex
            .skip(1)
            .bind(to: userDefaultsProvider.rxProtocol
            .setValues(key: UserDefaultsProvider.UDKey<Int>.themeModeIndex))
            .disposed(by: disposeBag)

        modalStyleSelectedIndex
            .skip(1)
            .bind(to: userDefaultsProvider.rxProtocol
            .setValues(key: UserDefaultsProvider.UDKey<Int>.modalStyleIndex))
            .disposed(by: disposeBag)

        initialSortSelectedIndex
            .skip(1)
            .bind(to: userDefaultsProvider.rxProtocol
            .setValues(key: UserDefaultsProvider.UDKey<Int>.initialSortIndex))
            .disposed(by: disposeBag)

        fontGroupTypeObservable
            .map { $0 }
            .bind(to: userDefaultsProvider.rxProtocol
            .setValues(key: UserDefaultsProvider.UDKey<OWFontGroupFamily>.fontGroupType))
            .disposed(by: disposeBag)

        articleAssociatedSelectedURL
            .skip(1)
            .bind(to: userDefaultsProvider.rxProtocol
            .setValues(key: UserDefaultsProvider.UDKey<String?>.articleAssociatedURL))
            .disposed(by: disposeBag)

        themeModeSelectedIndex // 0. default 1. light 2. dark
            .subscribe(onNext: { [weak self] index in
                guard let self = self else { return }
                var customizations = self.manager.ui.customizations
                customizations.themeEnforcement = .themeStyle(fromIndex: index)
            })
            .disposed(by: disposeBag)

        fontGroupTypeObservable
            .subscribe(onNext: { [weak self] fontGroupType in
                guard let self = self else { return }
                var customizations = self.manager.ui.customizations
                customizations.fontFamily = fontGroupType
            })
            .disposed(by: disposeBag)

        languageStrategyObservable
            .bind(to: userDefaultsProvider.rxProtocol
            .setValues(key: UserDefaultsProvider.UDKey<OWLanguageStrategy>.languageStrategy))
            .disposed(by: disposeBag)

        localeStrategyObservable
            .bind(to: userDefaultsProvider.rxProtocol
                .setValues(key: UserDefaultsProvider.UDKey<OWLocaleStrategy>.localeStrategy))
            .disposed(by: disposeBag)
    }
}

extension GeneralSettingsVM: SettingsGroupVMProtocol {

}

#endif
