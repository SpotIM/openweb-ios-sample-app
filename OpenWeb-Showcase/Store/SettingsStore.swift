//
//  SettingsStore.swift
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

class SettingsStore: NSObject, ObservableObject {
    static let shared = SettingsStore()

    private static let suiteName = "com.open-web.showcase-app"
    static let store = UserDefaults(suiteName: suiteName) ?? UserDefaults.standard

    @SDKSetting(SettingsItems.informationStrategy) private var informationStrategy: ArticleSettingsViewModel.InformationStrategySetting
    @SDKSetting(SettingsItems.articleAssociatedURL) private var articleAssociatedURL: String
    @SDKSetting(SettingsItems.hideArticleHeader) private var hideArticleHeader: Bool
    @SDKSetting(SettingsItems.readOnlyMode) private var readOnlyMode: OWReadOnlyMode
    @SDKSetting(SettingsItems.preConversationStyle) private var preConversationStyle: ScreenSettingsViewModel.PreConversationStyleSetting
    @SDKSetting(SettingsItems.numberOfComments) private var numberOfComments: Int
    @SDKSetting(SettingsItems.preConversationGuidelinesStyle) private var preConversationGuidelinesStyle: OWCommunityGuidelinesStyle
    @SDKSetting(SettingsItems.preConversationQuestionsStyle) private var preConversationQuestionsStyle: OWCommunityQuestionStyle
    @SDKSetting(SettingsItems.conversationStyle) private var conversationStyle: ScreenSettingsViewModel.ConversationStyleSetting
    @SDKSetting(SettingsItems.conversationGuidelinesStyle) private var conversationGuidelinesStyle: OWCommunityGuidelinesStyle
    @SDKSetting(SettingsItems.conversationQuestionsStyle) private var conversationQuestionsStyle: OWCommunityQuestionStyle
    @SDKSetting(SettingsItems.conversationSpacing) private var conversationSpacing: ScreenSettingsViewModel.ConversationSpacingSetting
    @SDKSetting(SettingsItems.betweenCommentsSpacing) private var betweenCommentsSpacing: Double
    @SDKSetting(SettingsItems.guidelinesSpacing) private var guidelinesSpacing: Double
    @SDKSetting(SettingsItems.questionsSpacing) private var questionsSpacing: Double
    @SDKSetting(SettingsItems.enablePullToRefresh) private var enablePullToRefresh: Bool

    private override init() {}

    // MARK: OpenWeb SDK
    var article: OWArticle {
        OWArticle(
            articleInformationStrategy: owInformationStrategy,
            additionalSettings: OWArticleSettings(
                headerStyle: hideArticleHeader ? .none : .regular,
                readOnlyMode: readOnlyMode
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

    static let didReset = PassthroughSubject<Void, Never>()

    func resetAll() {
        Self.store.removePersistentDomain(forName: Self.suiteName)
        SettingsItems.allItems.forEach { $0.applyDefaultToSDK() }
        Self.didReset.send()
    }
}

// MARK: - Private

private extension SettingsStore {
    var owPreConversationStyle: OWPreConversationStyle {
        switch preConversationStyle {
        case .regular: .regular
        case .compact: .compact
        case .summary: .ctaWithSummary(
            communityGuidelinesStyle: preConversationGuidelinesStyle,
            communityQuestionsStyle: preConversationQuestionsStyle
        )
        case .buttonOnly: .ctaButtonOnly
        case .custom: .custom(
            numberOfComments: numberOfComments,
            communityGuidelinesStyle: preConversationGuidelinesStyle,
            communityQuestionsStyle: preConversationQuestionsStyle
        )
        }
    }

    var owConversationStyle: OWConversationStyle {
        switch conversationStyle {
        case .regular: .regular
        case .compact: .compact
        case .custom: .custom(
            communityGuidelinesStyle: conversationGuidelinesStyle,
            communityQuestionsStyle: conversationQuestionsStyle,
            spacing: owConversationSpacing
        )
        }
    }

    var owConversationSpacing: OWConversationSpacing {
        switch conversationSpacing {
        case .regular: .regular
        case .compact: .compact
        case .custom: .custom(
            betweenComments: betweenCommentsSpacing,
            communityGuidelines: guidelinesSpacing,
            communityQuestions: questionsSpacing
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
