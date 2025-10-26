//
//  UIFlowsVC.swift
//  OpenWeb-Development
//
//  Created by Revital Pisman on 04/12/2022.
//  Copyright © 2022 OpenWeb. All rights reserved.
//

import UIKit
import Combine
import CombineCocoa
import SnapKit

class UIFlowsVC: UIViewController {

    private struct Metrics {
        static let identifier = "uiflows_vc_id"
        static let btnPreConversationPushModeIdentifier = "btn_pre_conversation_push_mode_id"
        static let btnPreConversationPresentModeIdentifier = "btn_pre_conversation_present_mode_id"
        static let btnFullConversationPushModeIdentifier = "btn_full_conversation_push_mode_id"
        static let btnFullConversationPresentModeIdentifier = "btn_full_conversation_present_mode_id"
        static let btnCommentCreationPushModeIdentifier = "btn_comment_creation_push_mode_id"
        static let btnCommentCreationPresentModeIdentifier = "btn_comment_creation_present_mode_id"
        static let btnCommentThreadPushModeIdentifier = "btn_comment_thread_push_mode_id"
        static let btnCommentThreadPresentModeIdentifier = "btn_comment_thread_present_mode_id"
        static let btnMonetizationIdentifier = "btn_monetization_id"
        static let verticalMargin: CGFloat = 40
        static let horizontalMargin: CGFloat = 50
        static let buttonVerticalMargin: CGFloat = 20
        static let buttonHeight: CGFloat = 50
    }

    private let viewModel: UIFlowsViewModeling
    private var cancellables = Set<AnyCancellable>()

    private lazy var scrollView: UIScrollView = {
        var scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()

    private lazy var btnPreConversationPushMode: UIButton = {
        return NSLocalizedString("PreConversationPushMode", comment: "").blueRoundedButton
    }()

    private lazy var btnPreConversationPresentMode: UIButton = {
        return NSLocalizedString("PreConversationPresentMode", comment: "").blueRoundedButton
    }()

    private lazy var btnFullConversationPushMode: UIButton = {
        return NSLocalizedString("FullConversationPushMode", comment: "").blueRoundedButton
    }()

    private lazy var btnFullConversationPresentMode: UIButton = {
        return NSLocalizedString("FullConversationPresentMode", comment: "").blueRoundedButton
    }()

    private lazy var btnCommentCreationPushMode: UIButton = {
        return NSLocalizedString("CommentCreationPushMode", comment: "").blueRoundedButton
    }()

    private lazy var btnCommentCreationPresentMode: UIButton = {
        return NSLocalizedString("CommentCreationPresentMode", comment: "").blueRoundedButton
    }()

    private lazy var btnCommentThreadPushMode: UIButton = {
        return NSLocalizedString("CommentThreadPushMode", comment: "").blueRoundedButton
    }()

    private lazy var btnCommentThreadPresentMode: UIButton = {
        return NSLocalizedString("CommentThreadPresentMode", comment: "").blueRoundedButton
    }()

    private lazy var btnMonetization: UIButton = {
        return NSLocalizedString("Monetization", comment: "").blueRoundedButton
    }()

    init(viewModel: UIFlowsViewModeling) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        applyAccessibility()
        setupObservers()
    }
}

private extension UIFlowsVC {
    func applyAccessibility() {
        view.accessibilityIdentifier = Metrics.identifier
        btnPreConversationPushMode.accessibilityIdentifier = Metrics.btnPreConversationPushModeIdentifier
        btnPreConversationPresentMode.accessibilityIdentifier = Metrics.btnPreConversationPresentModeIdentifier
        btnFullConversationPushMode.accessibilityIdentifier = Metrics.btnFullConversationPushModeIdentifier
        btnFullConversationPresentMode.accessibilityIdentifier = Metrics.btnFullConversationPresentModeIdentifier
        btnCommentCreationPushMode.accessibilityIdentifier = Metrics.btnCommentCreationPushModeIdentifier
        btnCommentCreationPresentMode.accessibilityIdentifier = Metrics.btnCommentCreationPresentModeIdentifier
        btnCommentThreadPushMode.accessibilityIdentifier = Metrics.btnCommentThreadPushModeIdentifier
        btnCommentThreadPresentMode.accessibilityIdentifier = Metrics.btnCommentThreadPresentModeIdentifier
        btnMonetization.accessibilityIdentifier = Metrics.btnMonetizationIdentifier
    }

