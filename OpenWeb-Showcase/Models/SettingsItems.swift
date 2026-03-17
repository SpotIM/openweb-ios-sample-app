//
//  SettingsItems.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 08/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import Foundation

enum SettingsItems {
    // MARK: - Customizations
    static let sortOption = SettingsItem(key: "sort_option", defaultValue: CustomizationsViewModel.SortOptionSetting.server)
    static let actionColor = SettingsItem(key: "action_color", defaultValue: CustomizationsViewModel.ActionColorSetting.default)
    static let actionFont = SettingsItem(key: "action_font", defaultValue: CustomizationsViewModel.ActionFontSetting.default)
    static let fontFamily = SettingsItem(key: "font_family", defaultValue: CustomizationsViewModel.FontFamilySetting.default)
    static let themeMode = SettingsItem(key: "theme_mode", defaultValue: CustomizationsViewModel.ThemeModeSetting.system)
    static let enableCustomUIDelegation = SettingsItem(key: "enable_custom_ui_delegation", defaultValue: false)

    // MARK: - Configurations
    static let languageStrategy = SettingsItem(key: "language_strategy", defaultValue: ConfigurationsViewModel.LanguageStrategySetting.device)
    static let customLanguage = SettingsItem(key: "custom_language", defaultValue: ConfigurationsViewModel.SupportedLanguage.english)
    static let localeStrategy = SettingsItem(key: "locale_strategy", defaultValue: ConfigurationsViewModel.LocaleStrategySetting.device)
    static let enableLandscape = SettingsItem(key: "enable_landscape", defaultValue: false)

    // MARK: - Article Settings
    static let informationStrategy = SettingsItem(key: "information_strategy", defaultValue: ArticleSettingsViewModel.InformationStrategySetting.server)
    static let articleAssociatedURL = SettingsItem(key: "article_associated_url", defaultValue: "")
    static let hideArticleHeader = SettingsItem(key: "hide_article_header", defaultValue: false)
    static let readOnlyMode = SettingsItem(key: "read_only_mode", defaultValue: ArticleSettingsViewModel.ReadOnlyModeSetting.server)

    // MARK: - Screen Settings
    static let preConversationStyle = SettingsItem(key: "pre_conversation_style", defaultValue: ScreenSettingsViewModel.PreConversationStyleSetting.regular)
    static let numberOfComments = SettingsItem(key: "number_of_comments", defaultValue: 3)
    static let preConversationGuidelinesStyle = SettingsItem(key: "pre_conversation_guidelines_style", defaultValue: ScreenSettingsViewModel.GuidelinesStyleSetting.regular)
    static let preConversationQuestionsStyle = SettingsItem(key: "pre_conversation_questions_style", defaultValue: ScreenSettingsViewModel.QuestionsStyleSetting.regular)
    static let conversationStyle = SettingsItem(key: "conversation_style", defaultValue: ScreenSettingsViewModel.ConversationStyleSetting.regular)
    static let conversationGuidelinesStyle = SettingsItem(key: "conversation_guidelines_style", defaultValue: ScreenSettingsViewModel.GuidelinesStyleSetting.regular)
    static let conversationQuestionsStyle = SettingsItem(key: "conversation_questions_style", defaultValue: ScreenSettingsViewModel.QuestionsStyleSetting.regular)
    static let conversationSpacing = SettingsItem(key: "conversation_spacing", defaultValue: ScreenSettingsViewModel.ConversationSpacingSetting.regular)
    static let betweenCommentsSpacing = SettingsItem(key: "between_comments_spacing", defaultValue: "16")
    static let guidelinesSpacing = SettingsItem(key: "guidelines_spacing", defaultValue: "12")
    static let questionsSpacing = SettingsItem(key: "questions_spacing", defaultValue: "12")
    static let enablePullToRefresh = SettingsItem(key: "enable_pull_to_refresh", defaultValue: true)

    // MARK: - All Items (for reset)
    static let allItems: [AnySettingsItem] = [
        sortOption, actionColor, actionFont, fontFamily, themeMode,
        enableCustomUIDelegation,
        languageStrategy, customLanguage, localeStrategy, enableLandscape,
        informationStrategy, articleAssociatedURL, hideArticleHeader, readOnlyMode,
        preConversationStyle, numberOfComments, preConversationGuidelinesStyle,
        preConversationQuestionsStyle, conversationStyle, conversationGuidelinesStyle,
        conversationQuestionsStyle, conversationSpacing, betweenCommentsSpacing,
        guidelinesSpacing, questionsSpacing, enablePullToRefresh,
    ]
}
