//
//  GeneralSettingsVM.swift
//  OpenWeb-Development
//
//  Created by Refael Sommer on 26/02/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import OpenWebSDK

protocol GeneralSettingsViewModelingInputs {
    var articleHeaderSelectedStyle: BehaviorSubject<OWArticleHeaderStyle> { get }
    var articleInformationSelectedStrategy: BehaviorSubject<OWArticleInformationStrategy> { get }
    var orientationSelectedEnforcement: BehaviorSubject<OWOrientationEnforcement> { get }
    var elementsCustomizationStyleSelectedIndex: PublishSubject<Int> { get }
    var colorsCustomizationStyleSelectedIndex: PublishSubject<Int> { get }
    var readOnlyModeSelectedIndex: PublishSubject<Int> { get }
    var themeModeSelectedIndex: PublishSubject<Int> { get }
    var statusBarStyleSelectedIndex: PublishSubject<Int> { get }
    var navigationBarStyleSelectedIndex: PublishSubject<Int> { get }
    var modalStyleSelectedIndex: PublishSubject<Int> { get }
    var initialSortSelectedIndex: PublishSubject<Int> { get }
    var customSortTitlesChanged: PublishSubject<[OWSortOption: String]> { get }
    var fontGroupTypeSelectedIndex: BehaviorSubject<Int> { get }
    var customFontGroupSelectedName: BehaviorSubject<String> { get }
    var articleAssociatedSelectedURL: PublishSubject<String> { get }
    var articleSelectedSection: PublishSubject<String> { get }
    var languageStrategySelectedIndex: BehaviorSubject<Int> { get }
    var languageSelectedName: BehaviorSubject<String> { get }
    var localeStrategySelectedIndex: BehaviorSubject<Int> { get }
    var showLoginPromptSelected: BehaviorSubject<Bool> { get }
    var openColorsCustomizationClicked: PublishSubject<Void> { get }
    var commentActionsColorSelected: BehaviorSubject<OWCommentActionsColor> { get }
    var commentActionsFontStyleSelected: BehaviorSubject<OWCommentActionsFontStyle> { get }
}

protocol GeneralSettingsViewModelingOutputs {
    var title: String { get }
    var articleURLTitle: String { get }
    var articleSectionTitle: String { get }
    var readOnlyTitle: String { get }
    var readOnlySettings: [String] { get }
    var themeModeTitle: String { get }
    var themeModeSettings: [String] { get }
    var statusBarStyleTitle: String { get }
    var statusBarStyleSettings: [String] { get }
    var navigationBarStyleTitle: String { get }
    var navigationBarStyleSettings: [String] { get }
    var modalStyleTitle: String { get }
    var modalStyleSettings: [String] { get }
    var initialSortTitle: String { get }
    var fontGroupTypeTitle: String { get }
    var fontGroupTypeSettings: [String] { get }
    var initialSortSettings: [String] { get }
    var elementsCustomizationStyleIndex: Observable<Int> { get }
    var colorsCustomizationStyleIndex: Observable<Int> { get }
    var readOnlyModeIndex: Observable<Int> { get }
    var themeModeIndex: Observable<Int> { get }
    var statusBarStyleIndex: Observable<Int> { get }
    var navigationBarStyleIndex: Observable<Int> { get }
    var modalStyleIndex: Observable<Int> { get }
    var initialSortIndex: Observable<Int> { get }
    var customSortTitles: Observable<[OWSortOption: String]> { get }
    var fontGroupTypeIndex: Observable<Int> { get }
    var customFontGroupTypeNameTitle: String { get }
    var customFontGroupTypeName: Observable<String> { get }
    var showCustomFontName: Observable<Bool> { get }
    var articleAssociatedURL: Observable<String> { get }
    var articleSection: Observable<String> { get }
    var shouldShowArticleURL: Observable<Bool> { get }
    var shouldShowSetLanguage: Observable<Bool> { get }
    var shouldShowColorSettingButton: Observable<Bool> { get }
    var supportedLanguageItems: [String] { get }
    var supportedLanguageTitle: String { get }
    var languageStrategyTitle: String { get }
    var languageStrategyIndex: Observable<Int> { get }
    var languageName: Observable<String> { get }
    var languageStrategySettings: [String] { get }

