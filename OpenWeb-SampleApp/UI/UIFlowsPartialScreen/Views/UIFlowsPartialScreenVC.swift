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
        static let btnPreConversationToConversationPushModeIdentifier = "btn_pre_conversation_to_conversation_push_mode_id"
        static let btnPreConversationToConversationPresentModeIdentifier = "btn_pre_conversation_to_conversation_present_mode_id"
        static let btnPreConversationToConversationCoverModeIdentifier = "btn_pre_conversation_to_conversation_cover_mode_id"
        static let btnFullConversationIdentifier = "btn_full_conversation_id"
        static let btnCommentCreationIdentifier = "btn_comment_creation_id"
        static let btnCommentThreadIdentifier = "btn_comment_thread_id"
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

    private lazy var btnPreConversationToConversationPushMode: UIButton = {
        return NSLocalizedString("PreConversationToFullConversationPushMode", comment: "").blueRoundedButton
    }()

    private lazy var btnPreConversationToConversationPresentMode: UIButton = {
        return NSLocalizedString("PreConversationToFullConversationPresentMode", comment: "").blueRoundedButton
    }()

    private lazy var btnPreConversationToConversationCoverMode: UIButton = {
        return NSLocalizedString("PreConversationToFullConversationCoverMode", comment: "").blueRoundedButton
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
        btnPreConversationToConversationPushMode.accessibilityIdentifier = Metrics.btnPreConversationToConversationPushModeIdentifier
        btnPreConversationToConversationPresentMode.accessibilityIdentifier = Metrics.btnPreConversationToConversationPresentModeIdentifier
        btnPreConversationToConversationCoverMode.accessibilityIdentifier = Metrics.btnPreConversationToConversationCoverModeIdentifier
        btnFullConversation.accessibilityIdentifier = Metrics.btnFullConversationIdentifier
        btnCommentCreation.accessibilityIdentifier = Metrics.btnCommentCreationIdentifier
        btnCommentThread.accessibilityIdentifier = Metrics.btnCommentThreadIdentifier
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

        let buttons = [
            btnPreConversationToConversationPushMode,
            btnPreConversationToConversationPresentMode,
            btnPreConversationToConversationCoverMode,
            btnFullConversation,
            btnCommentCreation,
            btnCommentThread
        ]
        let buttonsStackView = UIStackView(arrangedSubviews: buttons)
        buttonsStackView.axis = .vertical
        buttonsStackView.spacing = Metrics.buttonVerticalMargin
        buttonsStackView.alignment = .fill

        scrollView.addSubview(buttonsStackView)
        buttonsStackView.snp.makeConstraints { make in
            make.top.equalTo(scrollView.contentLayoutGuide).offset(Metrics.verticalMargin)
            make.bottom.equalTo(scrollView.contentLayoutGuide).offset(-Metrics.verticalMargin)
            make.leading.trailing.equalTo(scrollView.frameLayoutGuide).inset(Metrics.horizontalMargin)
        }

        buttons.forEach { button in
            button.snp.makeConstraints { make in
                make.height.equalTo(Metrics.buttonHeight)
            }
        }
    }

    func setupObservers() {
        title = viewModel.outputs.title

        // Bind buttons
        btnPreConversationToConversationPushMode.tapPublisher
            .bind(to: viewModel.inputs.preConversationToFullConversationPushModeTapped)
                .store(in: &cancellables)

        btnPreConversationToConversationPresentMode.tapPublisher
            .bind(to: viewModel.inputs.preConversationToFullConversationPresentModeTapped)
                .store(in: &cancellables)

        btnPreConversationToConversationCoverMode.tapPublisher
            .bind(to: viewModel.inputs.preConversationToFullConversationCoverModeTapped)
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
    }
}
