//
//  GeneralSettingsVM.swift
//  OpenWeb-Development
//
//  Created by Refael Sommer on 26/02/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation
import UIKit
import Combine
import OpenWebSDK

protocol GeneralSettingsViewModelingInputs {
    var articleHeaderSelectedStyle: CurrentValueSubject<OWArticleHeaderStyle, Never> { get }
    var articleInformationSelectedStrategy: CurrentValueSubject<OWArticleInformationStrategy, Never> { get }
    var orientationSelectedEnforcement: CurrentValueSubject<OWOrientationEnforcement, Never> { get }
    var elementsCustomizationStyleSelectedIndex: CurrentValueSubject<Int, Never> { get }
    var colorsCustomizationStyleSelectedIndex: CurrentValueSubject<Int, Never> { get }
    var readOnlyModeSelectedIndex: CurrentValueSubject<Int, Never> { get }
    var themeModeSelectedIndex: CurrentValueSubject<Int, Never> { get }
    var statusBarStyleSelectedIndex: CurrentValueSubject<Int, Never> { get }
    var navigationBarStyleSelectedIndex: CurrentValueSubject<Int, Never> { get }
    var modalStyleSelectedIndex: CurrentValueSubject<Int, Never> { get }
    var initialSortSelectedIndex: CurrentValueSubject<Int, Never> { get }
    var fontGroupTypeSelectedIndex: CurrentValueSubject<Int, Never> { get }
    var customFontGroupSelectedName: CurrentValueSubject<String, Never> { get }
    var articleAssociatedSelectedURL: CurrentValueSubject<String, Never> { get }
    var articleSelectedSection: CurrentValueSubject<String, Never> { get }
    var languageStrategySelectedIndex: CurrentValueSubject<Int, Never> { get }
    var languageSelectedName: CurrentValueSubject<String, Never> { get }
    var localeStrategySelectedIndex: CurrentValueSubject<Int, Never> { get }
    var showLoginPromptSelected: CurrentValueSubject<Bool, Never> { get }
    var openColorsCustomizationClicked: PassthroughSubject<Void, Never> { get }
    var commentActionsColorSelected: CurrentValueSubject<OWCommentActionsColor, Never> { get }
    var commentActionsFontStyleSelected: CurrentValueSubject<OWCommentActionsFontStyle, Never> { get }
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
    var elementsCustomizationStyleIndex: AnyPublisher<Int, Never> { get }
    var colorsCustomizationStyleIndex: AnyPublisher<Int, Never> { get }
    var readOnlyModeIndex: AnyPublisher<Int, Never> { get }
    var themeModeIndex: AnyPublisher<Int, Never> { get }
    var statusBarStyleIndex: AnyPublisher<Int, Never> { get }
    var navigationBarStyleIndex: AnyPublisher<Int, Never> { get }
    var modalStyleIndex: AnyPublisher<Int, Never> { get }
    var initialSortIndex: AnyPublisher<Int, Never> { get }
    var fontGroupTypeIndex: AnyPublisher<Int, Never> { get }
    var customFontGroupTypeNameTitle: String { get }
    var customFontGroupTypeName: AnyPublisher<String, Never> { get }
    var showCustomFontName: AnyPublisher<Bool, Never> { get }
    var articleAssociatedURL: AnyPublisher<String, Never> { get }
    var articleSection: AnyPublisher<String, Never> { get }
    var shouldShowArticleURL: AnyPublisher<Bool, Never> { get }
    var shouldShowSetLanguage: AnyPublisher<Bool, Never> { get }
    var shouldShowColorSettingButton: AnyPublisher<Bool, Never> { get }
    var supportedLanguageItems: [String] { get }
    var supportedLanguageTitle: String { get }
    var languageStrategyTitle: String { get }
    var languageStrategyIndex: AnyPublisher<Int, Never> { get }
    var languageName: AnyPublisher<String, Never> { get }
    var languageStrategySettings: [String] { get }

    var localeStrategyIndex: AnyPublisher<Int, Never> { get }
    var localeStrategyTitle: String { get }
    var localeStrategySettings: [String] { get }

    var elementsCustomizationStyleTitle: String { get }
    var elementsCustomizationStyleSettings: [String] { get }

    var colorsCustomizationStyleTitle: String { get }
    var colorsCustomizationStyleSettings: [String] { get }
    var openColorsCustomizationScreen: AnyPublisher<UIViewController, Never> { get }

