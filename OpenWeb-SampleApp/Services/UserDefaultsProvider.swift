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
        case shouldShowOpenFullConversation
        case shouldPresentInNewNavStack
        case shouldOpenComment
        case isCustomDarkModeEnabled = "demo.isCustomDarkModeEnabled"
        case isReadOnlyEnabled = "demo.isReadOnlyEnabled"
        case interfaceStyle = "demo.interfaceStyle"
        case spotIdKey
        case articleHeaderStyle
        case articleInformationStrategy
        case elementsCustomizationStyleIndex
        case colorCustomizationStyleIndex
        case colorCustomizationCustomTheme
        case readOnlyModeIndex
        case themeModeIndex = "themeModeSelectedIndex"
        case statusBarStyleIndex
        case navigationBarStyleIndex
        case modalStyleIndex
        case initialSortIndex
        case customSortTitles
        case fontGroupType
        case articleAssociatedURL
        case articleSection
        case preConversationStyle = "preConversationCustomStyle"
        case conversationStyle = "conversationCustomStyleModeSelected"
        case commentCreationStyle = "commentCreationCustomStyleModeSelected"
        case networkEnvironment = "networkEnvironmentSelected"
        case languageStrategy
        case localeStrategy
        case openCommentId
        case showLoginPrompt
        case orientationEnforcement
        case selectedSpotId
        case selectedPostId
        case deeplinkOption
        case commentActionsColor
        case commentActionsFontStyle
        case flowsLoggerEnabled
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
