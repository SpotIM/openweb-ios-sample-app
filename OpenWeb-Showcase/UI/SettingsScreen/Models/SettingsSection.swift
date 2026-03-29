//
//  SettingsSection.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 08/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI

enum SettingsSection: Identifiable, CaseIterable {
    case customizations
    case configurations
    case articleSettings
    case screenSettings

    var id: Self { self }

    var title: LocalizedStringResource {
        switch self {
        case .customizations: .settingsCustomizationsTitle
        case .configurations: .settingsConfigurationsTitle
        case .articleSettings: .settingsArticleSettingsTitle
        case .screenSettings: .settingsScreenSettingsTitle
        }
    }

    var subtitle: LocalizedStringResource {
        switch self {
        case .customizations: .settingsCustomizationsSubtitle
        case .configurations: .settingsConfigurationsSubtitle
        case .articleSettings: .settingsArticleSettingsSubtitle
        case .screenSettings: .settingsScreenSettingsSubtitle
        }
    }

    var entries: [SettingsEntry] {
        switch self {
        case .customizations: Self.customizationsEntries
        case .configurations: Self.configurationsEntries
        case .articleSettings: Self.articleSettingsEntries
        case .screenSettings: Self.screenSettingsEntries
        }
    }

    private static let customizationsEntries: [SettingsEntry] = [
        SettingsEntry(
            id: "sort_option",
            title: String(localized: .customizationsSortOptionTitle),
            subtitle: String(localized: .customizationsSortOptionSubtitle)
        ),
        SettingsEntry(
            id: "action_color",
            title: String(localized: .customizationsActionColorTitle),
            subtitle: String(localized: .customizationsActionColorSubtitle)
        ),
        SettingsEntry(
            id: "action_font",
            title: String(localized: .customizationsActionFontTitle),
            subtitle: String(localized: .customizationsActionFontSubtitle)
        ),
        SettingsEntry(
            id: "font_family",
            title: String(localized: .customizationsFontFamilyTitle),
            subtitle: String(localized: .customizationsFontFamilySubtitle)
        ),
        SettingsEntry(
            id: "theme_mode",
            title: String(localized: .customizationsThemeModeTitle),
            subtitle: String(localized: .customizationsThemeModeSubtitle)
        ),
        SettingsEntry(
            id: "custom_theme_colors",
            title: String(localized: .customizationsCustomThemeColorsTitle),
            subtitle: String(localized: .customizationsCustomThemeColorsSubtitle)
        ),
        SettingsEntry(
            id: "custom_ui_callback",
            title: String(localized: .customizationsUICallbackTitle),
            subtitle: String(localized: .customizationsUICallbackSubtitle)
        ),
    ]

    private static let configurationsEntries: [SettingsEntry] = [
        SettingsEntry(
            id: "language_strategy",
            title: String(localized: .configurationsLanguageStrategyTitle),
            subtitle: String(localized: .configurationsLanguageStrategySubtitle)
        ),
        SettingsEntry(
            id: "language",
            title: String(localized: .configurationsLanguageTitle),
            subtitle: ""
        ),
        SettingsEntry(
            id: "locale_strategy",
            title: String(localized: .configurationsLocaleStrategyTitle),
            subtitle: String(localized: .configurationsLocaleStrategySubtitle)
        ),
        SettingsEntry(
            id: "enable_landscape",
            title: String(localized: .configurationsEnableLandscapeTitle),
            subtitle: String(localized: .configurationsEnableLandscapeSubtitle)
        ),
    ]

    private static let articleSettingsEntries: [SettingsEntry] = [
        SettingsEntry(
            id: "information_strategy",
            title: String(localized: .articleSettingsInformationStrategyTitle),
            subtitle: String(localized: .articleSettingsInformationStrategySubtitle)
        ),
        SettingsEntry(
            id: "article_associated_url",
            title: String(localized: .articleSettingsAssociatedURLTitle),
            subtitle: ""
        ),
        SettingsEntry(
            id: "hide_article_header",
            title: String(localized: .articleSettingsHideHeaderTitle),
            subtitle: String(localized: .articleSettingsHideHeaderSubtitle)
        ),
        SettingsEntry(
            id: "read_only_mode",
            title: String(localized: .articleSettingsReadOnlyModeTitle),
            subtitle: String(localized: .articleSettingsReadOnlyModeSubtitle)
        ),
    ]

    private static let screenSettingsEntries: [SettingsEntry] = [
        SettingsEntry(
            id: "pre_conversation_style",
            title: String(localized: .screenSettingsPreConversationStyleTitle),
            subtitle: String(localized: .screenSettingsPreConversationStyleSubtitle)
        ),
        SettingsEntry(
            id: "number_of_comments",
            title: String(localized: .screenSettingsNumberOfCommentsTitle),
            subtitle: String(localized: .screenSettingsNumberOfCommentsSubtitle)
        ),
        SettingsEntry(
            id: "pre_conversation_guidelines",
            title: String(localized: .screenSettingsPreConversationGuidelinesTitle),
            subtitle: String(localized: .screenSettingsPreConversationGuidelinesSubtitle)
        ),
        SettingsEntry(
            id: "pre_conversation_questions",
            title: String(localized: .screenSettingsPreConversationQuestionsTitle),
            subtitle: String(localized: .screenSettingsPreConversationQuestionsSubtitle)
        ),
        SettingsEntry(
            id: "conversation_style",
            title: String(localized: .screenSettingsConversationStyleTitle),
            subtitle: String(localized: .screenSettingsConversationStyleSubtitle)
        ),
        SettingsEntry(
            id: "conversation_guidelines",
            title: String(localized: .screenSettingsConversationGuidelinesTitle),
            subtitle: String(localized: .screenSettingsConversationGuidelinesSubtitle)
        ),
        SettingsEntry(
            id: "conversation_questions",
            title: String(localized: .screenSettingsConversationQuestionsTitle),
            subtitle: String(localized: .screenSettingsConversationQuestionsSubtitle)
        ),
        SettingsEntry(
            id: "conversation_spacing",
            title: String(localized: .screenSettingsConversationSpacingTitle),
            subtitle: String(localized: .screenSettingsConversationSpacingSubtitle)
        ),
        SettingsEntry(
            id: "between_comments_spacing",
            title: String(localized: .screenSettingsBetweenCommentsSpacingTitle),
            subtitle: String(localized: .screenSettingsBetweenCommentsSpacingSubtitle)
        ),
        SettingsEntry(
            id: "guidelines_spacing",
            title: String(localized: .screenSettingsGuidelinesSpacingTitle),
            subtitle: String(localized: .screenSettingsGuidelinesSpacingSubtitle)
        ),
        SettingsEntry(
            id: "questions_spacing",
            title: String(localized: .screenSettingsQuestionsSpacingTitle),
            subtitle: String(localized: .screenSettingsQuestionsSpacingSubtitle)
        ),
        SettingsEntry(
            id: "enable_pull_to_refresh",
            title: String(localized: .screenSettingsEnablePullToRefreshTitle),
            subtitle: String(localized: .screenSettingsEnablePullToRefreshSubtitle)
        ),
    ]
}