    var articleHeaderStyle: AnyPublisher<OWArticleHeaderStyle, Never> { get }
    var articleHeaderStyleTitle: String { get }
    var articleHeaderStyleSettings: [String] { get }

    var articleInformationStrategy: AnyPublisher<OWArticleInformationStrategy, Never> { get }
    var articleInformationStrategyTitle: String { get }
    var articleInformationStrategySettings: [String] { get }

    var showLoginPrompt: AnyPublisher<Bool, Never> { get }
    var showLoginPromptTitle: String { get }

    var orientationEnforcement: AnyPublisher<OWOrientationEnforcement, Never> { get }
    var orientationEnforcementTitle: String { get }
    var orientationEnforcementSettings: [String] { get }

    var commentActionsColor: AnyPublisher<OWCommentActionsColor, Never> { get }
    var commentActionsFontStyle: AnyPublisher<OWCommentActionsFontStyle, Never> { get }
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

    lazy var articleHeaderSelectedStyle = CurrentValueSubject<OWArticleHeaderStyle, Never>(userDefaultsProvider.get(key: .articleHeaderStyle, defaultValue: OWArticleHeaderStyle.default))
    lazy var articleInformationSelectedStrategy = CurrentValueSubject<OWArticleInformationStrategy, Never>(userDefaultsProvider.get(key: .articleInformationStrategy, defaultValue: .default))
    lazy var orientationSelectedEnforcement = CurrentValueSubject<OWOrientationEnforcement, Never>(userDefaultsProvider.get(key: .orientationEnforcement, defaultValue: .default))
    lazy var elementsCustomizationStyleSelectedIndex = CurrentValueSubject<Int, Never>(
        userDefaultsProvider.get(key: UserDefaultsProvider.UDKey<Int>.elementsCustomizationStyleIndex, defaultValue: 0)
    )
    lazy var colorsCustomizationStyleSelectedIndex = CurrentValueSubject<Int, Never>(
        userDefaultsProvider.get(key: .colorCustomizationStyleIndex, defaultValue: SettingsColorCustomizationStyle.defaultIndex)
    )
    lazy var readOnlyModeSelectedIndex = CurrentValueSubject<Int, Never>(userDefaultsProvider.get(key: .readOnlyModeIndex, defaultValue: OWReadOnlyMode.default.index))
    lazy var themeModeSelectedIndex = CurrentValueSubject<Int, Never>(userDefaultsProvider.get(key: .themeModeIndex, defaultValue: OWThemeStyleEnforcement.default.index))
    lazy var statusBarStyleSelectedIndex = CurrentValueSubject<Int, Never>(userDefaultsProvider.get(key: .statusBarStyleIndex, defaultValue: OWStatusBarEnforcement.default.index))
    lazy var navigationBarStyleSelectedIndex = CurrentValueSubject<Int, Never>(
        userDefaultsProvider.get(key: .navigationBarStyleIndex, defaultValue: OWNavigationBarEnforcement.default.index)
    )
    lazy var modalStyleSelectedIndex = CurrentValueSubject<Int, Never>(userDefaultsProvider.get(key: .modalStyleIndex, defaultValue: OWModalPresentationStyle.default.index))
    lazy var initialSortSelectedIndex = CurrentValueSubject<Int, Never>(userDefaultsProvider.get(key: .initialSortIndex, defaultValue: OWInitialSortStrategy.default.index))
    lazy var fontGroupTypeSelectedIndex = CurrentValueSubject<Int, Never>(userDefaultsProvider.get(key: .fontGroupType, defaultValue: OWFontGroupFamily.default).index)
    lazy var customFontGroupSelectedName = CurrentValueSubject<String, Never>(userDefaultsProvider.get(key: .fontGroupType, defaultValue: OWFontGroupFamily.default).name)
    lazy var articleAssociatedSelectedURL = CurrentValueSubject<String, Never>(userDefaultsProvider.get(key: .articleAssociatedURL, defaultValue: ""))
    lazy var articleSelectedSection = CurrentValueSubject<String, Never>(userDefaultsProvider.get(key: UserDefaultsProvider.UDKey<String>.articleSection, defaultValue: ""))
    lazy var languageStrategySelectedIndex = CurrentValueSubject<Int, Never>(userDefaultsProvider.get(key: .languageStrategy, defaultValue: OWLanguageStrategy.default).index)
    lazy var languageSelectedName = CurrentValueSubject<String, Never>(userDefaultsProvider.get(key: .languageStrategy, defaultValue: OWLanguageStrategy.default).name)
    lazy var localeStrategySelectedIndex = CurrentValueSubject<Int, Never>(userDefaultsProvider.get(key: .localeStrategy, defaultValue: OWLocaleStrategy.default).index)
    lazy var showLoginPromptSelected = CurrentValueSubject<Bool, Never>(userDefaultsProvider.get(key: .showLoginPrompt, defaultValue: false))
    lazy var commentActionsColorSelected = CurrentValueSubject<OWCommentActionsColor, Never>(userDefaultsProvider.get(key: .commentActionsColor, defaultValue: .default))
    lazy var commentActionsFontStyleSelected = CurrentValueSubject<OWCommentActionsFontStyle, Never>(userDefaultsProvider.get(key: .commentActionsFontStyle, defaultValue: .default))

