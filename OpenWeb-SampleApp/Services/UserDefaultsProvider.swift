//
//  UserDefaultsProvider.swift
//  OpenWeb-Development
//
//  Created by Refael Sommer on 08/12/2022.
//  Copyright © 2022 OpenWeb. All rights reserved.
//

import Foundation
import RxSwift

protocol UserDefaultsProviderProtocol: UserDefaultsProviderRxProtocol {
    func get<T>(key: UserDefaultsProvider.UDKey<T>) -> T?
    func get<T>(key: UserDefaultsProvider.UDKey<T>, defaultValue: T) -> T
    func save<T>(value: T, forKey key: UserDefaultsProvider.UDKey<T>)
    func remove<T>(key: UserDefaultsProvider.UDKey<T>)
    var rxProtocol: UserDefaultsProviderRxProtocol { get }
}

protocol UserDefaultsProviderRxProtocol {
    func values<T>(key: UserDefaultsProvider.UDKey<T>, defaultValue: T?) -> Observable<T>
    func values<T>(key: UserDefaultsProvider.UDKey<T>) -> Observable<T>
    func setValues<T>(key: UserDefaultsProvider.UDKey<T>) -> Binder<T>
}

class UserDefaultsProvider: ReactiveCompatible, UserDefaultsProviderProtocol {
    // Singleton
    static let shared: UserDefaultsProviderProtocol = UserDefaultsProvider()

    var rxProtocol: UserDefaultsProviderRxProtocol { return self }
    fileprivate var rxHelper: UserDefaultsProviderRxHelperProtocol

    private struct Metrics {
        static let suiteName = "com.open-web.demo-app"
    }

    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = UserDefaults(suiteName: Metrics.suiteName) ?? UserDefaults.standard,
         encoder: JSONEncoder = JSONEncoder(),
         decoder: JSONDecoder = JSONDecoder()) {
        self.userDefaults = userDefaults
        self.encoder = encoder
        self.decoder = decoder
        self.rxHelper = UserDefaultsProviderRxHelper(decoder: decoder, encoder: encoder)
    }

    func save<T>(value: T, forKey key: UDKey<T>) {
        guard let encodedData = try? encoder.encode(value) else {
            DLog("Failed to encode data for key: \(key.rawValue) before writing to UserDefaults")
            return
        }

        rxHelper.onNext(key: key, data: encodedData)

        _save(data: encodedData, forKey: key)
    }

    func get<T>(key: UDKey<T>) -> T? {
        guard let data = _get(key: key) else {
            return nil
        }

        guard let valueToReturn = try? decoder.decode(T.self, from: data) else {
            DLog("Failed to decode data for key: \(key.rawValue) to class: \(T.self) after retrieving from UserDefaults")
            return nil
        }

        return valueToReturn
    }

    func get<T>(key: UDKey<T>, defaultValue: T) -> T {
        return get(key: key) ?? defaultValue
    }

    func remove<T>(key: UDKey<T>) {
        _remove(key: key)
    }

    enum UDKey<T: Codable>: String {
        case shouldShowOpenFullConversation = "shouldShowOpenFullConversation"
        case shouldPresentInNewNavStack = "shouldPresentInNewNavStack"
        case shouldOpenComment = "shouldOpenComment"
        case isCustomDarkModeEnabled = "demo.isCustomDarkModeEnabled"
        case isReadOnlyEnabled = "demo.isReadOnlyEnabled"
        case interfaceStyle = "demo.interfaceStyle"
        case spotIdKey = "spotIdKey"
        case articleHeaderStyle = "articleHeaderStyle"
        case articleInformationStrategy = "articleInformationStrategy"
        case elementsCustomizationStyleIndex = "elementsCustomizationStyleIndex"
        case colorCustomizationStyleIndex = "colorCustomizationStyleIndex"
        case colorCustomizationCustomTheme = "colorCustomizationCustomTheme"
        case readOnlyModeIndex = "readOnlyModeIndex"
        case themeModeIndex = "themeModeSelectedIndex"
        case statusBarStyleIndex = "statusBarStyleIndex"
        case navigationBarStyleIndex = "navigationBarStyleIndex"
        case modalStyleIndex = "modalStyleIndex"
        case initialSortIndex = "initialSortIndex"
        case fontGroupType = "fontGroupType"
        case articleAssociatedURL = "articleAssociatedURL"
        case articleSection = "articleSection"
        case preConversationStyle = "preConversationCustomStyle"
        case conversationStyle = "conversationCustomStyleModeSelected"
        case commentCreationStyle = "commentCreationCustomStyleModeSelected"
        case networkEnvironment = "networkEnvironmentSelected"
        case languageStrategy = "languageStrategy"
        case localeStrategy = "localeStrategy"
        case openCommentId = "openCommentId"
        case showLoginPrompt = "showLoginPrompt"
        case orientationEnforcement = "orientationEnforcement"
        case selectedSpotId = "selectedSpotId"
        case selectedPostId = "selectedPostId"
        case deeplinkOption = "deeplinkOption"
        case commentActionsColor = "commentActionsColor"
        case commentActionsFontStyle = "commentActionsFontStyle"
    }
}

