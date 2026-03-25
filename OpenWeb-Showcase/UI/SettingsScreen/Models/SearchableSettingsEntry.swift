//
//  SearchableSettingsEntry.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 25/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import Foundation

struct SearchableSettingsEntry: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let section: SettingsSection
}

extension SearchableSettingsEntry {
    func matches(_ query: String) -> Bool {
        let lowercased = query.lowercased()
        return title.lowercased().contains(lowercased) ||
               subtitle.lowercased().contains(lowercased)
    }
}

extension SearchableSettingsEntry {
    static let allEntries: [SearchableSettingsEntry] = [
        // Customizations - Sorting
        SearchableSettingsEntry(
            id: "sort_option",
            title: String(localized: "customizationsSortOptionTitle"),
            subtitle: String(localized: "customizationsSortOptionSubtitle"),
            section: .customizations
        ),
        // Customizations - Comment Actions
        SearchableSettingsEntry(
            id: "action_color",
            title: String(localized: "customizationsActionColorTitle"),
            subtitle: String(localized: "customizationsActionColorSubtitle"),
            section: .customizations
        ),
        SearchableSettingsEntry(
            id: "action_font",
            title: String(localized: "customizationsActionFontTitle"),
            subtitle: String(localized: "customizationsActionFontSubtitle"),
            section: .customizations
        ),
        // Customizations - Theme
        SearchableSettingsEntry(
            id: "font_family",
            title: String(localized: "customizationsFontFamilyTitle"),
            subtitle: String(localized: "customizationsFontFamilySubtitle"),
            section: .customizations
        ),
        SearchableSettingsEntry(
            id: "theme_mode",
            title: String(localized: "customizationsThemeModeTitle"),
            subtitle: String(localized: "customizationsThemeModeSubtitle"),
            section: .customizations
        ),
        SearchableSettingsEntry(
            id: "custom_theme_colors",
            title: String(localized: "customizationsCustomThemeColorsTitle"),
            subtitle: String(localized: "customizationsCustomThemeColorsSubtitle"),
            section: .customizations
        ),
        // Customizations - UI Callback
        SearchableSettingsEntry(
            id: "custom_ui_callback",
            title: String(localized: "customizationsUICallbackTitle"),
            subtitle: String(localized: "customizationsUICallbackSubtitle"),
            section: .customizations
        ),
        // Configurations
        SearchableSettingsEntry(
            id: "language_strategy",
            title: String(localized: "configurationsLanguageStrategyTitle"),
            subtitle: String(localized: "configurationsLanguageStrategySubtitle"),
            section: .configurations
        ),
        SearchableSettingsEntry(
            id: "language",
            title: String(localized: "configurationsLanguageTitle"),
            subtitle: "",
            section: .configurations
        ),
        SearchableSettingsEntry(
            id: "locale_strategy",
            title: String(localized: "configurationsLocaleStrategyTitle"),
            subtitle: String(localized: "configurationsLocaleStrategySubtitle"),
            section: .configurations
        ),
        SearchableSettingsEntry(
            id: "enable_landscape",
            title: String(localized: "configurationsEnableLandscapeTitle"),
            subtitle: String(localized: "configurationsEnableLandscapeSubtitle"),
            section: .configurations
        ),
        // Article Settings
        SearchableSettingsEntry(
            id: "information_strategy",
            title: String(localized: "articleSettingsInformationStrategyTitle"),
            subtitle: String(localized: "articleSettingsInformationStrategySubtitle"),
            section: .articleSettings
        ),
        SearchableSettingsEntry(
            id: "article_associated_url",
            title: String(localized: "articleSettingsAssociatedURLTitle"),
            subtitle: "",
            section: .articleSettings
        ),
        SearchableSettingsEntry(
            id: "hide_article_header",
            title: String(localized: "articleSettingsHideHeaderTitle"),
            subtitle: String(localized: "articleSettingsHideHeaderSubtitle"),
            section: .articleSettings
        ),
        SearchableSettingsEntry(
            id: "read_only_mode",
            title: String(localized: "articleSettingsReadOnlyModeTitle"),
            subtitle: String(localized: "articleSettingsReadOnlyModeSubtitle"),
            section: .articleSettings
        ),
        // Screen Settings - Pre Conversation
        SearchableSettingsEntry(
            id: "pre_conversation_style",
            title: String(localized: "screenSettingsPreConversationStyleTitle"),
            subtitle: String(localized: "screenSettingsPreConversationStyleSubtitle"),
            section: .screenSettings
        ),
        SearchableSettingsEntry(
            id: "number_of_comments",
            title: String(localized: "screenSettingsNumberOfCommentsTitle"),
            subtitle: String(localized: "screenSettingsNumberOfCommentsSubtitle"),
            section: .screenSettings
        ),
        SearchableSettingsEntry(
            id: "pre_conversation_guidelines",
            title: String(localized: "screenSettingsPreConversationGuidelinesTitle"),
            subtitle: String(localized: "screenSettingsPreConversationGuidelinesSubtitle"),
            section: .screenSettings
        ),
        SearchableSettingsEntry(
            id: "pre_conversation_questions",
            title: String(localized: "screenSettingsPreConversationQuestionsTitle"),
            subtitle: String(localized: "screenSettingsPreConversationQuestionsSubtitle"),
            section: .screenSettings
        ),
        // Screen Settings - Conversation
        SearchableSettingsEntry(
            id: "conversation_style",
            title: String(localized: "screenSettingsConversationStyleTitle"),
            subtitle: String(localized: "screenSettingsConversationStyleSubtitle"),
            section: .screenSettings
        ),
        SearchableSettingsEntry(
            id: "conversation_guidelines",
            title: String(localized: "screenSettingsConversationGuidelinesTitle"),
            subtitle: String(localized: "screenSettingsConversationGuidelinesSubtitle"),
            section: .screenSettings
        ),
        SearchableSettingsEntry(
            id: "conversation_questions",
            title: String(localized: "screenSettingsConversationQuestionsTitle"),
            subtitle: String(localized: "screenSettingsConversationQuestionsSubtitle"),
            section: .screenSettings
        ),
        SearchableSettingsEntry(
            id: "conversation_spacing",
            title: String(localized: "screenSettingsConversationSpacingTitle"),
            subtitle: String(localized: "screenSettingsConversationSpacingSubtitle"),
            section: .screenSettings
        ),
        SearchableSettingsEntry(
            id: "between_comments_spacing",
            title: String(localized: "screenSettingsBetweenCommentsSpacingTitle"),
            subtitle: String(localized: "screenSettingsBetweenCommentsSpacingSubtitle"),
            section: .screenSettings
        ),
        SearchableSettingsEntry(
            id: "guidelines_spacing",
            title: String(localized: "screenSettingsGuidelinesSpacingTitle"),
            subtitle: String(localized: "screenSettingsGuidelinesSpacingSubtitle"),
            section: .screenSettings
        ),
        SearchableSettingsEntry(
            id: "questions_spacing",
            title: String(localized: "screenSettingsQuestionsSpacingTitle"),
            subtitle: String(localized: "screenSettingsQuestionsSpacingSubtitle"),
            section: .screenSettings
        ),
        // Screen Settings - General
        SearchableSettingsEntry(
            id: "enable_pull_to_refresh",
            title: String(localized: "screenSettingsEnablePullToRefreshTitle"),
            subtitle: String(localized: "screenSettingsEnablePullToRefreshSubtitle"),
            section: .screenSettings
        ),
    ]
}
