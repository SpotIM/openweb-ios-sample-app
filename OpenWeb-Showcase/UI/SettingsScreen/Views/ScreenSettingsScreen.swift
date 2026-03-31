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

    var body: some View {
        List {
            preConversationSection
            conversationSection
            generalSection
        }
        .scrollAndHighlight(entryID: highlightedEntryID)
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
            .settingsRow(SettingsItems.preConversationStyle.key)
            SliderRow(
                title: .screenSettingsNumberOfCommentsTitle,
                subtitle: .screenSettingsNumberOfCommentsSubtitle,
                value: $viewModel.numberOfComments,
                range: 1...Metrics.maxNumberOfComments,
                isEnabled: viewModel.isNumberOfCommentsEnabled
            )
            .settingsRow(SettingsItems.numberOfComments.key)
            SegmentedPickerRow(
                title: .screenSettingsPreConversationGuidelinesTitle,
                subtitle: .screenSettingsPreConversationGuidelinesSubtitle,
                selection: $viewModel.selectedPreConversationGuidelinesStyle,
                optionTitle: \.title
            )
            .settingsRow(SettingsItems.preConversationGuidelinesStyle.key)
            SegmentedPickerRow(
                title: .screenSettingsPreConversationQuestionsTitle,
                subtitle: .screenSettingsPreConversationQuestionsSubtitle,
                selection: $viewModel.selectedPreConversationQuestionsStyle,
                optionTitle: \.title
            )
            .settingsRow(SettingsItems.preConversationQuestionsStyle.key)
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
            .settingsRow(SettingsItems.conversationStyle.key)
            SegmentedPickerRow(
                title: .screenSettingsConversationGuidelinesTitle,
                subtitle: .screenSettingsConversationGuidelinesSubtitle,
                selection: $viewModel.selectedConversationGuidelinesStyle,
                optionTitle: \.title,
                isEnabled: viewModel.isCustomConversationEnabled
            )
            .settingsRow(SettingsItems.conversationGuidelinesStyle.key)
            SegmentedPickerRow(
                title: .screenSettingsConversationQuestionsTitle,
                subtitle: .screenSettingsConversationQuestionsSubtitle,
                selection: $viewModel.selectedConversationQuestionsStyle,
                optionTitle: \.title,
                isEnabled: viewModel.isCustomConversationEnabled
            )
            .settingsRow(SettingsItems.conversationQuestionsStyle.key)
            SegmentedPickerRow(
                title: .screenSettingsConversationSpacingTitle,
                subtitle: .screenSettingsConversationSpacingSubtitle,
                selection: $viewModel.selectedConversationSpacing,
                optionTitle: \.title,
                isEnabled: viewModel.isCustomConversationEnabled
            )
            .settingsRow(SettingsItems.conversationSpacing.key)
            NumericTextFieldRow(
                title: .screenSettingsBetweenCommentsSpacingTitle,
                subtitle: .screenSettingsBetweenCommentsSpacingSubtitle,
                placeholder: .screenSettingsSpacingPlaceholder,
                value: $viewModel.betweenCommentsSpacing,
                isEnabled: viewModel.isCustomSpacingEnabled
            )
            .settingsRow(SettingsItems.betweenCommentsSpacing.key)
            NumericTextFieldRow(
                title: .screenSettingsGuidelinesSpacingTitle,
                subtitle: .screenSettingsGuidelinesSpacingSubtitle,
                placeholder: .screenSettingsSpacingPlaceholder,
                value: $viewModel.guidelinesSpacing,
                isEnabled: viewModel.isCustomSpacingEnabled
            )
            .settingsRow(SettingsItems.guidelinesSpacing.key)
            NumericTextFieldRow(
                title: .screenSettingsQuestionsSpacingTitle,
                subtitle: .screenSettingsQuestionsSpacingSubtitle,
                placeholder: .screenSettingsSpacingPlaceholder,
                value: $viewModel.questionsSpacing,
                isEnabled: viewModel.isCustomSpacingEnabled
            )
            .settingsRow(SettingsItems.questionsSpacing.key)
        }
    }

    var generalSection: some View {
        Section(.screenSettingsGeneralSectionTitle) {
            ToggleRow(
                title: .screenSettingsEnablePullToRefreshTitle,
                subtitle: .screenSettingsEnablePullToRefreshSubtitle,
                isOn: $viewModel.enablePullToRefresh
            )
            .settingsRow(SettingsItems.enablePullToRefresh.key)
        }
    }
}

#Preview {
    NavigationStack {
        ScreenSettingsScreen()
    }
}
