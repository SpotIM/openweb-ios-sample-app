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
            id: SettingsItems.sortOption.key,
            title: String(localized: .customizationsSortOptionTitle),
            subtitle: String(localized: .customizationsSortOptionSubtitle)
        ),
        SettingsEntry(
            id: SettingsItems.actionColor.key,
            title: String(localized: .customizationsActionColorTitle),
            subtitle: String(localized: .customizationsActionColorSubtitle)
        ),
        SettingsEntry(
            id: SettingsItems.actionFont.key,
            title: String(localized: .customizationsActionFontTitle),
            subtitle: String(localized: .customizationsActionFontSubtitle)
        ),
        SettingsEntry(
            id: SettingsItems.fontFamily.key,
            title: String(localized: .customizationsFontFamilyTitle),
            subtitle: String(localized: .customizationsFontFamilySubtitle)
        ),
        SettingsEntry(
            id: SettingsItems.themeMode.key,
            title: String(localized: .customizationsThemeModeTitle),
            subtitle: String(localized: .customizationsThemeModeSubtitle)
        ),
        SettingsEntry(
            id: SettingsItems.customThemeColors.key,
            title: String(localized: .customizationsCustomThemeColorsTitle),
            subtitle: String(localized: .customizationsCustomThemeColorsSubtitle)
        ),
        SettingsEntry(
            id: SettingsItems.enableCustomUICallback.key,
            title: String(localized: .customizationsUICallbackTitle),
            subtitle: String(localized: .customizationsUICallbackSubtitle)
        ),
    ]

    private static let configurationsEntries: [SettingsEntry] = [
        SettingsEntry(
            id: SettingsItems.languageStrategy.key,
            title: String(localized: .configurationsLanguageStrategyTitle),
            subtitle: String(localized: .configurationsLanguageStrategySubtitle)
        ),
        SettingsEntry(
            id: SettingsItems.customLanguage.key,
            title: String(localized: .configurationsLanguageTitle),
            subtitle: ""
        ),
        SettingsEntry(
            id: SettingsItems.localeStrategy.key,
            title: String(localized: .configurationsLocaleStrategyTitle),
            subtitle: String(localized: .configurationsLocaleStrategySubtitle)
        ),
        SettingsEntry(
            id: SettingsItems.enableLandscape.key,
            title: String(localized: .configurationsEnableLandscapeTitle),
            subtitle: String(localized: .configurationsEnableLandscapeSubtitle)
        ),
    ]

    private static let articleSettingsEntries: [SettingsEntry] = [
        SettingsEntry(
            id: SettingsItems.informationStrategy.key,
            title: String(localized: .articleSettingsInformationStrategyTitle),
            subtitle: String(localized: .articleSettingsInformationStrategySubtitle)
        ),
        SettingsEntry(
            id: SettingsItems.articleAssociatedURL.key,
            title: String(localized: .articleSettingsAssociatedURLTitle),
            subtitle: ""
        ),
        SettingsEntry(
            id: SettingsItems.hideArticleHeader.key,
            title: String(localized: .articleSettingsHideHeaderTitle),
            subtitle: String(localized: .articleSettingsHideHeaderSubtitle)
        ),
        SettingsEntry(
            id: SettingsItems.readOnlyMode.key,
            title: String(localized: .articleSettingsReadOnlyModeTitle),
            subtitle: String(localized: .articleSettingsReadOnlyModeSubtitle)
        ),
    ]

    private static let screenSettingsEntries: [SettingsEntry] = [
        SettingsEntry(
            id: SettingsItems.preConversationStyle.key,
            title: String(localized: .screenSettingsPreConversationStyleTitle),
            subtitle: String(localized: .screenSettingsPreConversationStyleSubtitle)
        ),
        SettingsEntry(
            id: SettingsItems.numberOfComments.key,
            title: String(localized: .screenSettingsNumberOfCommentsTitle),
            subtitle: String(localized: .screenSettingsNumberOfCommentsSubtitle)
        ),
        SettingsEntry(
            id: SettingsItems.preConversationGuidelinesStyle.key,
            title: String(localized: .screenSettingsPreConversationGuidelinesTitle),
            subtitle: String(localized: .screenSettingsPreConversationGuidelinesSubtitle)
        ),
        SettingsEntry(
            id: SettingsItems.preConversationQuestionsStyle.key,
            title: String(localized: .screenSettingsPreConversationQuestionsTitle),
            subtitle: String(localized: .screenSettingsPreConversationQuestionsSubtitle)
        ),
        SettingsEntry(
            id: SettingsItems.conversationStyle.key,
            title: String(localized: .screenSettingsConversationStyleTitle),
            subtitle: String(localized: .screenSettingsConversationStyleSubtitle)
        ),
        SettingsEntry(
            id: SettingsItems.conversationGuidelinesStyle.key,
            title: String(localized: .screenSettingsConversationGuidelinesTitle),
            subtitle: String(localized: .screenSettingsConversationGuidelinesSubtitle)
        ),
        SettingsEntry(
            id: SettingsItems.conversationQuestionsStyle.key,
            title: String(localized: .screenSettingsConversationQuestionsTitle),
            subtitle: String(localized: .screenSettingsConversationQuestionsSubtitle)
        ),
        SettingsEntry(
            id: SettingsItems.conversationSpacing.key,
            title: String(localized: .screenSettingsConversationSpacingTitle),
            subtitle: String(localized: .screenSettingsConversationSpacingSubtitle)
        ),
        SettingsEntry(
            id: SettingsItems.betweenCommentsSpacing.key,
            title: String(localized: .screenSettingsBetweenCommentsSpacingTitle),
            subtitle: String(localized: .screenSettingsBetweenCommentsSpacingSubtitle)
        ),
        SettingsEntry(
            id: SettingsItems.guidelinesSpacing.key,
            title: String(localized: .screenSettingsGuidelinesSpacingTitle),
            subtitle: String(localized: .screenSettingsGuidelinesSpacingSubtitle)
        ),
        SettingsEntry(
            id: SettingsItems.questionsSpacing.key,
            title: String(localized: .screenSettingsQuestionsSpacingTitle),
            subtitle: String(localized: .screenSettingsQuestionsSpacingSubtitle)
        ),
        SettingsEntry(
            id: SettingsItems.enablePullToRefresh.key,
            title: String(localized: .screenSettingsEnablePullToRefreshTitle),
            subtitle: String(localized: .screenSettingsEnablePullToRefreshSubtitle)
        ),
    ]

}
