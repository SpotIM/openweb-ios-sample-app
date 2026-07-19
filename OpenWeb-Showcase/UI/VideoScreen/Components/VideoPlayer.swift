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
    private var looper: AVPlayerLooper?

    func setup(url: URL) {
        tearDown()
        let queuePlayer = AVQueuePlayer()
        looper = AVPlayerLooper(player: queuePlayer, templateItem: AVPlayerItem(url: url))
        player = queuePlayer
    }

    func tearDown() {
        player?.pause()
        player = nil
        looper = nil
    }
}
