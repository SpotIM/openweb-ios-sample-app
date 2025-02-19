//
//  ConversationBelowVideoVC.swift
//  OpenWeb-Development
//
//  Created by Alon Haiut on 21/09/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
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
    private let disposeBag = DisposeBag()

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

    func setupViews() {
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
            .subscribe(onNext: { [weak self] err in
                self?.showError(message: err.description)
            })
            .disposed(by: disposeBag)

        viewModel.outputs.preConversationRetrieved
            .subscribe(onNext: { [weak self] view in
                self?.handlePreConversationRetrieved(view: view)
            })
            .disposed(by: disposeBag)

        viewModel.outputs.conversationRetrieved
            .subscribe(onNext: { [weak self] view in
                self?.handleConversationRetrieved(view: view)
            })
            .disposed(by: disposeBag)

        viewModel.outputs.commentCreationRetrieved
            .subscribe(onNext: { [weak self] view in
                self?.handleCommentCreationRetrieved(view: view)
            })
            .disposed(by: disposeBag)

        viewModel.outputs.reportReasonsRetrieved
            .subscribe(onNext: { [weak self] view in
                guard let self else { return }
                self.handleRetrieved(component: view,
                                     assignToComponent: &self.reportReasons,
                                     topConstraint: &self.reportReasonsTopConstraint,
                                     heightConstraint: &self.reportReasonsHeightConstraint,
                                     putWithAnimationOnComponent: self.conversation)
            })
            .disposed(by: disposeBag)

        viewModel.outputs.commentThreadRetrieved
            .subscribe(onNext: { [weak self] view in
                guard let self else { return }
                self.handleRetrieved(component: view,
                                     assignToComponent: &self.commentThread,
                                     topConstraint: &self.commentThreadTopConstraint,
                                     heightConstraint: &self.commentThreadHeightConstraint,
                                     putWithAnimationOnComponent: self.conversation)
            })
            .disposed(by: disposeBag)

        viewModel.outputs.clarityDetailsRetrieved
            .subscribe(onNext: { [weak self] view in
                guard let self else { return }
                self.handleRetrieved(component: view,
                                     assignToComponent: &self.clarityDetails,
                                     topConstraint: &self.clarityDetailsTopConstraint,
                                     heightConstraint: &self.clarityDetailsHeightConstraint,
                                     putWithAnimationOnComponent: self.conversation)
            })
            .disposed(by: disposeBag)

        viewModel.outputs.webPageRetrieved
            .subscribe(onNext: { [weak self] view in
                guard let self else { return }
                self.handleRetrieved(component: view,
                                     assignToComponent: &self.webPage,
                                     topConstraint: &self.webPageTopConstraint,
                                     heightConstraint: &self.webPageHeightConstraint,
                                     putWithAnimationOnComponent: self.conversation)
            })
            .disposed(by: disposeBag)

        viewModel.outputs.removeConversation
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                self.handleRemoveWithAnimation(component: &self.conversation,
                                               componentTopConstraint: self.conversationTopConstraint)
            })
            .disposed(by: disposeBag)

        viewModel.outputs.removeReportReasons
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                self.handleRemoveWithAnimation(component: &self.reportReasons,
                                               componentTopConstraint: self.reportReasonsTopConstraint)
            })
            .disposed(by: disposeBag)

        viewModel.outputs.removeClarityDetails
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                self.handleRemoveWithAnimation(component: &self.clarityDetails,
                                               componentTopConstraint: self.clarityDetailsTopConstraint)
            })
            .disposed(by: disposeBag)

        viewModel.outputs.removeCommentThread
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                self.handleRemoveWithAnimation(component: &self.commentThread,
                                               componentTopConstraint: self.commentThreadTopConstraint)
            })
            .disposed(by: disposeBag)

        viewModel.outputs.removeWebPage
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                self.handleRemoveWithAnimation(component: &self.webPage,
                                               componentTopConstraint: self.webPageTopConstraint)
            })
            .disposed(by: disposeBag)

        viewModel.outputs.removeCommentCreation
            .subscribe(onNext: { [weak self] _ in
                self?.handleRemoveCommentCreation()
            })
            .disposed(by: disposeBag)

        viewModel.outputs.openAuthentication
            .flatMap { [weak self] result -> Observable<OWBasicCompletion> in
                guard let self else { return Observable.empty() }
                let spotId = result.0
                let completion = result.1
                let authenticationVM = AuthenticationPlaygroundViewModel(filterBySpotId: spotId)
                let authenticationVC = AuthenticationPlaygroundVC(viewModel: authenticationVM)
                self.navigationController?.present(authenticationVC, animated: true)

                return authenticationVM.outputs.dismissed
                    .asObservable()
                    .take(1)
                    .map { completion }
            }
            .subscribe(onNext: { completion in
                completion()
            })
            .disposed(by: disposeBag)

        let keyboardShowHeight = NotificationCenter.default.rx
            .notification(UIResponder.keyboardWillShowNotification)
            .map { notification -> CGFloat in
                let height = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height
                return height ?? 0
            }

        let keyboardHideHeight = NotificationCenter.default.rx
            .notification(UIResponder.keyboardWillHideNotification)
            .map { _ -> CGFloat in
                0
            }

        let keyboardHeight = Observable.from([keyboardShowHeight, keyboardHideHeight])
            .merge()

        // Chaning report reasons height according to the keyboard
        keyboardHeight
            .subscribe(onNext: { [weak self] height in
                guard let self, self.reportReasons != nil,
                let reportReasonsHeightConstraint = self.reportReasonsHeightConstraint else { return }
                let adjustedHeight = height == 0 ? 0 : height - self.view.safeAreaInsets.bottom
                reportReasonsHeightConstraint.update(offset: -adjustedHeight)
                UIView.animate(withDuration: Metrics.keyboardAnimationDuration) {
                    self.view.layoutIfNeeded()
                }
            })
            .disposed(by: disposeBag)

        // Changing clarity details height according to the keyboard
        keyboardHeight
            .subscribe(onNext: { [weak self] height in
                guard let self, self.clarityDetails != nil,
                let clarityDetailsHeightConstraint = self.clarityDetailsHeightConstraint else { return }
                let adjustedHeight = height == 0 ? 0 : height - self.view.safeAreaInsets.bottom
                clarityDetailsHeightConstraint.update(offset: -adjustedHeight)
                UIView.animate(withDuration: Metrics.keyboardAnimationDuration) {
                    self.view.layoutIfNeeded()
                }
            })
            .disposed(by: disposeBag)
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
