//
//  ConversationBelowVideoVC.swift
//  Spot-IM.Development
//
//  Created by Alon Haiut on 21/09/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

#if NEW_API

class ConversationBelowVideoVC: UIViewController {

    fileprivate struct Metrics {
        static let identifier = "uiviews_examples_vc_id"
        static let verticalMargin: CGFloat = 20
        static let horizontalMargin: CGFloat = 20
        static let videoRatio: CGFloat = 9/16
        static let videoPlayerIdentifier = "video_player_id"
    }

    fileprivate let viewModel: ConversationBelowVideoViewModeling
    fileprivate let disposeBag = DisposeBag()

    fileprivate lazy var videoPlayer: UIView = {
        let view = UIView()
            .backgroundColor(.green)
        return view
    }()

    fileprivate lazy var containerBelowVideo: UIView = {
        let view = UIView()
            .backgroundColor(ColorPalette.shared.color(type: .background))
        return view
    }()

    init(viewModel: ConversationBelowVideoViewModeling) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        super.loadView()
        setupViews()
        applyAccessibility()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupObservers()
    }
}

fileprivate extension ConversationBelowVideoVC {
    func applyAccessibility() {
        view.accessibilityIdentifier = Metrics.identifier
        videoPlayer.accessibilityIdentifier = Metrics.videoPlayerIdentifier
    }

    func setupViews() {
        view.backgroundColor = ColorPalette.shared.color(type: .background)
        self.navigationItem.largeTitleDisplayMode = .never

        // Adding video player view
        view.addSubview(videoPlayer)
        videoPlayer.snp.makeConstraints { make in
            make.leading.trailing.top.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(videoPlayer.snp.width).multipliedBy(Metrics.videoRatio)
        }

        // Adding container below video
        view.addSubview(containerBelowVideo)
        containerBelowVideo.snp.makeConstraints { make in
            make.top.equalTo(videoPlayer.snp.bottom)
            make.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }

    func setupObservers() {
        title = viewModel.outputs.title
    }
}

#endif
