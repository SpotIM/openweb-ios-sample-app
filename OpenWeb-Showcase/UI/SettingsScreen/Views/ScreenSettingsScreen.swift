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
        static let disabledOpacity: Double = 0.4
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
            SegmentedPickerSection(
                title: .screenSettingsPreConversationStyleTitle,
                subtitle: .screenSettingsPreConversationStyleSubtitle,
                selection: $viewModel.selectedPreConversationStyle,
                optionTitle: \.title
            )
            .settingsRow("pre_conversation_style", highlightedID: activeHighlightID)
            VStack(alignment: .leading) {
                Text(.screenSettingsNumberOfCommentsTitle)
                    .font(.bodyText)
                Text(.screenSettingsNumberOfCommentsSubtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                HStack {
                    Slider(
                        value: Binding(
                            get: { Double(viewModel.numberOfComments) },
                            set: { viewModel.numberOfComments = Int($0) }
                        ),
                        in: 1...Metrics.maxNumberOfComments,
                        step: 1
                    )
                    Text("\(viewModel.numberOfComments)")
                        .monospacedDigit()
                }
            }
            .disabled(!viewModel.isNumberOfCommentsEnabled)
            .opacity(viewModel.isNumberOfCommentsEnabled ? 1 : Metrics.disabledOpacity)
            .settingsRow("number_of_comments", highlightedID: activeHighlightID)
            SegmentedPickerSection(
                title: .screenSettingsPreConversationGuidelinesTitle,
                subtitle: .screenSettingsPreConversationGuidelinesSubtitle,
                selection: $viewModel.selectedPreConversationGuidelinesStyle,
                optionTitle: \.title
            )
            .settingsRow("pre_conversation_guidelines", highlightedID: activeHighlightID)
            SegmentedPickerSection(
                title: .screenSettingsPreConversationQuestionsTitle,
                subtitle: .screenSettingsPreConversationQuestionsSubtitle,
                selection: $viewModel.selectedPreConversationQuestionsStyle,
                optionTitle: \.title
            )
            .settingsRow("pre_conversation_questions", highlightedID: activeHighlightID)
        }
    }

    var conversationSection: some View {
        Section(.screenSettingsConversationSectionTitle) {
            SegmentedPickerSection(
                title: .screenSettingsConversationStyleTitle,
                subtitle: .screenSettingsConversationStyleSubtitle,
                selection: $viewModel.selectedConversationStyle,
                optionTitle: \.title
            )
            .settingsRow("conversation_style", highlightedID: activeHighlightID)
            SegmentedPickerSection(
                title: .screenSettingsConversationGuidelinesTitle,
                subtitle: .screenSettingsConversationGuidelinesSubtitle,
                selection: $viewModel.selectedConversationGuidelinesStyle,
                optionTitle: \.title,
                isEnabled: viewModel.isCustomConversationEnabled
            )
            .settingsRow("conversation_guidelines", highlightedID: activeHighlightID)
            SegmentedPickerSection(
                title: .screenSettingsConversationQuestionsTitle,
                subtitle: .screenSettingsConversationQuestionsSubtitle,
                selection: $viewModel.selectedConversationQuestionsStyle,
                optionTitle: \.title,
                isEnabled: viewModel.isCustomConversationEnabled
            )
            .settingsRow("conversation_questions", highlightedID: activeHighlightID)
            SegmentedPickerSection(
                title: .screenSettingsConversationSpacingTitle,
                subtitle: .screenSettingsConversationSpacingSubtitle,
                selection: $viewModel.selectedConversationSpacing,
                optionTitle: \.title,
                isEnabled: viewModel.isCustomConversationEnabled
            )
            .settingsRow("conversation_spacing", highlightedID: activeHighlightID)
            TextFieldSection(
                title: .screenSettingsBetweenCommentsSpacingTitle,
                subtitle: .screenSettingsBetweenCommentsSpacingSubtitle,
                placeholder: .screenSettingsSpacingPlaceholder,
                text: $viewModel.betweenCommentsSpacing,
                isEnabled: viewModel.isCustomSpacingEnabled
            )
            .settingsRow("between_comments_spacing", highlightedID: activeHighlightID)
            TextFieldSection(
                title: "screenSettingsGuidelinesSpacingTitle",
                subtitle: "screenSettingsGuidelinesSpacingSubtitle",
                placeholder: "screenSettingsSpacingPlaceholder",
                text: $viewModel.guidelinesSpacing,
                isEnabled: viewModel.isCustomSpacingEnabled
            )
            .settingsRow("guidelines_spacing", highlightedID: activeHighlightID)
            TextFieldSection(
                title: .screenSettingsQuestionsSpacingTitle,
                subtitle: .screenSettingsQuestionsSpacingSubtitle,
                placeholder: .screenSettingsSpacingPlaceholder,
                text: $viewModel.questionsSpacing,
                isEnabled: viewModel.isCustomSpacingEnabled
            )
            .settingsRow("questions_spacing", highlightedID: activeHighlightID)
        }
    }

    var generalSection: some View {
        Section(.screenSettingsGeneralSectionTitle) {
            ToggleSection(
                title: .screenSettingsEnablePullToRefreshTitle,
                subtitle: .screenSettingsEnablePullToRefreshSubtitle,
                isOn: $viewModel.enablePullToRefresh
            )
            .settingsRow("enable_pull_to_refresh", highlightedID: activeHighlightID)
        }
    }
}

#Preview {
    NavigationStack {
        ScreenSettingsScreen()
    }
}