    var localeStrategyIndex: Observable<Int> { get }
    var localeStrategyTitle: String { get }
    var localeStrategySettings: [String] { get }

    var elementsCustomizationStyleTitle: String { get }
    var elementsCustomizationStyleSettings: [String] { get }

    var colorsCustomizationStyleTitle: String { get }
    var colorsCustomizationStyleSettings: [String] { get }
    var openColorsCustomizationScreen: Observable<UIViewController> { get }

    var articleHeaderStyle: Observable<OWArticleHeaderStyle> { get }
    var articleHeaderStyleTitle: String { get }
    var articleHeaderStyleSettings: [String] { get }

    var articleInformationStrategy: Observable<OWArticleInformationStrategy> { get }
    var articleInformationStrategyTitle: String { get }
    var articleInformationStrategySettings: [String] { get }

    var showLoginPrompt: Observable<Bool> { get }
    var showLoginPromptTitle: String { get }

    var orientationEnforcement: Observable<OWOrientationEnforcement> { get }
    var orientationEnforcementTitle: String { get }
    var orientationEnforcementSettings: [String] { get }

    var commentActionsColor: Observable<OWCommentActionsColor> { get }
    var commentActionsFontStyle: Observable<OWCommentActionsFontStyle> { get }
    var commentActionsColorTitle: String { get }
    var commentActionsFontStyleTitle: String { get }
    var commentActionsColorSettings: [String] { get }
    var commentActionsFontStyleSettings: [String] { get }
}

protocol GeneralSettingsViewModeling {
    var inputs: GeneralSettingsViewModelingInputs { get }
    var outputs: GeneralSettingsViewModelingOutputs { get }
}

class GeneralSettingsVM: GeneralSettingsViewModeling, GeneralSettingsViewModelingInputs, GeneralSettingsViewModelingOutputs {
    var inputs: GeneralSettingsViewModelingInputs { return self }
    var outputs: GeneralSettingsViewModelingOutputs { return self }

    var articleHeaderSelectedStyle = BehaviorSubject<OWArticleHeaderStyle>(value: OWArticleHeaderStyle.default)
    var articleInformationSelectedStrategy = BehaviorSubject<OWArticleInformationStrategy>(value: .default)
    var orientationSelectedEnforcement = BehaviorSubject<OWOrientationEnforcement>(value: .default)
    var elementsCustomizationStyleSelectedIndex = PublishSubject<Int>()
    var colorsCustomizationStyleSelectedIndex = PublishSubject<Int>()
    var readOnlyModeSelectedIndex = PublishSubject<Int>()
    var themeModeSelectedIndex = PublishSubject<Int>()
    var statusBarStyleSelectedIndex = PublishSubject<Int>()
    var navigationBarStyleSelectedIndex = PublishSubject<Int>()
    var modalStyleSelectedIndex = PublishSubject<Int>()
    var initialSortSelectedIndex = PublishSubject<Int>()
    var customSortTitlesChanged = PublishSubject<[OWSortOption: String]>()
    var fontGroupTypeSelectedIndex = BehaviorSubject<Int>(value: 0)
    var customFontGroupSelectedName = BehaviorSubject<String>(value: "")
    var articleAssociatedSelectedURL = PublishSubject<String>()
    var articleSelectedSection = PublishSubject<String>()
    var languageStrategySelectedIndex = BehaviorSubject<Int>(value: OWLanguageStrategy.defaultStrategyIndex)
    var languageSelectedName = BehaviorSubject<String>(value: OWSupportedLanguage.defaultLanguage.languageName)
    var localeStrategySelectedIndex = BehaviorSubject<Int>(value: OWLocaleStrategy.default.index)
    var showLoginPromptSelected = BehaviorSubject<Bool>(value: false)
    var commentActionsColorSelected = BehaviorSubject<OWCommentActionsColor>(value: .default)
    var commentActionsFontStyleSelected = BehaviorSubject<OWCommentActionsFontStyle>(value: .default)

    private var userDefaultsProvider: UserDefaultsProviderProtocol
    private var manager: OWManagerProtocol

    private lazy var fontGroupTypeObservable =
    Observable.combineLatest(fontGroupTypeSelectedIndex, customFontGroupSelectedName) { index, name -> OWFontGroupFamily in
        return OWFontGroupFamily.fontGroupFamily(fromIndex: index, name: name)
    }
    .skip(2)
    .asObservable()

