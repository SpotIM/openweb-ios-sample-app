//
//  UIFlowsPartialScreenVC.swift
//  OpenWeb-SampleApp
//
//  Created by Alon Shprung on 22/10/2025.
//

import UIKit
import Combine
import CombineCocoa
import SnapKit
import OpenWebSDK

class UIFlowsPartialScreenVC: UIViewController {

    private struct Metrics {
        static let identifier = "uiflows_partial_screen_vc_id"
        static let btnPreConversationIdentifier = "btn_pre_conversation_id"
        static let btnFullConversationIdentifier = "btn_full_conversation_id"
        static let btnCommentCreationIdentifier = "btn_comment_creation_id"
        static let btnCommentThreadIdentifier = "btn_comment_thread_id"
        static let btnExamplesIdentifier = "btn_examples_id"
        static let verticalMargin: CGFloat = 40
        static let horizontalMargin: CGFloat = 50
        static let buttonVerticalMargin: CGFloat = 20
        static let buttonHeight: CGFloat = 50
    }

    private let viewModel: UIFlowsPartialScreenViewModeling
    private var cancellables = Set<AnyCancellable>()

    private lazy var scrollView: UIScrollView = {
        var scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()

    private lazy var btnPreConversation: UIButton = {
        return NSLocalizedString("PreConversation", comment: "").blueRoundedButton
    }()

    private lazy var btnFullConversation: UIButton = {
        return NSLocalizedString("FullConversation", comment: "").blueRoundedButton
    }()

    private lazy var btnCommentCreation: UIButton = {
        return NSLocalizedString("CommentCreation", comment: "").blueRoundedButton
    }()

    private lazy var btnCommentThread: UIButton = {
        return NSLocalizedString("CommentThread", comment: "").blueRoundedButton
    }()

    private lazy var btnExamples: UIButton = {
        return NSLocalizedString("Examples", comment: "").blueRoundedButton
    }()

    init(viewModel: UIFlowsPartialScreenViewModeling) {
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

private extension UIFlowsPartialScreenVC {
    func applyAccessibility() {
        view.accessibilityIdentifier = Metrics.identifier
        btnPreConversation.accessibilityIdentifier = Metrics.btnPreConversationIdentifier
        btnFullConversation.accessibilityIdentifier = Metrics.btnFullConversationIdentifier
        btnCommentCreation.accessibilityIdentifier = Metrics.btnCommentCreationIdentifier
        btnCommentThread.accessibilityIdentifier = Metrics.btnCommentThreadIdentifier
        btnExamples.accessibilityIdentifier = Metrics.btnExamplesIdentifier
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

        // Adding pre conversation button
        scrollView.addSubview(btnPreConversation)
        btnPreConversation.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(Metrics.buttonHeight)
            make.top.equalTo(scrollView).offset(Metrics.verticalMargin)
            make.leading.equalTo(scrollView).offset(Metrics.horizontalMargin)
            make.top.equalTo(scrollView.contentLayoutGuide).offset(Metrics.verticalMargin)
        }

        // Adding full conversation button
        scrollView.addSubview(btnFullConversation)
        btnFullConversation.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(Metrics.buttonHeight)
            make.top.equalTo(btnPreConversation.snp.bottom).offset(Metrics.buttonVerticalMargin)
            make.leading.equalTo(scrollView).offset(Metrics.horizontalMargin)
        }

        // Adding comment creation button
        scrollView.addSubview(btnCommentCreation)
        btnCommentCreation.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(Metrics.buttonHeight)
            make.top.equalTo(btnFullConversation.snp.bottom).offset(Metrics.buttonVerticalMargin)
            make.leading.equalTo(scrollView).offset(Metrics.horizontalMargin)
        }

        // Adding comment thread button
        scrollView.addSubview(btnCommentThread)
        btnCommentThread.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(Metrics.buttonHeight)
            make.top.equalTo(btnCommentCreation.snp.bottom).offset(Metrics.buttonVerticalMargin)
            make.leading.equalTo(scrollView).offset(Metrics.horizontalMargin)
        }

        // Adding examples button
        scrollView.addSubview(btnExamples)
        btnExamples.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(Metrics.buttonHeight)
            make.top.equalTo(btnCommentThread.snp.bottom).offset(Metrics.buttonVerticalMargin)
            make.leading.equalTo(scrollView).offset(Metrics.horizontalMargin)
            make.bottom.equalTo(scrollView.contentLayoutGuide).offset(-Metrics.verticalMargin)
        }
    }

    func setupObservers() {
        title = viewModel.outputs.title

        // Bind buttons
        btnPreConversation.tapPublisher
            .bind(to: viewModel.inputs.preConversationTapped)
            .store(in: &cancellables)

        btnFullConversation.tapPublisher
            .bind(to: viewModel.inputs.fullConversationTapped)
            .store(in: &cancellables)

        btnCommentCreation.tapPublisher
            .bind(to: viewModel.inputs.commentCreationTapped)
            .store(in: &cancellables)

        btnCommentThread.tapPublisher
            .bind(to: viewModel.inputs.commentThreadTapped)
            .store(in: &cancellables)

        btnExamples.tapPublisher
            .bind(to: viewModel.inputs.examplesTapped)
            .store(in: &cancellables)
    }
}
