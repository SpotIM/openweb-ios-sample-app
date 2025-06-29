//
//  ConversationBelowVideoVC.swift
//  OpenWeb-Development
//
//  Created by Alon Haiut on 21/09/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import UIKit
import Combine
import CombineCocoa
import SnapKit
import OpenWebSDK
import AVFoundation
import AVKit

class ConversationBelowVideoVC: UIViewController {

    private struct Metrics {
        static let identifier = "uiviews_examples_vc_id"
        static let verticalMargin: CGFloat = 40
        static let presentAnimationDuration: TimeInterval = 0.3
        static let preConversationHorizontalMargin: CGFloat = 16.0
        static let videoRatio: CGFloat = 9 / 16
        static let keyboardAnimationDuration: CGFloat = 0.25
        static let videoPlayerIdentifier = "video_player_id"
        static let videoLink = "https://test-videos.co.uk/vids/bigbuckbunny/mp4/h264/1080/Big_Buck_Bunny_1080_10s_30MB.mp4"
        // For some reason this longer video isn't working on a simulator, so we will show it only one a real device
        static let videoLink2 = "https://storage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"
    }

    private let viewModel: ConversationBelowVideoViewModeling
    private var cancellables = Set<AnyCancellable>()

    private var preConversation: UIView?
    private var conversation: UIView?
    private var commentCreation: UIView?
    private var reportReasons: UIView?
    private var clarityDetails: UIView?
    private var commentThread: UIView?
    private var webPage: UIView?

    private unowned var conversationTopConstraint: Constraint!
    private unowned var reportReasonsTopConstraint: Constraint!
    private unowned var clarityDetailsTopConstraint: Constraint!
    private unowned var commentThreadTopConstraint: Constraint!
    private unowned var webPageTopConstraint: Constraint!

    // Designed to play with the height
    private unowned var reportReasonsHeightConstraint: Constraint!
    private unowned var clarityDetailsHeightConstraint: Constraint!
    private unowned var commentThreadHeightConstraint: Constraint!
    private unowned var webPageHeightConstraint: Constraint!

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

    private lazy var containerBelowVideo: UIView = {
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
        setupVideo()
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}

private extension ConversationBelowVideoVC {
    func applyAccessibility() {
        view.accessibilityIdentifier = Metrics.identifier
        videoPlayerContainer.accessibilityIdentifier = Metrics.videoPlayerIdentifier
    }