    private lazy var languageStrategyObservable =
    Observable.combineLatest(languageStrategySelectedIndex, languageSelectedName) { index, languageName -> OWLanguageStrategy in
        return OWLanguageStrategy.languageStrategy(fromIndex: index, language: OWSupportedLanguage(languageName: languageName))
    }
    .skip(2)
    .asObservable()

    private lazy var localeStrategyObservable =
    localeStrategySelectedIndex
        .map { index in
            return OWLocaleStrategy.localeStrategy(fromIndex: index)
        }
        .skip(1)
        .asObservable()

    var elementsCustomizationStyleIndex: Observable<Int> {
        return userDefaultsProvider.values(key: .elementsCustomizationStyleIndex, defaultValue: SettingsElementsCustomizationStyle.defaultIndex)
    }

    var colorsCustomizationStyleIndex: Observable<Int> {
        return userDefaultsProvider.values(key: .colorCustomizationStyleIndex, defaultValue: SettingsColorCustomizationStyle.defaultIndex)
    }

    var articleHeaderStyle: Observable<OWArticleHeaderStyle> {
        return userDefaultsProvider.values(key: .articleHeaderStyle, defaultValue: OWArticleHeaderStyle.default)
    }

    var articleInformationStrategy: Observable<OWArticleInformationStrategy> {
        return userDefaultsProvider.values(key: .articleInformationStrategy, defaultValue: .server)
    }

    var showLoginPrompt: Observable<Bool> {
        return userDefaultsProvider.values(key: .showLoginPrompt, defaultValue: false)
    }

    var orientationEnforcement: Observable<OWOrientationEnforcement> {
        return userDefaultsProvider.values(key: .orientationEnforcement, defaultValue: OWOrientationEnforcement.default)
    }

    var commentActionsColor: Observable<OWCommentActionsColor> {
        return userDefaultsProvider.values(key: .commentActionsColor, defaultValue: OWCommentActionsColor.default)
    }

    var commentActionsFontStyle: Observable<OWCommentActionsFontStyle> {
        return userDefaultsProvider.values(key: .commentActionsFontStyle, defaultValue: OWCommentActionsFontStyle.default)
    }

    var readOnlyModeIndex: Observable<Int> {
        return userDefaultsProvider.values(key: .readOnlyModeIndex, defaultValue: OWReadOnlyMode.default.index)
    }

    var themeModeIndex: Observable<Int> {
        return userDefaultsProvider.values(key: .themeModeIndex, defaultValue: OWThemeStyleEnforcement.default.index)
    }

    var statusBarStyleIndex: Observable<Int> {
        return userDefaultsProvider.values(key: .statusBarStyleIndex, defaultValue: OWStatusBarEnforcement.default.index)
    }

    var navigationBarStyleIndex: Observable<Int> {
        return userDefaultsProvider.values(key: .navigationBarStyleIndex, defaultValue: OWNavigationBarEnforcement.default.index)
    }

    var modalStyleIndex: Observable<Int> {
        return userDefaultsProvider.values(key: .modalStyleIndex, defaultValue: OWModalPresentationStyle.default.index)
    }

    var initialSortIndex: Observable<Int> {
        return userDefaultsProvider.values(key: .initialSortIndex, defaultValue: OWInitialSortStrategy.default.index)
    }

    var customSortTitles: Observable<[OWSortOption: String]> {
        return userDefaultsProvider.values(key: .customSortTitles)
    }

