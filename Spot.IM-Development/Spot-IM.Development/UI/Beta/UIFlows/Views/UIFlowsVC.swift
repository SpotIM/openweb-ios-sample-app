//
//  UIFlowsVC.swift
//  Spot-IM.Development
//
//  Created by Revital Pisman on 04/12/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

#if NEW_API

class UIFlowsVC: UIViewController {

    fileprivate struct Metrics {
        static let identifier = "uiviews_vc_id"
        static let btnPreConversationPushModeIdentifier = "btn_pre_conversation_push_mode_id"
        static let btnPreConversationPresentModeIdentifier = "btn_pre_conversation_present_mode_id"
        static let btnFullConversationPushModeIdentifier = "btn_full_conversation_push_mode_id"
        static let btnFullConversationPresentModeIdentifier = "btn_full_conversation_present_mode_id"
        static let btnCommentCreationPushModeIdentifier = "btn_comment_creation_push_mode_id"
        static let btnCommentCreationPresentModeIdentifier = "btn_comment_creation_present_mode_id"
        static let verticalMargin: CGFloat = 40
        static let horizontalMargin: CGFloat = 50
        static let buttonVerticalMargin: CGFloat = 20
        static let buttonHeight: CGFloat = 50
    }

    fileprivate let viewModel: UIFlowsViewModeling
    fileprivate let disposeBag = DisposeBag()
    
    fileprivate lazy var scrollView: UIScrollView = {
        var scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()

    fileprivate lazy var btnPreConversationPushMode: UIButton = {
        return NSLocalizedString("PreConversationPushMode", comment: "").blueRoundedButton
    }()

    fileprivate lazy var btnPreConversationPresentMode: UIButton = {
        return NSLocalizedString("PreConversationPresentMode", comment: "").blueRoundedButton
    }()

    fileprivate lazy var btnFullConversationPushMode: UIButton = {
        return NSLocalizedString("FullConversationPushMode", comment: "").blueRoundedButton
    }()

    fileprivate lazy var btnFullConversationPresentMode: UIButton = {
        return NSLocalizedString("FullConversationPresentMode", comment: "").blueRoundedButton
    }()

    fileprivate lazy var btnCommentCreationPushMode: UIButton = {
        return NSLocalizedString("CommentCreationPushMode", comment: "").blueRoundedButton
    }()

    fileprivate lazy var btnCommentCreationPresentMode: UIButton = {
        return NSLocalizedString("CommentCreationPresentMode", comment: "").blueRoundedButton
    }()

    init(viewModel: UIFlowsViewModeling) {
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

fileprivate extension UIFlowsVC {
    func applyAccessibility() {
        view.accessibilityIdentifier = Metrics.identifier
        btnPreConversationPushMode.accessibilityIdentifier = Metrics.btnPreConversationPushModeIdentifier
        btnPreConversationPresentMode.accessibilityIdentifier = Metrics.btnPreConversationPresentModeIdentifier
        btnFullConversationPushMode.accessibilityIdentifier = Metrics.btnFullConversationPushModeIdentifier
        btnFullConversationPresentMode.accessibilityIdentifier = Metrics.btnFullConversationPresentModeIdentifier
        btnCommentCreationPushMode.accessibilityIdentifier = Metrics.btnCommentCreationPushModeIdentifier
        btnCommentCreationPresentMode.accessibilityIdentifier = Metrics.btnCommentCreationPresentModeIdentifier
    }
    
    func setupViews() {
        view.backgroundColor = ColorPalette.shared.color(type: .background)
        
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
            make.bottom.equalTo(scrollView.contentLayoutGuide).offset(-Metrics.verticalMargin)
        }
    }

    func setupObservers() {
        title = viewModel.outputs.title

        // Bind buttons
        btnPreConversationPushMode.rx.tap
            .map { PresentationalModeCompact.push }
            .bind(to: viewModel.inputs.preConversationTapped)
            .disposed(by: disposeBag)

        btnPreConversationPresentMode.rx.tap
            .map { PresentationalModeCompact.present }
            .bind(to: viewModel.inputs.preConversationTapped)
            .disposed(by: disposeBag)

        btnFullConversationPushMode.rx.tap
            .map { PresentationalModeCompact.push }
            .bind(to: viewModel.inputs.fullConversationTapped)
            .disposed(by: disposeBag)

        btnFullConversationPresentMode.rx.tap
            .map { PresentationalModeCompact.present }
            .bind(to: viewModel.inputs.fullConversationTapped)
            .disposed(by: disposeBag)

        btnCommentCreationPushMode.rx.tap
            .map { PresentationalModeCompact.push }
            .bind(to: viewModel.inputs.commentCreationTapped)
            .disposed(by: disposeBag)

        btnCommentCreationPresentMode.rx.tap
            .map { PresentationalModeCompact.present }
            .bind(to: viewModel.inputs.commentCreationTapped)
            .disposed(by: disposeBag)

        viewModel.outputs.openMockArticleScreen
            .subscribe(onNext: { [weak self] settings in
                let mockArticleVM = MockArticleViewModel(actionSettings: settings)
                let mockArticleVC = MockArticleVC(viewModel: mockArticleVM)
                self?.navigationController?.pushViewController(mockArticleVC, animated: true)
            })
            .disposed(by: disposeBag)
    }
}

#endif

