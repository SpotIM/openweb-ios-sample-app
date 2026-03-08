//
//  ScreenSettingsViewModel.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 08/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI
import Combine

class ScreenSettingsViewModel: ObservableObject {
    // Pre Conversation
    @Published var selectedPreConversationStyle: PreConversationStyleSetting = .regular
    @Published var numberOfComments: Int = 3
    @Published var selectedPreConversationGuidelinesStyle: GuidelinesStyleSetting = .regular
    @Published var selectedPreConversationQuestionsStyle: QuestionsStyleSetting = .regular

    // Conversation
    @Published var selectedConversationStyle: ConversationStyleSetting = .regular
    @Published var selectedConversationGuidelinesStyle: GuidelinesStyleSetting = .regular
    @Published var selectedConversationQuestionsStyle: QuestionsStyleSetting = .regular
    @Published var selectedConversationSpacing: ConversationSpacingSetting = .regular
    @Published var betweenCommentsSpacing: String = "16"
    @Published var guidelinesSpacing: String = "12"
    @Published var questionsSpacing: String = "12"

    // General
    @Published var enablePullToRefresh: Bool = true

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
    enum PreConversationStyleSetting: CaseIterable, Identifiable {
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

    enum ConversationStyleSetting: CaseIterable, Identifiable {
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

    enum GuidelinesStyleSetting: CaseIterable, Identifiable {
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

    enum QuestionsStyleSetting: CaseIterable, Identifiable {
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

    enum ConversationSpacingSetting: CaseIterable, Identifiable {
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
