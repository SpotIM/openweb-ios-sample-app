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

protocol OpenWebApplicable {
    func applyToSDK()
}

class SettingsManager: ObservableObject {
    static let shared = SettingsManager()

    private static let suiteName = "com.open-web.showcase-app"
    static let store = UserDefaults(suiteName: suiteName) ?? UserDefaults.standard
    private let defaults: UserDefaults = SettingsManager.store

    @SDKSetting(SettingsItems.informationStrategy) private var informationStrategy: ArticleSettingsViewModel.InformationStrategySetting
    @SDKSetting(SettingsItems.articleAssociatedURL) private var articleAssociatedURL: String
    @SDKSetting(SettingsItems.hideArticleHeader) private var hideArticleHeader: Bool
    @SDKSetting(SettingsItems.readOnlyMode) private var readOnlyMode: ArticleSettingsViewModel.ReadOnlyModeSetting
    @SDKSetting(SettingsItems.preConversationStyle) private var preConversationStyle: ScreenSettingsViewModel.PreConversationStyleSetting
    @SDKSetting(SettingsItems.numberOfComments) private var numberOfComments: Int
    @SDKSetting(SettingsItems.preConversationGuidelinesStyle) private var preConversationGuidelinesStyle: ScreenSettingsViewModel.GuidelinesStyleSetting
    @SDKSetting(SettingsItems.preConversationQuestionsStyle) private var preConversationQuestionsStyle: ScreenSettingsViewModel.QuestionsStyleSetting
    @SDKSetting(SettingsItems.conversationStyle) private var conversationStyle: ScreenSettingsViewModel.ConversationStyleSetting
    @SDKSetting(SettingsItems.conversationGuidelinesStyle) private var conversationGuidelinesStyle: ScreenSettingsViewModel.GuidelinesStyleSetting
    @SDKSetting(SettingsItems.conversationQuestionsStyle) private var conversationQuestionsStyle: ScreenSettingsViewModel.QuestionsStyleSetting
    @SDKSetting(SettingsItems.conversationSpacing) private var conversationSpacing: ScreenSettingsViewModel.ConversationSpacingSetting
    @SDKSetting(SettingsItems.betweenCommentsSpacing) private var betweenCommentsSpacing: String
    @SDKSetting(SettingsItems.guidelinesSpacing) private var guidelinesSpacing: String
    @SDKSetting(SettingsItems.questionsSpacing) private var questionsSpacing: String
    @SDKSetting(SettingsItems.enablePullToRefresh) private var enablePullToRefresh: Bool

    private init() {}

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
            preConversationStyle: owPreConversationStyle,
            conversationStyle: owConversationStyle,
            allowPullToRefresh: enablePullToRefresh
        )
    }

    static let didResetNotification = Notification.Name("SettingsManagerDidReset")

    func resetAll() {
        defaults.removePersistentDomain(forName: Self.suiteName)
        SettingsItems.allItems.forEach { $0.applyDefaultToSDK() }
        NotificationCenter.default.post(name: Self.didResetNotification, object: nil)
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

    var owConversationStyle: OWConversationStyle {
        switch conversationStyle {
        case .regular: .regular
        case .compact: .compact
        case .custom: .custom(
            communityGuidelinesStyle: conversationGuidelinesStyle.owGuidelinesStyle,
            communityQuestionsStyle: conversationQuestionsStyle.owQuestionsStyle,
            spacing: owConversationSpacing
        )
        }
    }

    var owConversationSpacing: OWConversationSpacing {
        switch conversationSpacing {
        case .regular: .regular
        case .compact: .compact
        case .custom: .custom(
            betweenComments: CGFloat(Double(betweenCommentsSpacing) ?? OWConversationSpacing.Metrics.defaultSpaceBetweenComments),
            communityGuidelines: CGFloat(Double(guidelinesSpacing) ?? OWConversationSpacing.Metrics.defaultSpaceCommunityGuidelines),
            communityQuestions: CGFloat(Double(questionsSpacing) ?? OWConversationSpacing.Metrics.defaultSpaceCommunityQuestions)
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
