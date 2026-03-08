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
    @Published var selectedInformationStrategy: InformationStrategySetting = .server
    @Published var articleAssociatedURL: String = ""
    @Published var hideArticleHeader: Bool = false
    @Published var selectedReadOnlyMode: ReadOnlyModeSetting = .server

    var isAssociatedURLEnabled: Bool {
        selectedInformationStrategy == .local
    }
}

// MARK: - Setting Enums

extension ArticleSettingsViewModel {
    enum InformationStrategySetting: CaseIterable, Identifiable {
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

    enum ReadOnlyModeSetting: CaseIterable, Identifiable {
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
