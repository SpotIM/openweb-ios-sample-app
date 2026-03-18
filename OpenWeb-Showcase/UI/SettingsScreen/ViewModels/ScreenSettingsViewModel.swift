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
    private let manager = SettingsManager.shared
    private var cancellables = Set<AnyCancellable>()

    // Pre Conversation
    @SDKSetting(SettingsItems.preConversationStyle) var selectedPreConversationStyle: PreConversationStyleSetting
    @SDKSetting(SettingsItems.numberOfComments) var numberOfComments: Int
    @SDKSetting(SettingsItems.preConversationGuidelinesStyle) var selectedPreConversationGuidelinesStyle: GuidelinesStyleSetting
    @SDKSetting(SettingsItems.preConversationQuestionsStyle) var selectedPreConversationQuestionsStyle: QuestionsStyleSetting

    // Conversation
    @Published var selectedConversationStyle: ConversationStyleSetting = SettingsItems.conversationStyle.defaultValue
    @Published var selectedConversationGuidelinesStyle: GuidelinesStyleSetting = SettingsItems.conversationGuidelinesStyle.defaultValue
    @Published var selectedConversationQuestionsStyle: QuestionsStyleSetting = SettingsItems.conversationQuestionsStyle.defaultValue
    @Published var selectedConversationSpacing: ConversationSpacingSetting = SettingsItems.conversationSpacing.defaultValue
    @Published var betweenCommentsSpacing: String = SettingsItems.betweenCommentsSpacing.defaultValue
    @Published var guidelinesSpacing: String = SettingsItems.guidelinesSpacing.defaultValue
    @Published var questionsSpacing: String = SettingsItems.questionsSpacing.defaultValue

    // General
    @Published var enablePullToRefresh: Bool = SettingsItems.enablePullToRefresh.defaultValue

    var isNumberOfCommentsEnabled: Bool {
        selectedPreConversationStyle == .custom
    }

    var isCustomConversationEnabled: Bool {
        selectedConversationStyle == .custom
    }

    var isCustomSpacingEnabled: Bool {
        isCustomConversationEnabled && selectedConversationSpacing == .custom
    }

    init() {
        loadSettings()
        observeChanges()
    }

    func loadSettings() {
        selectedConversationStyle = manager.get(SettingsItems.conversationStyle)
        selectedConversationGuidelinesStyle = manager.get(SettingsItems.conversationGuidelinesStyle)
        selectedConversationQuestionsStyle = manager.get(SettingsItems.conversationQuestionsStyle)
        selectedConversationSpacing = manager.get(SettingsItems.conversationSpacing)
        betweenCommentsSpacing = manager.get(SettingsItems.betweenCommentsSpacing)
        guidelinesSpacing = manager.get(SettingsItems.guidelinesSpacing)
        questionsSpacing = manager.get(SettingsItems.questionsSpacing)
        enablePullToRefresh = manager.get(SettingsItems.enablePullToRefresh)
    }
}

// MARK: - Private

private extension ScreenSettingsViewModel {
    func observeChanges() {
        $selectedConversationStyle.dropFirst().sink { [weak self] in self?.manager.set(SettingsItems.conversationStyle, value: $0) }.store(in: &cancellables)
        $selectedConversationGuidelinesStyle.dropFirst().sink { [weak self] in self?.manager.set(SettingsItems.conversationGuidelinesStyle, value: $0) }.store(in: &cancellables)
        $selectedConversationQuestionsStyle.dropFirst().sink { [weak self] in self?.manager.set(SettingsItems.conversationQuestionsStyle, value: $0) }.store(in: &cancellables)
        $selectedConversationSpacing.dropFirst().sink { [weak self] in self?.manager.set(SettingsItems.conversationSpacing, value: $0) }.store(in: &cancellables)
        $betweenCommentsSpacing.dropFirst().sink { [weak self] in self?.manager.set(SettingsItems.betweenCommentsSpacing, value: $0) }.store(in: &cancellables)
        $guidelinesSpacing.dropFirst().sink { [weak self] in self?.manager.set(SettingsItems.guidelinesSpacing, value: $0) }.store(in: &cancellables)
        $questionsSpacing.dropFirst().sink { [weak self] in self?.manager.set(SettingsItems.questionsSpacing, value: $0) }.store(in: &cancellables)
        $enablePullToRefresh.dropFirst().sink { [weak self] in self?.manager.set(SettingsItems.enablePullToRefresh, value: $0) }.store(in: &cancellables)
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
