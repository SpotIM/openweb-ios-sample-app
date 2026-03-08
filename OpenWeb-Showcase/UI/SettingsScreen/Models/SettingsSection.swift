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

    var title: LocalizedStringKey {
        switch self {
        case .customizations: "settingsCustomizationsTitle"
        case .configurations: "settingsConfigurationsTitle"
        case .articleSettings: "settingsArticleSettingsTitle"
        case .screenSettings: "settingsScreenSettingsTitle"
        }
    }

    var subtitle: LocalizedStringKey {
        switch self {
        case .customizations: "settingsCustomizationsSubtitle"
        case .configurations: "settingsConfigurationsSubtitle"
        case .articleSettings: "settingsArticleSettingsSubtitle"
        case .screenSettings: "settingsScreenSettingsSubtitle"
        }
    }
}
