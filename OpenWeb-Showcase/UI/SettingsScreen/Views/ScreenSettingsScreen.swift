//
//  ScreenSettingsScreen.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 08/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI

struct ScreenSettingsScreen: View {
    private struct Metrics {
        static let maxNumberOfComments: Double = 8
    }

    @StateObject private var viewModel = ScreenSettingsViewModel()
    var highlightedEntryID: String?
    @State private var activeHighlightID: String?

    var body: some View {
        List {
            preConversationSection
            conversationSection
            generalSection
        }
        .scrollAndHighlight(entryID: highlightedEntryID, activeHighlightID: $activeHighlightID)
        .navigationTitle(.screenSettingsScreenTitle)
        .settingsToolbar()
    }
}

// MARK: - Sections

private extension ScreenSettingsScreen {
    var preConversationSection: some View {
        Section(.screenSettingsPreConversationSectionTitle) {
            SegmentedPickerRow(
                title: .screenSettingsPreConversationStyleTitle,
                subtitle: .screenSettingsPreConversationStyleSubtitle,
                selection: $viewModel.selectedPreConversationStyle,
                optionTitle: \.title
            )
            .settingsRow(SettingsItems.preConversationStyle.key, highlightedID: activeHighlightID)
            SliderRow(
                title: .screenSettingsNumberOfCommentsTitle,
                subtitle: .screenSettingsNumberOfCommentsSubtitle,
                value: $viewModel.numberOfComments,
                range: 1...Metrics.maxNumberOfComments,
                isEnabled: viewModel.isNumberOfCommentsEnabled
            )
            .settingsRow(SettingsItems.numberOfComments.key, highlightedID: activeHighlightID)
            SegmentedPickerRow(
                title: .screenSettingsPreConversationGuidelinesTitle,
                subtitle: .screenSettingsPreConversationGuidelinesSubtitle,
                selection: $viewModel.selectedPreConversationGuidelinesStyle,
                optionTitle: \.title
            )
            .settingsRow(SettingsItems.preConversationGuidelinesStyle.key, highlightedID: activeHighlightID)
            SegmentedPickerRow(
                title: .screenSettingsPreConversationQuestionsTitle,
                subtitle: .screenSettingsPreConversationQuestionsSubtitle,
                selection: $viewModel.selectedPreConversationQuestionsStyle,
                optionTitle: \.title
            )
            .settingsRow(SettingsItems.preConversationQuestionsStyle.key, highlightedID: activeHighlightID)
        }
    }

    var conversationSection: some View {
        Section(.screenSettingsConversationSectionTitle) {
            SegmentedPickerRow(
                title: .screenSettingsConversationStyleTitle,
                subtitle: .screenSettingsConversationStyleSubtitle,
                selection: $viewModel.selectedConversationStyle,
                optionTitle: \.title
            )
            .settingsRow(SettingsItems.conversationStyle.key, highlightedID: activeHighlightID)
            SegmentedPickerRow(
                title: .screenSettingsConversationGuidelinesTitle,
                subtitle: .screenSettingsConversationGuidelinesSubtitle,
                selection: $viewModel.selectedConversationGuidelinesStyle,
                optionTitle: \.title,
                isEnabled: viewModel.isCustomConversationEnabled
            )
            .settingsRow(SettingsItems.conversationGuidelinesStyle.key, highlightedID: activeHighlightID)
            SegmentedPickerRow(
                title: .screenSettingsConversationQuestionsTitle,
                subtitle: .screenSettingsConversationQuestionsSubtitle,
                selection: $viewModel.selectedConversationQuestionsStyle,
                optionTitle: \.title,
                isEnabled: viewModel.isCustomConversationEnabled
            )
            .settingsRow(SettingsItems.conversationQuestionsStyle.key, highlightedID: activeHighlightID)
            SegmentedPickerRow(
                title: .screenSettingsConversationSpacingTitle,
                subtitle: .screenSettingsConversationSpacingSubtitle,
                selection: $viewModel.selectedConversationSpacing,
                optionTitle: \.title,
                isEnabled: viewModel.isCustomConversationEnabled
            )
            .settingsRow(SettingsItems.conversationSpacing.key, highlightedID: activeHighlightID)
            TextFieldRow(
                title: .screenSettingsBetweenCommentsSpacingTitle,
                subtitle: .screenSettingsBetweenCommentsSpacingSubtitle,
                placeholder: .screenSettingsSpacingPlaceholder,
                text: $viewModel.betweenCommentsSpacing,
                isEnabled: viewModel.isCustomSpacingEnabled
            )
            .settingsRow(SettingsItems.betweenCommentsSpacing.key, highlightedID: activeHighlightID)
            TextFieldRow(
                title: "screenSettingsGuidelinesSpacingTitle",
                subtitle: "screenSettingsGuidelinesSpacingSubtitle",
                placeholder: "screenSettingsSpacingPlaceholder",
                text: $viewModel.guidelinesSpacing,
                isEnabled: viewModel.isCustomSpacingEnabled
            )
            .settingsRow(SettingsItems.guidelinesSpacing.key, highlightedID: activeHighlightID)
            TextFieldRow(
                title: .screenSettingsQuestionsSpacingTitle,
                subtitle: .screenSettingsQuestionsSpacingSubtitle,
                placeholder: .screenSettingsSpacingPlaceholder,
                text: $viewModel.questionsSpacing,
                isEnabled: viewModel.isCustomSpacingEnabled
            )
            .settingsRow(SettingsItems.questionsSpacing.key, highlightedID: activeHighlightID)
        }
    }

    var generalSection: some View {
        Section(.screenSettingsGeneralSectionTitle) {
            ToggleRow(
                title: .screenSettingsEnablePullToRefreshTitle,
                subtitle: .screenSettingsEnablePullToRefreshSubtitle,
                isOn: $viewModel.enablePullToRefresh
            )
            .settingsRow(SettingsItems.enablePullToRefresh.key, highlightedID: activeHighlightID)
        }
    }
}

#Preview {
    NavigationStack {
        ScreenSettingsScreen()
    }
}