extension UserDefaultsProvider {
    func values<T>(key: UserDefaultsProvider.UDKey<T>) -> Observable<T> {
        return rx.values(key: key, defaultValue: nil)
    }

    func values<T>(key: UserDefaultsProvider.UDKey<T>, defaultValue: T? = nil) -> Observable<T> {
        return rx.values(key: key, defaultValue: defaultValue)
    }

    func setValues<T>(key: UserDefaultsProvider.UDKey<T>) -> Binder<T> {
        return rx.setValues(key: key)
    }
}

private extension UserDefaultsProvider.UDKey {
    // Add description for better understanding of future cases (keys)
    var description: String {
        switch self {
        case .shouldShowOpenFullConversation:
            return "Key which stores if we should open full conversation"
        case .shouldPresentInNewNavStack:
            return "Key which stores if we should present in a new navigation or push in the existing one"
        case .shouldOpenComment:
            return "Key which stores if we should show create comment button"
        case .isCustomDarkModeEnabled:
            return "Key which stores if we should override system's dark mode"
        case .isReadOnlyEnabled:
            return "Key which stores if read only mode is enabled"
        case .interfaceStyle:
            return "Key which stores if we should override system's interface style (light, dark)"
        case .spotIdKey:
            return "Key which stores the current spot id to be tested"
        case .articleHeaderStyle:
            return "Key which stores article header style"
        case .articleInformationStrategy:
            return "Key which stores article information strategy (server, custom)"
        case .readOnlyModeIndex:
            return "Key which stores read only mode (default, enabled, disabled)"
        case .themeModeIndex:
            return "Key which stores the theme mode (default, light, dark)"
        case .statusBarStyleIndex:
            return "Key which stores the status bar style (matchTheme, lightContent, darkContent)"
        case .navigationBarStyleIndex:
            return "Key which stores the navigation bar style (largeTitles, regular, keepOriginal)"
        case .modalStyleIndex:
            return "Key which stores modal style (full screen, page sheet)"
        case .initialSortIndex:
            return "Key which stores initial sort (server, best, newest, oldest)"
        case .articleAssociatedURL:
            return "Key which stores injected article url for easy testing"
        case .articleSection:
            return "Key which stores article section for easy testing"
        case .preConversationStyle:
            return "Key which stores pre conversation's style"
        case .conversationStyle:
            return "Key which stores conversation's style"
        case .commentCreationStyle:
            return "Key which stores comment creation style"
        case .networkEnvironment:
            return "Key which stores network environment"
        case .fontGroupType:
            return "Key which stores general setting's font type"
        case .languageStrategy:
            return "Key which stores general setting's language strategy"
        case .localeStrategy:
            return "Key which stores general setting's locale strategy"
        case .openCommentId:
            return "Key which stores comment thread setting's comment id to open"
        case .showLoginPrompt:
            return "Key which stores general setting's show login prompt (if needed)"
        case .orientationEnforcement:
            return "Key wich stores general setting's orientation enforcement"
        case .elementsCustomizationStyleIndex:
            return "Key which stores general setting's elements customization style index"
        case .colorCustomizationStyleIndex:
            return "Key which stores general setting's color customization style index"
        case .colorCustomizationCustomTheme:
            return "Key which stores general setting's OWTheme color for custom colors override"
        case .selectedSpotId:
            return "Key which stores the current spot id"
        case .selectedPostId:
            return "Key which stores the current post id"
        case .deeplinkOption:
            return "Key which stores the SampleApp deeplink option"
        case .commentActionsColor:
            return "Key which stores the comment action's color"
        case .commentActionsFontStyle:
            return "Key which stores the comment action's font style"
        }
    }
}

private extension UserDefaultsProvider {
    func _save<T>(data: Data, forKey key: UDKey<T>) {
        DLog("Writing data to UserDefaults for key: \(key.rawValue)")
        userDefaults.set(data, forKey: key.rawValue)
    }

    func _get<T>(key: UDKey<T>) -> Data? {
        DLog("retrieving data from UserDefaults for key: \(key.rawValue)")
        return userDefaults.data(forKey: key.rawValue)
    }

    func _remove<T>(key: UDKey<T>) {
        DLog("Removing data from UserDefaults for key: \(key.rawValue)")
        userDefaults.removeObject(forKey: key.rawValue)
    }
}

private extension Reactive where Base: UserDefaultsProvider {
    func setValues<T>(key: UserDefaultsProvider.UDKey<T>) -> Binder<T> {
        return base.rxHelper.binder(key: key) { value in
            base.save(value: value, forKey: key)
        }
    }

    func values<T>(key: UserDefaultsProvider.UDKey<T>, defaultValue: T? = nil) -> Observable<T> {
        return base.rxHelper.observable(key: key, value: base._get(key: key), defaultValue: defaultValue)
    }
}
