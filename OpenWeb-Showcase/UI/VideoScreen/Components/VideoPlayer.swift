//
//  VideoPlayer.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 12/04/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import AVFoundation

// MARK: - VideoPlayer

@Observable
final class VideoPlayer {
    private(set) var player: AVQueuePlayer?

    var isActive = false {
        didSet { updatePlayback() }
    }

    private var looper: AVPlayerLooper?

    func setup(url: URL) {
        tearDown()
        let item = AVPlayerItem(url: url)
        let queuePlayer = AVQueuePlayer()
        looper = AVPlayerLooper(player: queuePlayer, templateItem: item)
        player = queuePlayer
        updatePlayback()
    }

    func tearDown() {
        player?.pause()
        player = nil
        looper = nil
    }

    private func updatePlayback() {
        guard isActive else {
            player?.pause()
            return
        }
        player?.play()
    }
}
