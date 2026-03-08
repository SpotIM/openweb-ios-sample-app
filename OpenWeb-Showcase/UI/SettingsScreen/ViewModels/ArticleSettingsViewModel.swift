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
    private let manager = SettingsManager.shared
    private var cancellables = Set<AnyCancellable>()

    @Published var selectedInformationStrategy: InformationStrategySetting = SettingsItems.informationStrategy.defaultValue
    @Published var articleAssociatedURL: String = SettingsItems.articleAssociatedURL.defaultValue
    @Published var hideArticleHeader: Bool = SettingsItems.hideArticleHeader.defaultValue
    @Published var selectedReadOnlyMode: ReadOnlyModeSetting = SettingsItems.readOnlyMode.defaultValue

    var isAssociatedURLEnabled: Bool {
        selectedInformationStrategy == .local
    }

    init() {
        loadSettings()
        observeChanges()
    }

    func loadSettings() {
        selectedInformationStrategy = manager.get(SettingsItems.informationStrategy)
        articleAssociatedURL = manager.get(SettingsItems.articleAssociatedURL)
        hideArticleHeader = manager.get(SettingsItems.hideArticleHeader)
        selectedReadOnlyMode = manager.get(SettingsItems.readOnlyMode)
    }
}

// MARK: - Private

private extension ArticleSettingsViewModel {
    func observeChanges() {
        $selectedInformationStrategy.dropFirst().sink { [weak self] in self?.manager.set(SettingsItems.informationStrategy, value: $0) }.store(in: &cancellables)
        $articleAssociatedURL.dropFirst().sink { [weak self] in self?.manager.set(SettingsItems.articleAssociatedURL, value: $0) }.store(in: &cancellables)
        $hideArticleHeader.dropFirst().sink { [weak self] in self?.manager.set(SettingsItems.hideArticleHeader, value: $0) }.store(in: &cancellables)
        $selectedReadOnlyMode.dropFirst().sink { [weak self] in self?.manager.set(SettingsItems.readOnlyMode, value: $0) }.store(in: &cancellables)
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
