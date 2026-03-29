//
//  ScreenSettingsViewModel.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 08/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI
import Combine

class ScreenSettingsViewModel: NSObject, ObservableObject {

    // Pre Conversation
    @SDKSetting(SettingsItems.preConversationStyle) var selectedPreConversationStyle: PreConversationStyleSetting
    @SDKSetting(SettingsItems.numberOfComments) var numberOfComments: Int
    @SDKSetting(SettingsItems.preConversationGuidelinesStyle) var selectedPreConversationGuidelinesStyle: GuidelinesStyleSetting
    @SDKSetting(SettingsItems.preConversationQuestionsStyle) var selectedPreConversationQuestionsStyle: QuestionsStyleSetting

    // Conversation
    @SDKSetting(SettingsItems.conversationStyle) var selectedConversationStyle: ConversationStyleSetting
    @SDKSetting(SettingsItems.conversationGuidelinesStyle) var selectedConversationGuidelinesStyle: GuidelinesStyleSetting
    @SDKSetting(SettingsItems.conversationQuestionsStyle) var selectedConversationQuestionsStyle: QuestionsStyleSetting
    @SDKSetting(SettingsItems.conversationSpacing) var selectedConversationSpacing: ConversationSpacingSetting
    @SDKSetting(SettingsItems.betweenCommentsSpacing) var betweenCommentsSpacing: String
    @SDKSetting(SettingsItems.guidelinesSpacing) var guidelinesSpacing: String
    @SDKSetting(SettingsItems.questionsSpacing) var questionsSpacing: String

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

    enum GuidelinesStyleSetting: Codable, CaseIterable, Identifiable {
        case none
        case regular
        case compact

        var id: Self { self }
        var title: String {
            switch self {
            case .none: "None"
            case .regular: "Regular"
            case .compact: "Compact"
            }
        }
    }

    enum QuestionsStyleSetting: Codable, CaseIterable, Identifiable {
        case none
        case regular
        case compact

        var id: Self { self }
        var title: String {
            switch self {
            case .none: "None"
            case .regular: "Regular"
            case .compact: "Compact"
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
