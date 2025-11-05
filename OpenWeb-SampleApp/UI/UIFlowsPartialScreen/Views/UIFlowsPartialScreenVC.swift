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
        static let btnPreConversationToConversationIdentifier = "btn_pre_conversation_to_conversation_id"
        static let btnFullConversationIdentifier = "btn_full_conversation_id"
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

    private lazy var btnPreConversationToConversation: UIButton = {
        return NSLocalizedString("PreConversationToFullConversation", comment: "").blueRoundedButton
    }()

    private lazy var btnFullConversation: UIButton = {
        return NSLocalizedString("FullConversation", comment: "").blueRoundedButton
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
        btnPreConversationToConversation.accessibilityIdentifier = Metrics.btnPreConversationToConversationIdentifier
        btnFullConversation.accessibilityIdentifier = Metrics.btnFullConversationIdentifier
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

        let buttons = [
            btnPreConversationToConversation,
            btnFullConversation,
            btnExamples
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
        btnPreConversationToConversation.tapPublisher
            .bind(to: viewModel.inputs.preConversationToFullConversationTapped)
            .store(in: &cancellables)

        btnFullConversation.tapPublisher
            .bind(to: viewModel.inputs.fullConversationTapped)
            .store(in: &cancellables)

        btnExamples.tapPublisher
            .bind(to: viewModel.inputs.examplesTapped)
            .store(in: &cancellables)
    }
}
