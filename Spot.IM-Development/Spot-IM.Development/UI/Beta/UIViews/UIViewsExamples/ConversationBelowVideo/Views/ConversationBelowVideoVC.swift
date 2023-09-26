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
import SpotImCore

#if NEW_API

class ConversationBelowVideoVC: UIViewController {

    fileprivate struct Metrics {
        static let identifier = "uiviews_examples_vc_id"
        static let verticalMargin: CGFloat = 40
        static let horizontalMargin: CGFloat = 20
        static let presentAnimationDuration: TimeInterval = 0.3
        static let preConversationHorizontalMargin: CGFloat = 16.0
        static let videoRatio: CGFloat = 9/16
        static let videoPlayerIdentifier = "video_player_id"
    }

    fileprivate let viewModel: ConversationBelowVideoViewModeling
    fileprivate let disposeBag = DisposeBag()

    fileprivate var preConversation: UIView?
    fileprivate var conversation: UIView?
    fileprivate var commentCreation: UIView?
    fileprivate var reportReasons: UIView?

    fileprivate unowned var conversationTopConstraint: Constraint!
    fileprivate unowned var reportReasonsTopConstraint: Constraint!

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
                self?.handleReportReasonsRetrieved(view: view)
            })
            .disposed(by: disposeBag)

        viewModel.outputs.removeConversation
            .subscribe(onNext: { [weak self] _ in
                self?.handleRemoveConversation()
            })
            .disposed(by: disposeBag)

        viewModel.outputs.removeReportReasons
            .subscribe(onNext: { [weak self] _ in
                self?.handleRemoveReportReasons()
            })
            .disposed(by: disposeBag)

        viewModel.outputs.removeCommentCreation
            .subscribe(onNext: { [weak self] _ in
                self?.handleRemoveCommentCreation()
            })
            .disposed(by: disposeBag)

        viewModel.outputs.openAuthentication
            .flatMap { [weak self] result -> Observable<OWBasicCompletion> in
                guard let self = self else { return Observable.empty() }
                let spotId = result.0
                let completion = result.1
                let authenticationVM = AuthenticationPlaygroundNewAPIViewModel(filterBySpotId: spotId)
                let authenticationVC = AuthenticationPlaygroundNewAPIVC(viewModel: authenticationVM)
                self.navigationController?.present(authenticationVC, animated: true)

                return authenticationVM.outputs.dismissed
                    .take(1)
                    .map { completion }
            }
            .subscribe(onNext: { completion in
                completion()
            })
            .disposed(by: disposeBag)
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
        let offset = -containerBelowVideo.frame.height-self.view.safeAreaInsets.bottom
        conversationTopConstraint.update(offset: offset)
        UIView.animate(withDuration: Metrics.presentAnimationDuration) { [weak self] in
            guard let self = self else { return }
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

    func handleReportReasonsRetrieved(view: UIView) {
        // 1. Remove report reasons from UI hierarchy
        if let reportReasonsView = reportReasons {
            reportReasonsView.removeFromSuperview()
            reportReasons = nil
        }

        // 2. Set report reasons and add to the UI hierarchy with animation from the bottom
        // Adding on the `conversationView`
        guard let conversationView = conversation else { return }
        reportReasons = view
        conversationView.addSubview(view)
        view.snp.makeConstraints { make in
            reportReasonsTopConstraint = make.top.equalTo(conversationView.snp.bottom).offset(self.view.safeAreaInsets.bottom).constraint
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(conversationView.snp.height)
        }
        self.view.layoutIfNeeded()

        // 3. Perform animation
        let offset = -conversationView.frame.height
        reportReasonsTopConstraint.update(offset: offset)
        UIView.animate(withDuration: Metrics.presentAnimationDuration) { [weak self] in
            guard let self = self else { return }
            self.view.layoutIfNeeded()
        } completion: { _ in
            // Nothing here
        }
    }

    func handleRemoveConversation() {
        guard conversation != nil else { return }

        // 1. Perform animation
        conversationTopConstraint.update(offset: 0)
        UIView.animate(withDuration: Metrics.presentAnimationDuration) { [weak self] in
            guard let self = self else { return }
            self.view.layoutIfNeeded()
        } completion: { [weak self] _ in
            guard let self = self else { return }
            self.conversation?.removeFromSuperview()
            self.conversation = nil
        }
    }

    func handleRemoveReportReasons() {
        guard reportReasons != nil else { return }

        // 1. Perform animation
        reportReasonsTopConstraint.update(offset: 0)
        UIView.animate(withDuration: Metrics.presentAnimationDuration) { [weak self] in
            guard let self = self else { return }
            self.view.layoutIfNeeded()
        } completion: { [weak self] _ in
            guard let self = self else { return }
            self.reportReasons?.removeFromSuperview()
            self.reportReasons = nil
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

#endif
