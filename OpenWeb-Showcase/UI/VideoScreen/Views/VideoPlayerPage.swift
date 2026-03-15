//
//  VideoPlayerPage.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 12/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI
import AVFoundation

// MARK: - Metrics

private struct Metrics {
    static let bottomContentLeadingPadding: CGFloat = 20
    static let bottomContentTrailingPadding: CGFloat = 92
    static let bottomContentBottomPadding: CGFloat = 36
}

// MARK: - VideoPlayerPage

struct VideoPlayerPage: View {
    var url: URL
    var isActive: Bool

    @State private var player: AVQueuePlayer?
    @State private var looper: AVPlayerLooper?

    var body: some View {
        ZStack {
            VideoLoopingView(player: player)
                .ignoresSafeArea()
            VideoBottomContent()
                .padding(.leading, Metrics.bottomContentLeadingPadding)
                .padding(.trailing, Metrics.bottomContentTrailingPadding)
                .padding(.bottom, Metrics.bottomContentBottomPadding)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
            VideoActionButtons()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
        }
        .onAppear { setupPlayer() }
        .onDisappear { tearDownPlayer() }
        .onChange(of: isActive) { active in
            active ? player?.play() : player?.pause()
        }
    }
}

// MARK: - Private

private extension VideoPlayerPage {
    func setupPlayer() {
        let item = AVPlayerItem(url: url)
        let queuePlayer = AVQueuePlayer()
        looper = AVPlayerLooper(player: queuePlayer, templateItem: item)
        player = queuePlayer

        if isActive {
            queuePlayer.play()
        }
    }

    func tearDownPlayer() {
        player?.pause()
        player = nil
        looper = nil
    }
}
