//
//  SettingsItems.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 08/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import Foundation
import OpenWebSDK

enum SettingsItems {
    // MARK: - Customizations
    static let sortOption = SettingsItem(key: "sortOption", defaultValue: CustomizationsViewModel.SortOptionSetting.server)
    static let actionColor = SettingsItem(key: "actionColor", defaultValue: OWCommentActionsColor.default)
    static let actionFont = SettingsItem(key: "actionFont", defaultValue: OWCommentActionsFontStyle.default)
    static let fontFamily = SettingsItem(key: "fontFamily", defaultValue: CustomizationsViewModel.FontFamilySetting.default)
    static let themeMode = SettingsItem(key: "themeMode", defaultValue: CustomizationsViewModel.ThemeModeSetting.system)
    static let enableCustomUICallback = SettingsItem(key: "enableCustomUIDelegation", defaultValue: false)
    static let customThemeColors = SettingsItem(key: "customThemeColors", defaultValue: OWTheme())

    // MARK: - Configurations
    static let languageStrategy = SettingsItem(key: "languageStrategy", defaultValue: ConfigurationsViewModel.LanguageStrategySetting.device)
    static let customLanguage = SettingsItem(key: "customLanguage", defaultValue: OWSupportedLanguage.english)
    static let localeStrategy = SettingsItem(key: "localeStrategy", defaultValue: ConfigurationsViewModel.LocaleStrategySetting.device)
    static let enableLandscape = SettingsItem(key: "enableLandscape", defaultValue: ConfigurationsViewModel.EnableLandscapeSetting.disabled)

    // MARK: - Article Settings
    static let informationStrategy = SettingsItem(key: "informationStrategy", defaultValue: ArticleSettingsViewModel.InformationStrategySetting.server)
    static let articleAssociatedURL = SettingsItem(key: "articleAssociatedURL", defaultValue: "")
    static let hideArticleHeader = SettingsItem(key: "hideArticleHeader", defaultValue: false)
    static let readOnlyMode = SettingsItem(key: "readOnlyMode", defaultValue: OWReadOnlyMode.server)

    // MARK: - Screen Settings
    static let preConversationStyle = SettingsItem(key: "preConversationStyle", defaultValue: ScreenSettingsViewModel.PreConversationStyleSetting.regular)
    private static let defaultNumberOfComments = 3
    static let numberOfComments = SettingsItem(key: "numberOfComments", defaultValue: defaultNumberOfComments)
    static let preConversationGuidelinesStyle = SettingsItem(key: "preConversationGuidelinesStyle", defaultValue: OWCommunityGuidelinesStyle.regular)
    static let preConversationQuestionsStyle = SettingsItem(key: "preConversationQuestionsStyle", defaultValue: OWCommunityQuestionStyle.regular)
    static let conversationStyle = SettingsItem(key: "conversationStyle", defaultValue: ScreenSettingsViewModel.ConversationStyleSetting.regular)
    static let conversationGuidelinesStyle = SettingsItem(key: "conversationGuidelinesStyle", defaultValue: OWCommunityGuidelinesStyle.regular)
    static let conversationQuestionsStyle = SettingsItem(key: "conversationQuestionsStyle", defaultValue: OWCommunityQuestionStyle.regular)
    static let conversationSpacing = SettingsItem(key: "conversationSpacing", defaultValue: ScreenSettingsViewModel.ConversationSpacingSetting.regular)
    private static let defaultBetweenCommentsSpacing: Double = 16
    private static let defaultGuidelinesSpacing: Double = 12
    private static let defaultQuestionsSpacing: Double = 12
    static let betweenCommentsSpacing = SettingsItem(key: "betweenCommentsSpacing", defaultValue: defaultBetweenCommentsSpacing)
    static let guidelinesSpacing = SettingsItem(key: "guidelinesSpacing", defaultValue: defaultGuidelinesSpacing)
    static let questionsSpacing = SettingsItem(key: "questionsSpacing", defaultValue: defaultQuestionsSpacing)
    static let enablePullToRefresh = SettingsItem(key: "enablePullToRefresh", defaultValue: true)

    // MARK: - All Items (for reset)
    static let allItems: [AnySettingsItem] = [
        sortOption, actionColor, actionFont, fontFamily, themeMode,
        enableCustomUICallback, customThemeColors,
        languageStrategy, customLanguage, localeStrategy, enableLandscape,
        informationStrategy, articleAssociatedURL, hideArticleHeader, readOnlyMode,
        preConversationStyle, numberOfComments, preConversationGuidelinesStyle,
        preConversationQuestionsStyle, conversationStyle, conversationGuidelinesStyle,
        conversationQuestionsStyle, conversationSpacing, betweenCommentsSpacing,
        guidelinesSpacing, questionsSpacing, enablePullToRefresh,
    ]
}