    var fontGroupTypeIndex: Observable<Int> {
        return userDefaultsProvider.values(key: .fontGroupType, defaultValue: OWFontGroupFamily.default)
            .map { fontGroupFamily in
                switch fontGroupFamily {
                case .`default`:
                    return 0
                case .custom:
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

    var articleSection: Observable<String> {
        return userDefaultsProvider.values(key: .articleSection)
    }

    var showCustomFontName: Observable<Bool> {
        return userDefaultsProvider.values(key: .fontGroupType, defaultValue: OWFontGroupFamily.default)
            .map { fontGroupFamily in
                switch fontGroupFamily {
                case .custom:
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
                    return OWLocaleStrategy.default.index
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
                case .use:
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

    var shouldShowArticleURL: Observable<Bool> {
        return articleInformationStrategy
            .map {
                switch $0 {
                case .server: return false
                case .local: return true
                default:
                    return false
                }
            }
            .asObservable()
    }

    var shouldShowColorSettingButton: Observable<Bool> {
        return userDefaultsProvider.values(key: .colorCustomizationStyleIndex, defaultValue: 0)
            .map { $0 == 2 } // Custom
            .asObservable()
    }
    var openColorsCustomizationClicked = PublishSubject<Void>()
    var openColorsCustomizationScreen: Observable<UIViewController> {
        return openColorsCustomizationClicked
            .map { [weak self] _ -> UIViewController? in
                if #available(iOS 14.0, *) {
                    guard let self else { return nil }
                    return ColorsCustomizationVC(viewModel: ColorsCustomizationViewModel(userDefaultsProvider: self.userDefaultsProvider))
                } else {
                    return nil
                }
            }
            .unwrap()
            .asObservable()
    }

    private let disposeBag = DisposeBag()

    lazy var title: String = {
        return NSLocalizedString("GeneralSettings", comment: "")
    }()

    lazy var articleHeaderStyleTitle: String = {
        return NSLocalizedString("ArticleHeaderStyle", comment: "")
    }()

    lazy var articleInformationStrategyTitle: String = {
        return NSLocalizedString("ArticleInformationStrategy", comment: "")
    }()

    lazy var orientationEnforcementTitle: String = {
        return NSLocalizedString("OrientationEnforcement", comment: "")
    }()

    lazy var commentActionsColorTitle: String = {
        return NSLocalizedString("CommentActionsColor", comment: "")
    }()

    lazy var commentActionsFontStyleTitle: String = {
        return NSLocalizedString("CommentActionsFontStyle", comment: "")
    }()

    lazy var commentActionsColorSettings: [String] = {
        let _default = NSLocalizedString("Default", comment: "")
        let _brandColor = NSLocalizedString("BrandColor", comment: "")

        return [_default, _brandColor]
    }()

    lazy var commentActionsFontStyleSettings: [String] = {
        let _default = NSLocalizedString("Default", comment: "")
        let _semiBold = NSLocalizedString("SemiBold", comment: "")

        return [_default, _semiBold]
    }()

    lazy var elementsCustomizationStyleTitle: String = {
        return NSLocalizedString("ElementsCustomizationStyle", comment: "")
    }()

    lazy var colorsCustomizationStyleTitle: String = {
        return NSLocalizedString("ColorsCustomizationStyle", comment: "")
    }()

    lazy var readOnlyTitle: String = {
        return NSLocalizedString("ReadOnlyMode", comment: "")
    }()

    lazy var articleURLTitle: String = {
        return NSLocalizedString("ArticleAssociatedURL", comment: "")
    }()

    lazy var articleSectionTitle: String = {
        return NSLocalizedString("ArticleSection", comment: "")
    }()

    lazy var showLoginPromptTitle: String = {
        return NSLocalizedString("ShowLoginPromptTitle", comment: "")
    }()

    lazy var readOnlySettings: [String] = {
        let _server = NSLocalizedString("Server", comment: "")
        let _enabled = NSLocalizedString("Enabled", comment: "")
        let _disabled = NSLocalizedString("Disabled", comment: "")

        return [_server, _enabled, _disabled]
    }()

    lazy var themeModeTitle: String = {
        return NSLocalizedString("ThemeMode", comment: "")
    }()

    lazy var statusBarStyleTitle: String = {
        return NSLocalizedString("StatusBarStyle", comment: "")
    }()

    lazy var navigationBarStyleTitle: String = {
        return NSLocalizedString("NavigationBarStyle", comment: "")
    }()

    lazy var articleHeaderStyleSettings: [String] = {
        let _none = NSLocalizedString("None", comment: "")
        let _regular = NSLocalizedString("Regular", comment: "")

        return [_none, _regular]
    }()

    lazy var articleInformationStrategySettings: [String] = {
        let _server = NSLocalizedString("Server", comment: "")
        let _local = NSLocalizedString("Local", comment: "")

        return [_server, _local]
    }()

    lazy var orientationEnforcementSettings: [String] = {
        let _enableAll = NSLocalizedString("EnableAll", comment: "")
        let _portrait = NSLocalizedString("Portrait", comment: "")
        let _landscape = NSLocalizedString("Landscape", comment: "")

        return [_enableAll, _portrait, _landscape]
    }()

    lazy var elementsCustomizationStyleSettings: [String] = {
        let _none = NSLocalizedString("None", comment: "")
        let _style1 = NSLocalizedString("Style1", comment: "")
        let _style2 = NSLocalizedString("Style2", comment: "")

        return [_none, _style1, _style2]
    }()

    lazy var colorsCustomizationStyleSettings: [String] = {
        let _none = NSLocalizedString("None", comment: "")
        let _style1 = NSLocalizedString("Style1", comment: "")
        let _custom = NSLocalizedString("Custom", comment: "")

        return [_none, _style1, _custom]
    }()

    lazy var themeModeSettings: [String] = {
        let _default = NSLocalizedString("Default", comment: "")
        let _light = NSLocalizedString("Light", comment: "")
        let _dark = NSLocalizedString("Dark", comment: "")

        return [_default, _light, _dark]
    }()

    lazy var statusBarStyleSettings: [String] = {
        let _matchTheme = NSLocalizedString("MatchTheme", comment: "")
        let _light = NSLocalizedString("Light", comment: "")
        let _dark = NSLocalizedString("Dark", comment: "")

        return [_matchTheme, _light, _dark]
    }()

    lazy var navigationBarStyleSettings: [String] = {
        let _largeTitles = NSLocalizedString("LargeTitles", comment: "")
        let _regular = NSLocalizedString("Regular", comment: "")
        let _keepOriginal = NSLocalizedString("KeepOriginal", comment: "")

        return [_largeTitles, _regular, _keepOriginal]
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

private extension GeneralSettingsVM {
    // swiftlint:disable function_body_length
    func setupObservers() {
        articleHeaderSelectedStyle
            .skip(1)
            .bind(to: userDefaultsProvider.rxProtocol
            .setValues(key: UserDefaultsProvider.UDKey<OWArticleHeaderStyle>.articleHeaderStyle))
            .disposed(by: disposeBag)

        articleInformationSelectedStrategy
            .skip(1)
            .bind(to: userDefaultsProvider.rxProtocol
                .setValues(key: UserDefaultsProvider.UDKey<OWArticleInformationStrategy>.articleInformationStrategy))
            .disposed(by: disposeBag)

        orientationSelectedEnforcement
            .skip(1)
            .bind(to: userDefaultsProvider.rxProtocol
                .setValues(key: UserDefaultsProvider.UDKey<OWOrientationEnforcement>.orientationEnforcement))
            .disposed(by: disposeBag)

        commentActionsColorSelected
            .skip(1)
            .bind(to: userDefaultsProvider.rxProtocol
                .setValues(key: UserDefaultsProvider.UDKey<OWCommentActionsColor>.commentActionsColor))
            .disposed(by: disposeBag)

        commentActionsFontStyleSelected
            .skip(1)
            .bind(to: userDefaultsProvider.rxProtocol
                .setValues(key: UserDefaultsProvider.UDKey<OWCommentActionsFontStyle>.commentActionsFontStyle))
            .disposed(by: disposeBag)

        elementsCustomizationStyleSelectedIndex
            .skip(1)
            .bind(to: userDefaultsProvider.rxProtocol
            .setValues(key: UserDefaultsProvider.UDKey<Int>.elementsCustomizationStyleIndex))
            .disposed(by: disposeBag)

        colorsCustomizationStyleSelectedIndex
            .skip(1)
            .bind(to: userDefaultsProvider.rxProtocol
            .setValues(key: UserDefaultsProvider.UDKey<Int>.colorCustomizationStyleIndex))
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

        statusBarStyleSelectedIndex
            .skip(1)
            .bind(to: userDefaultsProvider.rxProtocol
            .setValues(key: UserDefaultsProvider.UDKey<Int>.statusBarStyleIndex))
            .disposed(by: disposeBag)

        navigationBarStyleSelectedIndex
            .skip(1)
            .bind(to: userDefaultsProvider.rxProtocol
            .setValues(key: UserDefaultsProvider.UDKey<Int>.navigationBarStyleIndex))
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

        customSortTitlesChanged
            .skip(1)
            .bind(to: userDefaultsProvider.rxProtocol
                .setValues(key: UserDefaultsProvider.UDKey<[OWSortOption: String]>.customSortTitles))
            .disposed(by: disposeBag)

        fontGroupTypeObservable
            .bind(to: userDefaultsProvider.rxProtocol
            .setValues(key: UserDefaultsProvider.UDKey<OWFontGroupFamily>.fontGroupType))
            .disposed(by: disposeBag)

        articleAssociatedSelectedURL
            .skip(1)
            .bind(to: userDefaultsProvider.rxProtocol
            .setValues(key: UserDefaultsProvider.UDKey<String?>.articleAssociatedURL))
            .disposed(by: disposeBag)

        articleSelectedSection
            .skip(1)
            .bind(to: userDefaultsProvider.rxProtocol
            .setValues(key: UserDefaultsProvider.UDKey<String?>.articleSection))
            .disposed(by: disposeBag)

        themeModeSelectedIndex // 0. default 1. light 2. dark
            .subscribe(onNext: { [weak self] index in
                guard let self else { return }
                let customizations = self.manager.ui.customizations
                customizations.themeEnforcement = .themeStyle(fromIndex: index)
            })
            .disposed(by: disposeBag)

        statusBarStyleSelectedIndex // 0. matchTheme 1. light 2. dark
            .subscribe(onNext: { [weak self] index in
                guard let self else { return }
                let customizations = self.manager.ui.customizations
                customizations.statusBarEnforcement = .statusBarStyle(fromIndex: index)
            })
            .disposed(by: disposeBag)

        navigationBarStyleSelectedIndex // 0. largeTitles 1. regular 2. keepOriginal
            .subscribe(onNext: { [weak self] index in
                guard let self else { return }
                let customizations = self.manager.ui.customizations
                customizations.navigationBarEnforcement = .navigationBarEnforcement(fromIndex: index)
            })
            .disposed(by: disposeBag)

        fontGroupTypeObservable
            .subscribe(onNext: { [weak self] fontGroupType in
                guard let self else { return }
                let customizations = self.manager.ui.customizations
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

        showLoginPromptSelected
            .skip(1)
            .bind(to: userDefaultsProvider.rxProtocol
                .setValues(key: UserDefaultsProvider.UDKey<Bool>.showLoginPrompt))
            .disposed(by: disposeBag)
    }
    // swiftlint:enable function_body_length
}

extension GeneralSettingsVM: SettingsGroupVMProtocol {
    func resetToDefault() {
        articleHeaderSelectedStyle.onNext(OWArticleHeaderStyle.default)
        articleInformationSelectedStrategy.onNext(OWArticleInformationStrategy.default)
        articleAssociatedSelectedURL.onNext("")
        articleSelectedSection.onNext("")
        elementsCustomizationStyleSelectedIndex.onNext(SettingsElementsCustomizationStyle.defaultIndex)
        colorsCustomizationStyleSelectedIndex.onNext(SettingsColorCustomizationStyle.defaultIndex)
        readOnlyModeSelectedIndex.onNext(OWReadOnlyMode.default.index)
        themeModeSelectedIndex.onNext(OWThemeStyleEnforcement.default.index)
        statusBarStyleSelectedIndex.onNext(OWStatusBarEnforcement.default.index)
        navigationBarStyleSelectedIndex.onNext(OWNavigationBarEnforcement.default.index)
        modalStyleSelectedIndex.onNext(OWModalPresentationStyle.default.index)
        initialSortSelectedIndex.onNext(OWInitialSortStrategy.default.index)
        customSortTitlesChanged.onNext([:])
        fontGroupTypeSelectedIndex.onNext(OWFontGroupFamilyIndexer.`default`.index)
        languageStrategySelectedIndex.onNext(OWLanguageStrategy.defaultStrategyIndex)
        showLoginPromptSelected.onNext(false)
        orientationSelectedEnforcement.onNext(OWOrientationEnforcement.default)
        commentActionsColorSelected.onNext(OWCommentActionsColor.default)
        commentActionsFontStyleSelected.onNext(OWCommentActionsFontStyle.default)
    }
}

extension OWSortOption {
    /// index into `GeneralSettingsVM.initialSortSettings`
    var titleIndex: Int {
        switch self {
        case .best:
            return 1
        case .newest:
            return 2
        case .oldest:
            return 3
        default:
            return 0
        }
    }
}