    private var userDefaultsProvider: UserDefaultsProviderProtocol
    private var manager: OWManagerProtocol

    private lazy var fontGroupTypeObservable =
    Publishers.CombineLatest(fontGroupTypeSelectedIndex, customFontGroupSelectedName).map { index, name -> OWFontGroupFamily in
        return OWFontGroupFamily.fontGroupFamily(fromIndex: index, name: name)
    }
    .dropFirst()
    .eraseToAnyPublisher()

    private lazy var languageStrategyObservable =
    Publishers.CombineLatest(languageStrategySelectedIndex, languageSelectedName).map { index, languageName -> OWLanguageStrategy in
        return OWLanguageStrategy.languageStrategy(fromIndex: index, language: OWSupportedLanguage(languageName: languageName))
    }
    .dropFirst()
    .eraseToAnyPublisher()

    private lazy var localeStrategyObservable =
    localeStrategySelectedIndex
        .map { index in
            return OWLocaleStrategy.localeStrategy(fromIndex: index)
        }
        .dropFirst()
        .eraseToAnyPublisher()

    var elementsCustomizationStyleIndex: AnyPublisher<Int, Never> {
        elementsCustomizationStyleSelectedIndex
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    var colorsCustomizationStyleIndex: AnyPublisher<Int, Never> {
        return colorsCustomizationStyleSelectedIndex
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    var articleHeaderStyle: AnyPublisher<OWArticleHeaderStyle, Never> {
        return articleHeaderSelectedStyle
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    var articleInformationStrategy: AnyPublisher<OWArticleInformationStrategy, Never> {
        return articleInformationSelectedStrategy
            .eraseToAnyPublisher()
    }

    var showLoginPrompt: AnyPublisher<Bool, Never> {
        return showLoginPromptSelected
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    var orientationEnforcement: AnyPublisher<OWOrientationEnforcement, Never> {
        return orientationSelectedEnforcement
            .eraseToAnyPublisher()
    }

    var commentActionsColor: AnyPublisher<OWCommentActionsColor, Never> {
        return commentActionsColorSelected
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    var commentActionsFontStyle: AnyPublisher<OWCommentActionsFontStyle, Never> {
        return commentActionsFontStyleSelected
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    var readOnlyModeIndex: AnyPublisher<Int, Never> {
        return readOnlyModeSelectedIndex
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    var themeModeIndex: AnyPublisher<Int, Never> {
        return themeModeSelectedIndex
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    var statusBarStyleIndex: AnyPublisher<Int, Never> {
        return statusBarStyleSelectedIndex
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    var navigationBarStyleIndex: AnyPublisher<Int, Never> {
        return navigationBarStyleSelectedIndex
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    var modalStyleIndex: AnyPublisher<Int, Never> {
        return modalStyleSelectedIndex
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    var initialSortIndex: AnyPublisher<Int, Never> {
        return initialSortSelectedIndex
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    var fontGroupTypeIndex: AnyPublisher<Int, Never> {
        return fontGroupTypeSelectedIndex
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    var customFontGroupTypeName: AnyPublisher<String, Never> {
        return customFontGroupSelectedName
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    var articleAssociatedURL: AnyPublisher<String, Never> {
        return articleAssociatedSelectedURL
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    var articleSection: AnyPublisher<String, Never> {
        return articleSelectedSection
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    var showCustomFontName: AnyPublisher<Bool, Never> {
        fontGroupTypeSelectedIndex
            .map { $0 != 0 }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    var localeStrategyIndex: AnyPublisher<Int, Never> {
        return localeStrategySelectedIndex
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    var languageStrategyIndex: AnyPublisher<Int, Never> {
        return languageStrategySelectedIndex
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    var languageName: AnyPublisher<String, Never> {
        return languageSelectedName
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    var shouldShowSetLanguage: AnyPublisher<Bool, Never> {
        return languageStrategyIndex
            .map { $0 == 2 }// Set language
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    var shouldShowArticleURL: AnyPublisher<Bool, Never> {
        return articleInformationStrategy
            .map {
                switch $0 {
                case .server: return false
                case .local: return true
                default:
                    return false
                }
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    var shouldShowColorSettingButton: AnyPublisher<Bool, Never> {
        return colorsCustomizationStyleSelectedIndex
            .map { $0 == 2 } // Custom
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    var openColorsCustomizationClicked = PassthroughSubject<Void, Never>()

    var openColorsCustomizationScreen: AnyPublisher<UIViewController, Never> {
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
            .eraseToAnyPublisher()
    }

    private var cancellables = Set<AnyCancellable>()

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
            .dropFirst()
            .bind(to: userDefaultsProvider.setValues(key: UserDefaultsProvider.UDKey<OWArticleHeaderStyle>.articleHeaderStyle))
            .store(in: &cancellables)

        articleInformationSelectedStrategy
            .dropFirst()
            .bind(to: userDefaultsProvider.setValues(key: UserDefaultsProvider.UDKey<OWArticleInformationStrategy>.articleInformationStrategy))
            .store(in: &cancellables)

        orientationSelectedEnforcement
            .dropFirst()
            .bind(to: userDefaultsProvider.setValues(key: UserDefaultsProvider.UDKey<OWOrientationEnforcement>.orientationEnforcement))
            .store(in: &cancellables)

        commentActionsColorSelected
            .dropFirst()
            .bind(to: userDefaultsProvider.setValues(key: UserDefaultsProvider.UDKey<OWCommentActionsColor>.commentActionsColor))
            .store(in: &cancellables)

        commentActionsFontStyleSelected
            .dropFirst()
            .bind(to: userDefaultsProvider.setValues(key: UserDefaultsProvider.UDKey<OWCommentActionsFontStyle>.commentActionsFontStyle))
            .store(in: &cancellables)

        elementsCustomizationStyleSelectedIndex
            .dropFirst()
            .bind(to: userDefaultsProvider.setValues(key: UserDefaultsProvider.UDKey<Int>.elementsCustomizationStyleIndex))
            .store(in: &cancellables)

        colorsCustomizationStyleSelectedIndex
            .dropFirst()
            .bind(to: userDefaultsProvider.setValues(key: UserDefaultsProvider.UDKey<Int>.colorCustomizationStyleIndex))
            .store(in: &cancellables)

        readOnlyModeSelectedIndex
            .dropFirst()
            .bind(to: userDefaultsProvider.setValues(key: UserDefaultsProvider.UDKey<Int>.readOnlyModeIndex))
            .store(in: &cancellables)

        themeModeSelectedIndex
            .dropFirst()
            .bind(to: userDefaultsProvider.setValues(key: UserDefaultsProvider.UDKey<Int>.themeModeIndex))
            .store(in: &cancellables)

        statusBarStyleSelectedIndex
            .dropFirst()
            .bind(to: userDefaultsProvider.setValues(key: UserDefaultsProvider.UDKey<Int>.statusBarStyleIndex))
            .store(in: &cancellables)

        navigationBarStyleSelectedIndex
            .dropFirst()
            .bind(to: userDefaultsProvider.setValues(key: UserDefaultsProvider.UDKey<Int>.navigationBarStyleIndex))
            .store(in: &cancellables)

        modalStyleSelectedIndex
            .dropFirst()
            .bind(to: userDefaultsProvider.setValues(key: UserDefaultsProvider.UDKey<Int>.modalStyleIndex))
            .store(in: &cancellables)

        initialSortSelectedIndex
            .dropFirst()
            .bind(to: userDefaultsProvider.setValues(key: UserDefaultsProvider.UDKey<Int>.initialSortIndex))
            .store(in: &cancellables)

        fontGroupTypeObservable
            .bind(to: userDefaultsProvider.setValues(key: UserDefaultsProvider.UDKey<OWFontGroupFamily>.fontGroupType))
            .store(in: &cancellables)

        articleAssociatedSelectedURL
            .dropFirst()
            .bind(to: userDefaultsProvider.setValues(key: UserDefaultsProvider.UDKey<String>.articleAssociatedURL))
            .store(in: &cancellables)

        articleSelectedSection
            .dropFirst()
            .bind(to: userDefaultsProvider.setValues(key: UserDefaultsProvider.UDKey<String>.articleSection))
            .store(in: &cancellables)

        themeModeSelectedIndex // 0. default 1. light 2. dark
            .sink { [weak self] index in
                guard let self else { return }
                let customizations = self.manager.ui.customizations
                customizations.themeEnforcement = .themeStyle(fromIndex: index)
            }
            .store(in: &cancellables)

        statusBarStyleSelectedIndex // 0. matchTheme 1. light 2. dark
            .sink { [weak self] index in
                guard let self else { return }
                let customizations = self.manager.ui.customizations
                customizations.statusBarEnforcement = .statusBarStyle(fromIndex: index)
            }
            .store(in: &cancellables)

        navigationBarStyleSelectedIndex // 0. largeTitles 1. regular 2. keepOriginal
            .sink { [weak self] index in
                guard let self else { return }
                let customizations = self.manager.ui.customizations
                customizations.navigationBarEnforcement = .navigationBarEnforcement(fromIndex: index)
            }
            .store(in: &cancellables)

        fontGroupTypeObservable
            .sink { [weak self] fontGroupType in
                guard let self else { return }
                let customizations = self.manager.ui.customizations
                customizations.fontFamily = fontGroupType
            }
            .store(in: &cancellables)

        languageStrategyObservable
            .bind(to: userDefaultsProvider.setValues(key: UserDefaultsProvider.UDKey<OWLanguageStrategy>.languageStrategy))
            .store(in: &cancellables)

        localeStrategyObservable
            .bind(to: userDefaultsProvider.setValues(key: UserDefaultsProvider.UDKey<OWLocaleStrategy>.localeStrategy))
            .store(in: &cancellables)

        showLoginPromptSelected
            .dropFirst()
            .bind(to: userDefaultsProvider.setValues(key: UserDefaultsProvider.UDKey<Bool>.showLoginPrompt))
            .store(in: &cancellables)
    }
    // swiftlint:enable function_body_length
}

extension GeneralSettingsVM: SettingsGroupVMProtocol {
    func resetToDefault() {
        articleHeaderSelectedStyle.send(OWArticleHeaderStyle.default)
        articleInformationSelectedStrategy.send(OWArticleInformationStrategy.default)
        articleAssociatedSelectedURL.send("")
        articleSelectedSection.send("")
        elementsCustomizationStyleSelectedIndex.send(SettingsElementsCustomizationStyle.defaultIndex)
        colorsCustomizationStyleSelectedIndex.send(SettingsColorCustomizationStyle.defaultIndex)
        readOnlyModeSelectedIndex.send(OWReadOnlyMode.default.index)
        themeModeSelectedIndex.send(OWThemeStyleEnforcement.default.index)
        statusBarStyleSelectedIndex.send(OWStatusBarEnforcement.default.index)
        navigationBarStyleSelectedIndex.send(OWNavigationBarEnforcement.default.index)
        modalStyleSelectedIndex.send(OWModalPresentationStyle.default.index)
        initialSortSelectedIndex.send(OWInitialSortStrategy.default.index)
        fontGroupTypeSelectedIndex.send(OWFontGroupFamilyIndexer.`default`.index)
        languageStrategySelectedIndex.send(OWLanguageStrategy.defaultStrategyIndex)
        showLoginPromptSelected.send(false)
        orientationSelectedEnforcement.send(OWOrientationEnforcement.default)
        commentActionsColorSelected.send(OWCommentActionsColor.default)
        commentActionsFontStyleSelected.send(OWCommentActionsFontStyle.default)
    }
}

extension OWFontGroupFamily {
    var index: Int {
        switch self {
        case .custom:
            return 1
        default:
            return 0
        }
    }

    var name: String {
        switch self {
        case .custom(fontFamily: let fontFamily):
            return fontFamily
        default:
            return ""
        }
    }
}

extension OWLanguageStrategy {
    var index: Int {
        switch self {
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

    var name: String {
        switch self {
        case .use(language: let language):
            return language.languageName
        default:
            return OWSupportedLanguage.defaultLanguage.languageName
        }
    }
}
