//
//  SettingsViewModel.swift
//  Spot-IM.Development
//
//  Created by Revital Pisman on 18/12/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift
import SpotImCore

#if NEW_API

protocol SettingsViewModelingInputs {
    var hideArticleHeaderToggled: PublishSubject<Bool> { get }
    var commentCreationNewDesignToggled: PublishSubject<Bool> { get }
    var readOnlyModeSelectedIndex: PublishSubject<Int> { get }
    var themeModeSelectedIndex: PublishSubject<Int> { get }
    var modalStyleSelectedIndex: PublishSubject<Int> { get }
    var initialSortSelectedIndex: PublishSubject<Int> { get }
    var articleAssociatedSelectedURL: PublishSubject<String?> { get }
}

protocol SettingsViewModelingOutputs {
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
    var initialSortSettings: [String] { get }
    var shouldHideArticleHeader: Observable<Bool> { get }
    var shouldCommentCreationNewDesign: Observable<Bool> { get }
    var readOnlyModeIndex: Observable<Int> { get }
    var themeModeIndex: Observable<Int> { get }
    var modalStyleIndex: Observable<Int> { get }
    var initialSortIndex: Observable<Int> { get }
    var articleAssociatedURL: Observable<String> { get }
}

protocol SettingsViewModeling {
    var inputs: SettingsViewModelingInputs { get }
    var outputs: SettingsViewModelingOutputs { get }
}

class SettingsViewModel: SettingsViewModeling, SettingsViewModelingInputs, SettingsViewModelingOutputs {
    var inputs: SettingsViewModelingInputs { return self }
    var outputs: SettingsViewModelingOutputs { return self }

    var hideArticleHeaderToggled = PublishSubject<Bool>()
    var commentCreationNewDesignToggled = PublishSubject<Bool>()
    var readOnlyModeSelectedIndex = PublishSubject<Int>()
    var themeModeSelectedIndex = PublishSubject<Int>()
    var modalStyleSelectedIndex = PublishSubject<Int>()
    var initialSortSelectedIndex = PublishSubject<Int>()
    var articleAssociatedSelectedURL = PublishSubject<String?>()

    fileprivate var userDefaultsProvider: UserDefaultsProviderProtocol
    fileprivate var manager: OWManagerProtocol

    var shouldHideArticleHeader: Observable<Bool> {
        return userDefaultsProvider.values(key: .hideArticleHeader, defaultValue: false)
    }

    var shouldCommentCreationNewDesign: Observable<Bool> {
        return userDefaultsProvider.values(key: .showCommentCreationNewDesign, defaultValue: false)
    }

    var readOnlyModeIndex: Observable<Int> {
        return userDefaultsProvider.values(key: .readOnlyModeIndex, defaultValue: 0)
    }

    var themeModeIndex: Observable<Int> {
        return userDefaultsProvider.values(key: .themeModeIndex, defaultValue: 0)
    }

    var modalStyleIndex: Observable<Int> {
        return userDefaultsProvider.values(key: .modalStyleIndex, defaultValue: 0)
    }

    var initialSortIndex: Observable<Int> {
        return userDefaultsProvider.values(key: .initialSortIndex, defaultValue: 0)
    }

    var articleAssociatedURL: Observable<String> {
        return userDefaultsProvider.values(key: .articleAssociatedURL)
    }

    fileprivate let disposeBag = DisposeBag()

    lazy var title: String = {
        return NSLocalizedString("Settings", comment: "")
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

    init(userDefaultsProvider: UserDefaultsProviderProtocol = UserDefaultsProvider.shared,
         manager: OWManagerProtocol = OpenWeb.manager) {
        self.userDefaultsProvider = userDefaultsProvider
        self.manager = manager
        setupObservers()
    }
}

extension SettingsViewModel {
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

        articleAssociatedSelectedURL
            .skip(1)
            .bind(to: userDefaultsProvider.rxProtocol
            .setValues(key: UserDefaultsProvider.UDKey<String?>.articleAssociatedURL))
            .disposed(by: disposeBag)

        themeModeSelectedIndex // 0. default 1. light 2. dark
            .subscribe(onNext: { [weak self] index in
                guard let self = self else { return }
                var customizations = self.manager.ui.customizations
                customizations.themeEnforcement = .themeFromPersistence(index: index)
            })
            .disposed(by: disposeBag)
    }
}

#endif
