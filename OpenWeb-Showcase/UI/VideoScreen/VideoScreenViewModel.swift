//
//  VideoScreenViewModel.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 12/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI
import OpenWebSDK
import Combine

class VideoScreenViewModel: ObservableObject {
    private let vertical: ShowcaseVertical = .video

    var article: ArticleData { vertical.article }
    var sdkUsageInfo: SDKUsageInfo { vertical.sdkUsageInfo }
    var color: Color { vertical.color }
    let videoURLs: [URL] = VideoURLs.shuffled

    @Published var isInfoVisible = false
    @Published var isConversationVisible = false
    @Published var articleSettings = SettingsStore.shared.article
    @Published var screenSettings = SettingsStore.shared.additionalSettings

    func showInfo() { isInfoVisible = true }
    func hideInfo() { isInfoVisible = false }
    func showConversation() { isConversationVisible = true }
    func hideConversation() { isConversationVisible = false }

    func initialize() {
        articleSettings = SettingsStore.shared.article
        screenSettings = SettingsStore.shared.additionalSettings
        // MARK: OpenWeb SDK
        OpenWeb.manager.spotId = article.spotId
        OpenWeb.manager.ui.customizations.customizedTheme.brandColor = UIColor(color)
        ShowcaseScreenConfigurator.applyShowcaseSettings()
    }
}
