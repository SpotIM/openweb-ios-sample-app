//
//  UserDefaultsProvider.swift
//  OpenWeb-Development
//
//  Created by Refael Sommer on 08/12/2022.
//  Copyright © 2022 OpenWeb. All rights reserved.
//

import Foundation
import Combine

protocol UserDefaultsProviderProtocol: UserDefaultsProviderCombineProtocol {
    func get<T: Codable>(key: UserDefaultsProvider.UDKey<T>) -> T?
    func get<T: Codable>(key: UserDefaultsProvider.UDKey<T>, defaultValue: T) -> T
    func save<T: Codable>(value: T, forKey key: UserDefaultsProvider.UDKey<T>)
    func remove<T: Codable>(key: UserDefaultsProvider.UDKey<T>)
}

protocol UserDefaultsProviderCombineProtocol {
    func values<T: Codable>(key: UserDefaultsProvider.UDKey<T>) -> AnyPublisher<T, Never>
    func values<T: Codable>(key: UserDefaultsProvider.UDKey<T>, defaultValue: T?) -> AnyPublisher<T, Never>
    func setValues<T: Codable>(key: UserDefaultsProvider.UDKey<T>) -> AnySubscriber<T, Never>
}

class UserDefaultsProvider: UserDefaultsProviderProtocol {
    // Singleton
    static let shared: UserDefaultsProviderProtocol = UserDefaultsProvider()

    private struct Metrics {
        static let suiteName = "com.open-web.demo-app"
    }

    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = UserDefaults(suiteName: Metrics.suiteName) ?? UserDefaults.standard) {
        self.userDefaults = userDefaults
    }

    func save<T: Codable>(value: T, forKey key: UDKey<T>) {
        userDefaults.set(Data(encoding: value), forKey: key.rawValue)
    }

    func get<T: Codable>(key: UDKey<T>) -> T? {
        return userDefaults.data(forKey: key.rawValue)?.asType(T.self)
    }

    func get<T: Codable>(key: UDKey<T>, defaultValue: T) -> T {
        return get(key: key) ?? defaultValue
    }

    func remove<T: Codable>(key: UDKey<T>) {
        userDefaults.removeObject(forKey: key.rawValue)
    }

    enum UDKey<T: Codable>: String {
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
        case notificationsStyle = "notificationsCustomStyleModeSelected"
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
        case callingMethodOption
        case flowsLoggerEnabled
        case starRatingEnabled
    }
}

extension UserDefaultsProvider: UserDefaultsProviderCombineProtocol {
    func values<T: Codable>(key: UDKey<T>) -> AnyPublisher<T, Never> {
        values(key: key, defaultValue: nil)
    }

    func values<T: Codable>(key: UDKey<T>, defaultValue: T?) -> AnyPublisher<T, Never> {
        return userDefaults.dataPublisher(for: key.rawValue)
            .map { data in
                data?.asType(T.self) ?? defaultValue
            }
            .unwrap()
            .eraseToAnyPublisher()
    }

    func setValues<T: Codable>(key: UDKey<T>) -> AnySubscriber<T, Never> {
        AnySubscriber(Subscribers.Sink(
            receiveCompletion: { _ in },
            receiveValue: { [weak self] value in
                self?.save(value: value, forKey: key)
            }
        ))
    }
}

extension UserDefaults {
    func dataPublisher(for key: String) -> AnyPublisher<Data?, Never> {
        NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)
            .map { [weak self] _ in self?.data(forKey: key) }
            .prepend(data(forKey: key))
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
}
