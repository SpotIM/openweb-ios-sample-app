//
//  VideoPlayerPage.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 12/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI

// MARK: - VideoPlayerPage

struct VideoPlayerPage: View {
    private struct Metrics {
        static let bottomContentLeadingPadding: CGFloat = 20
        static let bottomContentTrailingPadding: CGFloat = 92
        static let bottomContentBottomPadding: CGFloat = 36
    }

    var url: URL
    var isActive: Bool
    var commentsCount: Int
    var onCommentTap: () -> Void = {}
    var onInfoTap: () -> Void = {}

    @State private var videoPlayer = VideoPlayer()

    var body: some View {
        ZStack {
            VideoLoopingView(player: videoPlayer.player)
                .ignoresSafeArea()
            VideoBottomContent()
                .padding(.leading, Metrics.bottomContentLeadingPadding)
                .padding(.trailing, Metrics.bottomContentTrailingPadding)
                .padding(.bottom, Metrics.bottomContentBottomPadding)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
            VideoActionButtons(commentsCount: commentsCount, onCommentTap: onCommentTap, onInfoTap: onInfoTap)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
        }
        .onAppear {
            videoPlayer.isActive = isActive
            videoPlayer.setup(url: url)
        }
        .onDisappear { videoPlayer.tearDown() }
        .onChange(of: isActive) { _, active in videoPlayer.isActive = active }
    }
}
