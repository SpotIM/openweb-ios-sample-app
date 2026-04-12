//
//  VideoPlayer.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 12/04/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import AVFoundation
import Combine

// MARK: - VideoPlayer

@Observable
final class VideoPlayer {
    private(set) var player: AVQueuePlayer?

    var isActive = false {
        didSet { updatePlayback() }
    }

    private var looper: AVPlayerLooper?
    private var cancellables = Set<AnyCancellable>()

    func setup(url: URL) {
        tearDown()
        let item = AVPlayerItem(url: url)
        let queuePlayer = AVQueuePlayer()
        looper = AVPlayerLooper(player: queuePlayer, templateItem: item)
        player = queuePlayer

        queuePlayer.publisher(for: \.currentItem?.status)
            .compactMap { $0 }
            .filter { $0 == .readyToPlay }
            .prefix(1)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updatePlayback()
            }
            .store(in: &cancellables)

        updatePlayback()
    }

    func tearDown() {
        cancellables.removeAll()
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
