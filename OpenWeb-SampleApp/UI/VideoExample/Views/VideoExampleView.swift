//
//  VideoExampleView.swift
//  OpenWeb-SampleApp
//
//  Created by Alon Shprung on 28/09/2025.
//

import Combine
import UIKit
import SnapKit
import AVFoundation
import AVKit

class VideoExampleView: UIView {
    private struct Metrics {
        static let videoRatio: CGFloat = 9 / 16 // swiftlint:disable:this no_magic_numbers
        static let videoPlayerIdentifier = "video_player_id"
        static let videoLink = "https://test-videos.co.uk/vids/bigbuckbunny/mp4/h264/1080/Big_Buck_Bunny_1080_10s_30MB.mp4"
        // For some reason this longer video isn't working on a simulator, so we will show it only one a real device
        static let videoLink2 = "https://storage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"
    }

    private let viewModel: VideoExampleViewModeling
    private var cancellables = Set<AnyCancellable>()

    private lazy var videoPlayerItem: AVPlayerItem = {
        let urlString: String
        #if targetEnvironment(simulator)
        urlString = Metrics.videoLink
        #else
        urlString = Metrics.videoLink2
        #endif

        let videoURL = URL(string: urlString)
        let playerItem = AVPlayerItem(url: videoURL!)
        return playerItem
    }()

    private lazy var videoQueuePlayer: AVQueuePlayer = {
        let queuePlayer = AVQueuePlayer(playerItem: videoPlayerItem)
        return queuePlayer
    }()

    private lazy var videoPlayerLooper: AVPlayerLooper = {
        let playerLooper = AVPlayerLooper(player: self.videoQueuePlayer, templateItem: self.videoPlayerItem)
        return playerLooper
    }()

    private lazy var videoPlayerLayer: AVPlayerLayer = {
        let playerLayer = AVPlayerLayer(player: self.videoQueuePlayer)
        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        // Looper should be initialize at some point - the following line basically do that
        _ = self.videoPlayerLooper
        return playerLayer
    }()

    private lazy var imgViewPlaceholder: UIImageView = {
        return UIImageView()
            .image(UIImage(named: "video_placeholder")!)
            .contentMode(.scaleAspectFill)
    }()

    private lazy var videoPlayerContainer: UIView = {
        let view = UIView()
            .backgroundColor(.clear)

        view.addSubview(imgViewPlaceholder)
        imgViewPlaceholder.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        view.layer.addSublayer(videoPlayerLayer)
        return view
    }()

    init(viewModel: VideoExampleViewModeling) {
        self.viewModel = viewModel
        super.init(frame: CGRect.zero)

        setupViews()
        applyAccessibility()
        setupObservers()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        videoPlayerLayer.frame = videoPlayerContainer.bounds
    }
}

private extension VideoExampleView {
    func applyAccessibility() {
        videoPlayerContainer.accessibilityIdentifier = Metrics.videoPlayerIdentifier
    }

    func setupViews() {
        addSubview(videoPlayerContainer)
        videoPlayerContainer.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview()
            make.height.equalTo(videoPlayerContainer.snp.width).multipliedBy(Metrics.videoRatio)
        }
    }

    func setupObservers() {
        viewModel.outputs.startPlayingVideo
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                guard let self else { return }
                self.videoQueuePlayer.play()
            })
            .store(in: &cancellables)
    }
}
