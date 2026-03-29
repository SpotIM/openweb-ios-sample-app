//
//  VideoScreenViewModel.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 12/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI
import Combine

class VideoScreenViewModel: ObservableObject {
    private let vertical: ShowcaseVertical = .video

    var article: ArticleData { vertical.article }
    var sdkUsageInfo: SDKUsageInfo { vertical.sdkUsageInfo }
    var color: Color { vertical.color }
    var videoURLs: [URL] { VideoURLs.shuffled }

    @Published var isInfoVisible = false
    @Published var isConversationVisible = false
    @Published var articleSettings = SettingsManager.shared.article
    @Published var screenSettings = SettingsManager.shared.additionalSettings

    func showInfo() { isInfoVisible = true }
    func hideInfo() { isInfoVisible = false }
    func showConversation() { isConversationVisible = true }
    func hideConversation() { isConversationVisible = false }

    func initialize() {
        articleSettings = SettingsManager.shared.article
        screenSettings = SettingsManager.shared.additionalSettings
        ShowcaseScreenConfigurator.configure(article: article, brandColor: color)
    }
}
