//
//  SettingsManager.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 08/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import Foundation
import OpenWebSDK
import Combine

protocol SDKApplicable {
    func applyToSDK()
}

class SettingsManager: ObservableObject {
    static let shared = SettingsManager()

    private static let suiteName = "com.open-web.showcase-app"
    static let store = UserDefaults(suiteName: suiteName) ?? UserDefaults.standard
    private let defaults: UserDefaults = SettingsManager.store
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    @SDKSetting(SettingsItems.informationStrategy) private var informationStrategy: ArticleSettingsViewModel.InformationStrategySetting
    @SDKSetting(SettingsItems.articleAssociatedURL) private var articleAssociatedURL: String
    @SDKSetting(SettingsItems.hideArticleHeader) private var hideArticleHeader: Bool
    @SDKSetting(SettingsItems.readOnlyMode) private var readOnlyMode: ArticleSettingsViewModel.ReadOnlyModeSetting
    @SDKSetting(SettingsItems.preConversationStyle) private var preConversationStyle: ScreenSettingsViewModel.PreConversationStyleSetting
    @SDKSetting(SettingsItems.numberOfComments) private var numberOfComments: Int
    @SDKSetting(SettingsItems.preConversationGuidelinesStyle) private var preConversationGuidelinesStyle: ScreenSettingsViewModel.GuidelinesStyleSetting
    @SDKSetting(SettingsItems.preConversationQuestionsStyle) private var preConversationQuestionsStyle: ScreenSettingsViewModel.QuestionsStyleSetting

    private init() {}

    func get<T: Codable>(_ item: SettingsItem<T>) -> T {
        guard let data = defaults.data(forKey: item.key) else { return item.defaultValue }
        return (try? decoder.decode(T.self, from: data)) ?? item.defaultValue
    }

    func set<T: Codable>(_ item: SettingsItem<T>, value: T) {
        if let data = try? encoder.encode(value) {
            defaults.set(data, forKey: item.key)
        }
        (value as? SDKApplicable)?.applyToSDK()
    }

    // MARK: OpenWeb SDK
    var article: OWArticle {
        OWArticle(
            articleInformationStrategy: owInformationStrategy,
            additionalSettings: OWArticleSettings(
                headerStyle: hideArticleHeader ? .none : .regular,
                readOnlyMode: readOnlyMode.owMode
            )
        )
    }

    var additionalSettings: OWAdditionalSettings {
        OWAdditionalSettings(
            preConversationStyle: owPreConversationStyle
        )
    }

    func resetAll() {
        defaults.removePersistentDomain(forName: Self.suiteName)
        SettingsItems.allItems.forEach { $0.applyDefaultToSDK() }
    }
}

// MARK: - Private

private extension SettingsManager {
    var owPreConversationStyle: OWPreConversationStyle {
        switch preConversationStyle {
        case .regular: .regular
        case .compact: .compact
        case .summary: .ctaWithSummary(
            communityGuidelinesStyle: preConversationGuidelinesStyle.owGuidelinesStyle,
            communityQuestionsStyle: preConversationQuestionsStyle.owQuestionsStyle
        )
        case .buttonOnly: .ctaButtonOnly
        case .custom: .custom(
            numberOfComments: numberOfComments,
            communityGuidelinesStyle: preConversationGuidelinesStyle.owGuidelinesStyle,
            communityQuestionsStyle: preConversationQuestionsStyle.owQuestionsStyle
        )
        }
    }

    var owInformationStrategy: OWArticleInformationStrategy {
        switch informationStrategy {
        case .server: .server
        case .local:
            .local(data: OWArticleExtraData(
                url: URL(string: articleAssociatedURL) ?? URL(string: "https://test.com")!,
                title: "This is a placeholder for the article title. The container is limited to two lines of text to avoid interface overwhelming but will show the context",
                subtitle: "Showcase App",
                thumbnailUrl: URL(string: "https://53.fs1.hubspotusercontent-na1.net/hub/53/hubfs/parts-url.jpg?width=595&height=400&name=parts-url.jpg")
            ))
        }
    }
}
