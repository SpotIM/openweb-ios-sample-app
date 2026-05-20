//
//  VideoLoopingView.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 12/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI
import AVFoundation

// MARK: - VideoLoopingView

struct VideoLoopingView: UIViewRepresentable {
    var player: AVQueuePlayer?
    var isActive: Bool

    func makeUIView(context: Context) -> PlayerUIView {
        PlayerUIView()
    }

    func updateUIView(_ uiView: PlayerUIView, context: Context) {
        if uiView.playerLayer.player !== player {
            print("[VideoScreen] updateUIView: layer \(uiView.playerLayer.player != nil ? "set" : "nil") → \(player != nil ? "set" : "nil")")
            uiView.playerLayer.player = player
        }
        print("[VideoScreen] updateUIView: \(isActive ? "play" : "pause")")
        isActive ? player?.play() : player?.pause()
    }
}

// MARK: - PlayerUIView

class PlayerUIView: UIView {
    let playerLayer = AVPlayerLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        playerLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(playerLayer)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
}
