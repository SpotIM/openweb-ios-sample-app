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

    var body: some View {
        List {
            preConversationSection
            conversationSection
            generalSection
        }
        .navigationTitle("screenSettingsScreenTitle")
        .settingsToolbar()
    }
}

// MARK: - Sections

private extension ScreenSettingsScreen {
    var preConversationSection: some View {
        Section("screenSettingsPreConversationSectionTitle") {
            SegmentedPickerSection(
                title: "screenSettingsPreConversationStyleTitle",
                subtitle: "screenSettingsPreConversationStyleSubtitle",
                selection: $viewModel.selectedPreConversationStyle,
                optionTitle: \.title
            )
            VStack(alignment: .leading) {
                Text("screenSettingsNumberOfCommentsTitle")
                    .font(.bodyText)
                Text("screenSettingsNumberOfCommentsSubtitle")
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
            SegmentedPickerSection(
                title: "screenSettingsPreConversationGuidelinesTitle",
                subtitle: "screenSettingsPreConversationGuidelinesSubtitle",
                selection: $viewModel.selectedPreConversationGuidelinesStyle,
                optionTitle: \.title
            )
            SegmentedPickerSection(
                title: "screenSettingsPreConversationQuestionsTitle",
                subtitle: "screenSettingsPreConversationQuestionsSubtitle",
                selection: $viewModel.selectedPreConversationQuestionsStyle,
                optionTitle: \.title
            )
        }
    }

    var conversationSection: some View {
        Section("screenSettingsConversationSectionTitle") {
            SegmentedPickerSection(
                title: "screenSettingsConversationStyleTitle",
                subtitle: "screenSettingsConversationStyleSubtitle",
                selection: $viewModel.selectedConversationStyle,
                optionTitle: \.title
            )
            SegmentedPickerSection(
                title: "screenSettingsConversationGuidelinesTitle",
                subtitle: "screenSettingsConversationGuidelinesSubtitle",
                selection: $viewModel.selectedConversationGuidelinesStyle,
                optionTitle: \.title,
                isEnabled: viewModel.isCustomConversationEnabled
            )
            SegmentedPickerSection(
                title: "screenSettingsConversationQuestionsTitle",
                subtitle: "screenSettingsConversationQuestionsSubtitle",
                selection: $viewModel.selectedConversationQuestionsStyle,
                optionTitle: \.title,
                isEnabled: viewModel.isCustomConversationEnabled
            )
            SegmentedPickerSection(
                title: "screenSettingsConversationSpacingTitle",
                subtitle: "screenSettingsConversationSpacingSubtitle",
                selection: $viewModel.selectedConversationSpacing,
                optionTitle: \.title,
                isEnabled: viewModel.isCustomConversationEnabled
            )
            TextFieldSection(
                title: "screenSettingsBetweenCommentsSpacingTitle",
                subtitle: "screenSettingsBetweenCommentsSpacingSubtitle",
                placeholder: "screenSettingsSpacingPlaceholder",
                text: $viewModel.betweenCommentsSpacing,
                isEnabled: viewModel.isCustomSpacingEnabled
            )
            TextFieldSection(
                title: "screenSettingsGuidelinesSpacingTitle",
                subtitle: "screenSettingsGuidelinesSpacingSubtitle",
                placeholder: "screenSettingsSpacingPlaceholder",
                text: $viewModel.guidelinesSpacing,
                isEnabled: viewModel.isCustomSpacingEnabled
            )
            TextFieldSection(
                title: "screenSettingsQuestionsSpacingTitle",
                subtitle: "screenSettingsQuestionsSpacingSubtitle",
                placeholder: "screenSettingsSpacingPlaceholder",
                text: $viewModel.questionsSpacing,
                isEnabled: viewModel.isCustomSpacingEnabled
            )
        }
    }

    var generalSection: some View {
        Section("screenSettingsGeneralSectionTitle") {
            ToggleSection(
                title: "screenSettingsEnablePullToRefreshTitle",
                subtitle: "screenSettingsEnablePullToRefreshSubtitle",
                isOn: $viewModel.enablePullToRefresh
            )
        }
    }
}

#Preview {
    NavigationStack {
        ScreenSettingsScreen()
    }
}