    @objc func setupViews() {
        view.backgroundColor = ColorPalette.shared.color(type: .background)
        self.navigationItem.largeTitleDisplayMode = .never

        // Adding video player view
        view.addSubview(videoPlayerContainer)
        videoPlayerContainer.snp.makeConstraints { make in
            make.leading.trailing.top.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(videoPlayerContainer.snp.width).multipliedBy(Metrics.videoRatio)
        }

        // Adding container below video
        view.addSubview(containerBelowVideo)
        containerBelowVideo.snp.makeConstraints { make in
            make.top.equalTo(videoPlayerContainer.snp.bottom)
            make.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }

    // swiftlint:disable function_body_length
    func setupObservers() {
        title = viewModel.outputs.title

        // Showing error if needed
        viewModel.outputs.componentRetrievingError
            .sink(receiveValue: { [weak self] err in
                self?.showError(message: err.description)
            })
            .store(in: &cancellables)

        viewModel.outputs.preConversationRetrieved
            .sink(receiveValue: { [weak self] view in
                self?.handlePreConversationRetrieved(view: view)
            })
            .store(in: &cancellables)

        viewModel.outputs.conversationRetrieved
            .sink(receiveValue: { [weak self] view in
                self?.handleConversationRetrieved(view: view)
            })
            .store(in: &cancellables)

        viewModel.outputs.commentCreationRetrieved
            .sink(receiveValue: { [weak self] view in
                self?.handleCommentCreationRetrieved(view: view)
            })
            .store(in: &cancellables)

        viewModel.outputs.reportReasonsRetrieved
            .sink(receiveValue: { [weak self] view in
                guard let self else { return }
                self.handleRetrieved(component: view,
                                     assignToComponent: &self.reportReasons,
                                     topConstraint: &self.reportReasonsTopConstraint,
                                     heightConstraint: &self.reportReasonsHeightConstraint,
                                     putWithAnimationOnComponent: self.conversation)
            })
            .store(in: &cancellables)

        viewModel.outputs.commentThreadRetrieved
            .sink(receiveValue: { [weak self] view in
                guard let self else { return }
                self.handleRetrieved(component: view,
                                     assignToComponent: &self.commentThread,
                                     topConstraint: &self.commentThreadTopConstraint,
                                     heightConstraint: &self.commentThreadHeightConstraint,
                                     putWithAnimationOnComponent: self.conversation)
            })
            .store(in: &cancellables)

        viewModel.outputs.clarityDetailsRetrieved
            .sink(receiveValue: { [weak self] view in
                guard let self else { return }
                self.handleRetrieved(component: view,
                                     assignToComponent: &self.clarityDetails,
                                     topConstraint: &self.clarityDetailsTopConstraint,
                                     heightConstraint: &self.clarityDetailsHeightConstraint,
                                     putWithAnimationOnComponent: self.conversation)
            })
            .store(in: &cancellables)

        viewModel.outputs.webPageRetrieved
            .sink(receiveValue: { [weak self] view in
                guard let self else { return }
                self.handleRetrieved(component: view,
                                     assignToComponent: &self.webPage,
                                     topConstraint: &self.webPageTopConstraint,
                                     heightConstraint: &self.webPageHeightConstraint,
                                     putWithAnimationOnComponent: self.conversation)
            })
            .store(in: &cancellables)

        viewModel.outputs.removeConversation
            .sink(receiveValue: { [weak self] _ in
                guard let self else { return }
                self.handleRemoveWithAnimation(component: &self.conversation,
                                               componentTopConstraint: self.conversationTopConstraint)
            })
            .store(in: &cancellables)

        viewModel.outputs.removeReportReasons
            .sink(receiveValue: { [weak self] _ in
                guard let self else { return }
                self.handleRemoveWithAnimation(component: &self.reportReasons,
                                               componentTopConstraint: self.reportReasonsTopConstraint)
            })
            .store(in: &cancellables)

        viewModel.outputs.removeClarityDetails
            .sink(receiveValue: { [weak self] _ in
                guard let self else { return }
                self.handleRemoveWithAnimation(component: &self.clarityDetails,
                                               componentTopConstraint: self.clarityDetailsTopConstraint)
            })
            .store(in: &cancellables)

        viewModel.outputs.removeCommentThread
            .sink(receiveValue: { [weak self] _ in
                guard let self else { return }
                self.handleRemoveWithAnimation(component: &self.commentThread,
                                               componentTopConstraint: self.commentThreadTopConstraint)
            })
            .store(in: &cancellables)

        viewModel.outputs.removeWebPage
            .sink(receiveValue: { [weak self] _ in
                guard let self else { return }
                self.handleRemoveWithAnimation(component: &self.webPage,
                                               componentTopConstraint: self.webPageTopConstraint)
            })
            .store(in: &cancellables)

        viewModel.outputs.removeCommentCreation
            .sink(receiveValue: { [weak self] _ in
                self?.handleRemoveCommentCreation()
            })
            .store(in: &cancellables)

        viewModel.outputs.openAuthentication
            .flatMap { [weak self] result -> AnyPublisher<OWBasicCompletion, Never> in
                guard let self else { return Empty().eraseToAnyPublisher() }
                let spotId = result.0
                let completion = result.1
                let authenticationVM = AuthenticationPlaygroundViewModel(filterBySpotId: spotId)
                let authenticationVC = AuthenticationPlaygroundVC(viewModel: authenticationVM)
                self.navigationController?.present(authenticationVC, animated: true)

                return authenticationVM.outputs.dismissed
                    .prefix(1)
                    .map { completion }
                    .eraseToAnyPublisher()
            }
            .sink(receiveValue: { completion in
                completion()
            })
            .store(in: &cancellables)

        let keyboardShowHeight = NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .map { notification -> CGFloat in
                let height = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height
                return height ?? 0
            }

        let keyboardHideHeight = NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .map { _ -> CGFloat in
                0
            }

        let keyboardHeight = Publishers.Merge(keyboardShowHeight, keyboardHideHeight)

        // Chaning report reasons height according to the keyboard
        keyboardHeight
            .sink(receiveValue: { [weak self] height in
                guard let self, self.reportReasons != nil,
                let reportReasonsHeightConstraint else { return }
                let adjustedHeight = height == 0 ? 0 : height - self.view.safeAreaInsets.bottom
                reportReasonsHeightConstraint.update(offset: -adjustedHeight)
                UIView.animate(withDuration: Metrics.keyboardAnimationDuration) {
                    self.view.layoutIfNeeded()
                }
            })
            .store(in: &cancellables)

        // Changing clarity details height according to the keyboard
        keyboardHeight
            .sink(receiveValue: { [weak self] height in
                guard let self, self.clarityDetails != nil,
                let clarityDetailsHeightConstraint else { return }
                let adjustedHeight = height == 0 ? 0 : height - self.view.safeAreaInsets.bottom
                clarityDetailsHeightConstraint.update(offset: -adjustedHeight)
                UIView.animate(withDuration: Metrics.keyboardAnimationDuration) {
                    self.view.layoutIfNeeded()
                }
            })
            .store(in: &cancellables)
    }

    func setupVideo() {
        self.view.layoutIfNeeded()
        videoPlayerLayer.frame = videoPlayerContainer.bounds
        videoQueuePlayer.play()
    }

    func handlePreConversationRetrieved(view: UIView) {
        // 1. Remove pre conversation from UI hierarchy if for some reason it was already retrieved
        if let preConversationView = preConversation {
            preConversationView.removeFromSuperview()
            preConversation = nil
        }

        // 2. Set pre conversation and add to the UI hierarchy
        preConversation = view
        containerBelowVideo.addSubview(view)
        view.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Metrics.verticalMargin)
            make.leading.trailing.equalToSuperview().inset(Metrics.preConversationHorizontalMargin)
        }
    }

