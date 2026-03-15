//
//  VideoPlayerPage.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 12/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI
import AVFoundation

struct VideoPlayerPage: View {
    var url: URL
    var isActive: Bool

    @State private var player: AVQueuePlayer?
    @State private var looper: AVPlayerLooper?

    var body: some View {
        VideoLoopingView(player: player)
            .ignoresSafeArea()
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

// MARK: - VideoLoopingView

private struct VideoLoopingView: UIViewRepresentable {
    var player: AVQueuePlayer?

    func makeUIView(context: Context) -> PlayerUIView {
        PlayerUIView()
    }

    func updateUIView(_ uiView: PlayerUIView, context: Context) {
        uiView.playerLayer.player = player
    }
}

// MARK: - PlayerUIView

private class PlayerUIView: UIView {
    let playerLayer = AVPlayerLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        playerLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(playerLayer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
}
