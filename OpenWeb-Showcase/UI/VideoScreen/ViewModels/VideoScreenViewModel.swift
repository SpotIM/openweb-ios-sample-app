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
    var title: LocalizedStringResource { vertical.title }
    var videoURLs: [URL] { VideoURLs.all }

    @Published var isInfoVisible = false

    func showInfo() { isInfoVisible = true }
    func hideInfo() { isInfoVisible = false }

    func initialize() {
        // MARK: OpenWeb SDK
        OpenWeb.manager.spotId = article.spotId
        OpenWeb.manager.ui.customizations.customizedTheme.brandColor = OWColor(color)
    }
}
