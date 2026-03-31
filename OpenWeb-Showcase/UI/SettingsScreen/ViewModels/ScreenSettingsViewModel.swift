//
//  ScreenSettingsViewModel.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 08/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI
import Combine
import OpenWebSDK

class ScreenSettingsViewModel: NSObject, ObservableObject {

    // Pre Conversation
    @SDKSetting(SettingsItems.preConversationStyle) var selectedPreConversationStyle: PreConversationStyleSetting
    @SDKSetting(SettingsItems.numberOfComments) var numberOfComments: Int
    @SDKSetting(SettingsItems.preConversationGuidelinesStyle) var selectedPreConversationGuidelinesStyle: OWCommunityGuidelinesStyle
    @SDKSetting(SettingsItems.preConversationQuestionsStyle) var selectedPreConversationQuestionsStyle: OWCommunityQuestionStyle

    // Conversation
    @SDKSetting(SettingsItems.conversationStyle) var selectedConversationStyle: ConversationStyleSetting
    @SDKSetting(SettingsItems.conversationGuidelinesStyle) var selectedConversationGuidelinesStyle: OWCommunityGuidelinesStyle
    @SDKSetting(SettingsItems.conversationQuestionsStyle) var selectedConversationQuestionsStyle: OWCommunityQuestionStyle
    @SDKSetting(SettingsItems.conversationSpacing) var selectedConversationSpacing: ConversationSpacingSetting
    @SDKSetting(SettingsItems.betweenCommentsSpacing) var betweenCommentsSpacing: Double
    @SDKSetting(SettingsItems.guidelinesSpacing) var guidelinesSpacing: Double
    @SDKSetting(SettingsItems.questionsSpacing) var questionsSpacing: Double

    // General
    @SDKSetting(SettingsItems.enablePullToRefresh) var enablePullToRefresh: Bool

    var isNumberOfCommentsEnabled: Bool {
        selectedPreConversationStyle == .custom
    }

    var isCustomConversationEnabled: Bool {
        selectedConversationStyle == .custom
    }

    var isCustomSpacingEnabled: Bool {
        isCustomConversationEnabled && selectedConversationSpacing == .custom
    }

}

// MARK: - Setting Enums

extension ScreenSettingsViewModel {
    enum PreConversationStyleSetting: Codable, CaseIterable, Identifiable {
        case regular
        case compact
        case summary
        case buttonOnly
        case custom

        var id: Self { self }
        var title: String {
            switch self {
            case .regular: "Regular"
            case .compact: "Compact"
            case .summary: "Summary"
            case .buttonOnly: "Button Only"
            case .custom: "Custom"
            }
        }
    }

    enum ConversationStyleSetting: Codable, CaseIterable, Identifiable {
        case regular
        case compact
        case custom

        var id: Self { self }
        var title: String {
            switch self {
            case .regular: "Regular"
            case .compact: "Compact"
            case .custom: "Custom"
            }
        }
    }

    enum ConversationSpacingSetting: Codable, CaseIterable, Identifiable {
        case regular
        case compact
        case custom

        var id: Self { self }
        var title: String {
            switch self {
            case .regular: "Regular"
            case .compact: "Compact"
            case .custom: "Custom"
            }
        }
    }
}