    @objc func setupViews() {
        view.backgroundColor = ColorPalette.shared.color(type: .background)
        self.navigationItem.largeTitleDisplayMode = .never

        // Adding scroll view
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide)
        }

        // Adding pre conversation buttons
        scrollView.addSubview(btnPreConversationPushMode)
        btnPreConversationPushMode.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(Metrics.buttonHeight)
            make.top.equalTo(scrollView).offset(Metrics.verticalMargin)
            make.leading.equalTo(scrollView).offset(Metrics.horizontalMargin)
            make.top.equalTo(scrollView.contentLayoutGuide).offset(Metrics.verticalMargin)
        }

        scrollView.addSubview(btnPreConversationPresentMode)
        btnPreConversationPresentMode.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(Metrics.buttonHeight)
            make.top.equalTo(btnPreConversationPushMode.snp.bottom).offset(Metrics.buttonVerticalMargin)
            make.leading.equalTo(scrollView).offset(Metrics.horizontalMargin)
        }

        // Adding full conversation buttons
        scrollView.addSubview(btnFullConversationPushMode)
        btnFullConversationPushMode.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(Metrics.buttonHeight)
            make.top.equalTo(btnPreConversationPresentMode.snp.bottom).offset(Metrics.buttonVerticalMargin)
            make.leading.equalTo(scrollView).offset(Metrics.horizontalMargin)
        }

        scrollView.addSubview(btnFullConversationPresentMode)
        btnFullConversationPresentMode.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(Metrics.buttonHeight)
            make.top.equalTo(btnFullConversationPushMode.snp.bottom).offset(Metrics.buttonVerticalMargin)
            make.leading.equalTo(scrollView).offset(Metrics.horizontalMargin)
        }

        // Adding comment creation buttons
        scrollView.addSubview(btnCommentCreationPushMode)
        btnCommentCreationPushMode.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(Metrics.buttonHeight)
            make.top.equalTo(btnFullConversationPresentMode.snp.bottom).offset(Metrics.buttonVerticalMargin)
            make.leading.equalTo(scrollView).offset(Metrics.horizontalMargin)
        }

        scrollView.addSubview(btnCommentCreationPresentMode)
        btnCommentCreationPresentMode.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(Metrics.buttonHeight)
            make.top.equalTo(btnCommentCreationPushMode.snp.bottom).offset(Metrics.buttonVerticalMargin)
            make.leading.equalTo(scrollView).offset(Metrics.horizontalMargin)
        }

        // Adding comment thread buttons
        scrollView.addSubview(btnCommentThreadPushMode)
        btnCommentThreadPushMode.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(Metrics.buttonHeight)
            make.top.equalTo(btnCommentCreationPresentMode.snp.bottom).offset(Metrics.buttonVerticalMargin)
            make.leading.equalTo(scrollView).offset(Metrics.horizontalMargin)
        }

        scrollView.addSubview(btnCommentThreadPresentMode)
        btnCommentThreadPresentMode.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(Metrics.buttonHeight)
            make.top.equalTo(btnCommentThreadPushMode.snp.bottom).offset(Metrics.buttonVerticalMargin)
            make.leading.equalTo(scrollView).offset(Metrics.horizontalMargin)
        }

        #if ADS
        // Adding monetization button
        scrollView.addSubview(btnMonetization)
        btnMonetization.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(Metrics.buttonHeight)
            make.top.equalTo(btnCommentThreadPresentMode.snp.bottom).offset(Metrics.buttonVerticalMargin)
            make.leading.equalTo(scrollView).offset(Metrics.horizontalMargin)
            make.bottom.equalTo(scrollView.contentLayoutGuide).offset(-Metrics.verticalMargin)
        }
        #endif
    }

    func setupObservers() {
        title = viewModel.outputs.title

        // Bind buttons
        btnPreConversationPushMode.tapPublisher
            .map { PresentationalModeCompact.push }
            .bind(to: viewModel.inputs.preConversationTapped)
            .store(in: &cancellables)

        btnPreConversationPresentMode.tapPublisher
            .map { [weak self] in
                guard let self else { return .push }
                let style = self.viewModel.outputs.presentStyle
                return PresentationalModeCompact.present(style: style)
            }
            .bind(to: viewModel.inputs.preConversationTapped)
            .store(in: &cancellables)

        btnFullConversationPushMode.tapPublisher
            .map { PresentationalModeCompact.push }
            .bind(to: viewModel.inputs.fullConversationTapped)
            .store(in: &cancellables)

        btnFullConversationPresentMode.tapPublisher
            .map { [weak self] in
                guard let self else { return .push }
                let style = self.viewModel.outputs.presentStyle
                return PresentationalModeCompact.present(style: style)
            }
            .bind(to: viewModel.inputs.fullConversationTapped)
            .store(in: &cancellables)

        btnCommentCreationPushMode.tapPublisher
            .map { PresentationalModeCompact.push }
            .bind(to: viewModel.inputs.commentCreationTapped)
            .store(in: &cancellables)

        btnCommentCreationPresentMode.tapPublisher
            .map { [weak self] in
                guard let self else { return .push }
                return PresentationalModeCompact.present(style: self.viewModel.outputs.presentStyle)
            }
            .bind(to: viewModel.inputs.commentCreationTapped)
            .store(in: &cancellables)

        btnCommentThreadPushMode.tapPublisher
            .map { PresentationalModeCompact.push }
            .bind(to: viewModel.inputs.commentThreadTapped)
            .store(in: &cancellables)

        btnCommentThreadPresentMode.tapPublisher
            .map { [weak self] in
                guard let self else { return .push }
                return PresentationalModeCompact.present(style: self.viewModel.outputs.presentStyle)
            }
            .bind(to: viewModel.inputs.commentThreadTapped)
            .store(in: &cancellables)

        btnMonetization.tapPublisher
            .bind(to: viewModel.inputs.monetizationTapped)
            .store(in: &cancellables)
    }
}
