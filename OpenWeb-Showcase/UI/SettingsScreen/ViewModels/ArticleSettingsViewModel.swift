//
//  ArticleSettingsViewModel.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 08/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI
import Combine

class ArticleSettingsViewModel: ObservableObject {
    @SDKSetting(SettingsItems.informationStrategy) var selectedInformationStrategy: InformationStrategySetting
    @SDKSetting(SettingsItems.articleAssociatedURL) var articleAssociatedURL: String
    @SDKSetting(SettingsItems.hideArticleHeader) var hideArticleHeader: Bool
    @SDKSetting(SettingsItems.readOnlyMode) var selectedReadOnlyMode: ReadOnlyModeSetting

    var isAssociatedURLEnabled: Bool {
        selectedInformationStrategy == .local
    }
}

// MARK: - Setting Enums

extension ArticleSettingsViewModel {
    enum InformationStrategySetting: Codable, CaseIterable, Identifiable {
        case server
        case local

        var id: Self { self }
        var title: String {
            switch self {
            case .server: "Server"
            case .local: "Local"
            }
        }
    }

    enum ReadOnlyModeSetting: Codable, CaseIterable, Identifiable {
        case server
        case enable
        case disable

        var id: Self { self }
        var title: String {
            switch self {
            case .server: "Server"
            case .enable: "Enable"
            case .disable: "Disable"
            }
        }
    }
}