    func handleConversationRetrieved(view: UIView) {
        // 1. Remove conversation from UI hierarchy
        if let conversationView = conversation {
            conversationView.removeFromSuperview()
            conversation = nil
        }

        // 2. Set conversation and add to the UI hierarchy with animation from the bottom
        // Intentionnaly adding on the main `view` and not on `containerBelowVideo`, so later on we will be able to extend on the entire screen with a pan gesture on the conversation header
        conversation = view
        self.view.addSubview(view)
        view.snp.makeConstraints { make in
            conversationTopConstraint = make.top.equalTo(self.view.snp.bottom).constraint
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(containerBelowVideo.snp.height)
        }
        self.view.layoutIfNeeded()

        // 3. Perform animation
        let offset = -containerBelowVideo.frame.height - self.view.safeAreaInsets.bottom
        conversationTopConstraint.update(offset: offset)
        UIView.animate(withDuration: Metrics.presentAnimationDuration) { [weak self] in
            guard let self else { return }
            self.view.layoutIfNeeded()
        } completion: { _ in
            // Nothing here
        }
    }

    func handleCommentCreationRetrieved(view: UIView) {
        // 1. Remove comment creation from UI hierarchy
        if let commentCreationView = commentCreation {
            commentCreationView.removeFromSuperview()
            commentCreation = nil
        }

        // 2. Set comment creation and add to the UI hierarchy. Animation will happen internally in the component
        guard let conversationView = conversation else { return }
        commentCreation = view
        conversationView.addSubview(view)
        view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    func handleRetrieved(component: UIView,
                         assignToComponent componentToAssignOn: inout UIView?,
                         topConstraint: inout Constraint!,
                         heightConstraint: inout Constraint!,
                         putWithAnimationOnComponent baseComponent: UIView?) {
        // 1. Remove report reasons from UI hierarchy
        if let existedComponent = componentToAssignOn {
            existedComponent.removeFromSuperview()
            componentToAssignOn = nil
        }

        // 2. Set report reasons and add to the UI hierarchy with animation from the bottom
        // Adding on the `conversationView`
        guard let baseComponentView = baseComponent else { return }
        componentToAssignOn = component
        baseComponentView.addSubview(component)
        component.snp.makeConstraints { make in
            topConstraint = make.top.equalTo(baseComponentView.snp.bottom).offset(self.view.safeAreaInsets.bottom).constraint
            make.leading.trailing.equalToSuperview()
            heightConstraint = make.height.equalTo(baseComponentView.snp.height).constraint
        }
        self.view.layoutIfNeeded()

        // 3. Perform animation
        let offset = -baseComponentView.frame.height
        topConstraint.update(offset: offset)
        UIView.animate(withDuration: Metrics.presentAnimationDuration) { [weak self] in
            guard let self else { return }
            self.view.layoutIfNeeded()
        } completion: { _ in
            // Nothing here
        }
    }

    func handleRemoveWithAnimation(component: inout UIView?, componentTopConstraint: Constraint) {
        guard component != nil else { return }

        // 1. Perform animation
        componentTopConstraint.update(offset: 0)
        UIView.animate(withDuration: Metrics.presentAnimationDuration) { [weak self] in
            guard let self else { return }
            self.view.layoutIfNeeded()
        } completion: { [weak component] _ in
            component?.removeFromSuperview()
            component = nil
        }
    }

    func handleRemoveCommentCreation() {
        guard let commentCreationView = commentCreation else { return }

        commentCreationView.removeFromSuperview()
        commentCreation = nil
    }

    func showError(message: String) {
        let alert = UIAlertController(title: "Error retrieving component", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
