//
//  UIViewsVC.swift
//  OpenWeb-Development
//
//  Created by Revital Pisman on 07/12/2022.
//  Copyright © 2022 OpenWeb. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class UIViewsVC: UIViewController {

    private struct Metrics {
        static let identifier = "uiviews_vc_id"
        static let btnPreConversationIdentifier = "btn_pre_conversation_id"
        static let btnFullConversationIdentifier = "btn_full_conversation_id"
        static let btnCommentCreationIdentifier = "btn_comment_creation_id"
        static let btnCommentThreadIdentifier = "btn_comment_thread_id"
        static let btnClarityDetailsIdentifier = "btn_clarity_details_id"
        static let btnMonetizationIdentifier = "btn_monetization_id"
        static let btnExamplesIdentifier = "btn_examples_id"
        static let verticalMargin: CGFloat = 40
        static let horizontalMargin: CGFloat = 50
        static let buttonVerticalMargin: CGFloat = 20
        static let buttonHeight: CGFloat = 50
    }

    private let viewModel: UIViewsViewModeling
    private let disposeBag = DisposeBag()

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

    private lazy var btnClarityDetails: UIButton = {
        return NSLocalizedString("ClarityDetails", comment: "").blueRoundedButton
    }()

    private lazy var btnMonetization: UIButton = {
        return NSLocalizedString("Monetization", comment: "").blueRoundedButton
    }()

    private lazy var btnExamples: UIButton = {
        return NSLocalizedString("Examples", comment: "").blueRoundedButton
    }()

    init(viewModel: UIViewsViewModeling) {
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

private extension UIViewsVC {
    func applyAccessibility() {
        view.accessibilityIdentifier = Metrics.identifier
        btnPreConversation.accessibilityIdentifier = Metrics.btnPreConversationIdentifier
        btnFullConversation.accessibilityIdentifier = Metrics.btnFullConversationIdentifier
        btnCommentCreation.accessibilityIdentifier = Metrics.btnCommentCreationIdentifier
        btnCommentThread.accessibilityIdentifier = Metrics.btnCommentThreadIdentifier
        btnClarityDetails.accessibilityIdentifier = Metrics.btnClarityDetailsIdentifier
        btnMonetization.accessibilityIdentifier = Metrics.btnMonetizationIdentifier
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

        // Adding clarity details button
        scrollView.addSubview(btnClarityDetails)
        btnClarityDetails.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(Metrics.buttonHeight)
            make.top.equalTo(btnCommentThread.snp.bottom).offset(Metrics.buttonVerticalMargin)
            make.leading.equalTo(scrollView).offset(Metrics.horizontalMargin)
        }

        #if ADS
        // Adding monetization button
        scrollView.addSubview(btnMonetization)
        btnMonetization.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(Metrics.buttonHeight)
            make.top.equalTo(btnClarityDetails.snp.bottom).offset(Metrics.buttonVerticalMargin)
            make.leading.equalTo(scrollView).offset(Metrics.horizontalMargin)
        }
        #endif

        // Adding examples button
        scrollView.addSubview(btnExamples)
        btnExamples.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(Metrics.buttonHeight)
            #if ADS
            make.top.equalTo(btnMonetization.snp.bottom).offset(Metrics.buttonVerticalMargin)
            #else
            make.top.equalTo(btnClarityDetails.snp.bottom).offset(Metrics.buttonVerticalMargin)
            #endif
            make.leading.equalTo(scrollView).offset(Metrics.horizontalMargin)
            make.bottom.equalTo(scrollView.contentLayoutGuide).offset(-Metrics.verticalMargin)
        }
    }

    func setupObservers() {
        title = viewModel.outputs.title

        // Bind buttons
        btnPreConversation.rx.tap
            .bind(to: viewModel.inputs.preConversationTapped)
            .disposed(by: disposeBag)

        btnFullConversation.rx.tap
            .bind(to: viewModel.inputs.fullConversationTapped)
            .disposed(by: disposeBag)

        btnCommentCreation.rx.tap
            .bind(to: viewModel.inputs.commentCreationTapped)
            .disposed(by: disposeBag)

        btnCommentThread.rx.tap
            .bind(to: viewModel.inputs.commentThreadTapped)
            .disposed(by: disposeBag)

        btnClarityDetails.rx.tap
            .bind(to: viewModel.inputs.clarityDetailsTapped)
            .disposed(by: disposeBag)

        btnMonetization.rx.tap
            .bind(to: viewModel.inputs.monetizationTapped)
            .disposed(by: disposeBag)

        btnExamples.rx.tap
            .bind(to: viewModel.inputs.examplesTapped)
            .disposed(by: disposeBag)
    }
}
