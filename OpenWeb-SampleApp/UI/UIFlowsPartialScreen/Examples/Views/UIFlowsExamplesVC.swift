//
//  UIFlowsExamplesVC.swift
//  OpenWeb-SampleApp
//
//  Created by Alon Shprung on 28/09/2025.
//

import UIKit
import Combine
import CombineCocoa
import SnapKit

class UIFlowsExamplesVC: UIViewController {

    private struct Metrics {
        static let identifier = "uiflows_examples_vc_id"
        static let btnConversationBelowVideoIdentifier = "btn_conversation_below_video_id"
        static let verticalMargin: CGFloat = 40
        static let horizontalMargin: CGFloat = 50
        static let buttonHeight: CGFloat = 50
    }

    private let viewModel: UIFlowsExamplesViewModeling
    private var cancellables = Set<AnyCancellable>()

    private lazy var scrollView: UIScrollView = {
        var scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()

    private lazy var btnConversationBelowVideo: UIButton = {
        return NSLocalizedString("ConversationBelowVideo", comment: "")
            .blueRoundedButton
    }()

    init(viewModel: UIFlowsExamplesViewModeling) {
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

private extension UIFlowsExamplesVC {
    func applyAccessibility() {
        view.accessibilityIdentifier = Metrics.identifier
        btnConversationBelowVideo.accessibilityIdentifier = Metrics.btnConversationBelowVideoIdentifier
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

        // Adding conversation below video button
        scrollView.addSubview(btnConversationBelowVideo)
        btnConversationBelowVideo.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(Metrics.buttonHeight)
            make.top.equalTo(scrollView).offset(Metrics.verticalMargin)
            make.leading.equalTo(scrollView).offset(Metrics.horizontalMargin)
            make.bottom.equalTo(scrollView.contentLayoutGuide).offset(-Metrics.verticalMargin)
        }
    }

    func setupObservers() {
        title = viewModel.outputs.title

        // Bind buttons
        btnConversationBelowVideo.tapPublisher
            .bind(to: viewModel.inputs.conversationBelowVideoTapped)
            .store(in: &cancellables)
    }
}
