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
        static let verticalMargin: CGFloat = 40
        static let horizontalMargin: CGFloat = 50
        static let buttonVerticalMargin: CGFloat = 20
        static let buttonCorners: CGFloat = 16
        static let buttonPadding: CGFloat = 10
        static let buttonHeight: CGFloat = 50
    }
    
    fileprivate let viewModel: UIFlowsViewModeling
    fileprivate let disposeBag = DisposeBag()
    
    fileprivate lazy var optionsScrollView: UIScrollView = {
        return UIScrollView()
    }()
    
    fileprivate lazy var btnPreConversationPushMode: UIButton = {
        let txt = NSLocalizedString("PreConversationPushMode", comment: "")

        return txt
            .button
            .adjustsFontSizeToFitWidth
            .backgroundColor(ColorPalette.blue)
            .textColor(ColorPalette.extraLightGrey)
            .corner(radius: Metrics.buttonCorners)
            .withHorizontalPadding(Metrics.buttonPadding)
            .font(FontBook.paragraphBold)
    }()
    
    fileprivate lazy var btnPreConversationPresentMode: UIButton = {
        let txt = NSLocalizedString("PreConversationPresentMode", comment: "")

        return txt
            .button
            .adjustsFontSizeToFitWidth
            .backgroundColor(ColorPalette.blue)
            .textColor(ColorPalette.extraLightGrey)
            .corner(radius: Metrics.buttonCorners)
            .withHorizontalPadding(Metrics.buttonPadding)
            .font(FontBook.paragraphBold)
    }()

    fileprivate lazy var btnFullConversationPushMode: UIButton = {
        let txt = NSLocalizedString("FullConversationPushMode", comment: "")

        return txt
            .button
            .adjustsFontSizeToFitWidth
            .backgroundColor(ColorPalette.blue)
            .textColor(ColorPalette.extraLightGrey)
            .corner(radius: Metrics.buttonCorners)
            .withHorizontalPadding(Metrics.buttonPadding)
            .font(FontBook.paragraphBold)
    }()
    
    fileprivate lazy var btnFullConversationPresentMode: UIButton = {
        let txt = NSLocalizedString("FullConversationPresentMode", comment: "")

        return txt
            .button
            .adjustsFontSizeToFitWidth
            .backgroundColor(ColorPalette.blue)
            .textColor(ColorPalette.extraLightGrey)
            .corner(radius: Metrics.buttonCorners)
            .withHorizontalPadding(Metrics.buttonPadding)
            .font(FontBook.paragraphBold)
    }()
    
    fileprivate lazy var btnCommentCreationPushMode: UIButton = {
        let txt = NSLocalizedString("CommentCreationPushMode", comment: "")

        return txt
            .button
            .adjustsFontSizeToFitWidth
            .backgroundColor(ColorPalette.blue)
            .textColor(ColorPalette.extraLightGrey)
            .corner(radius: Metrics.buttonCorners)
            .withHorizontalPadding(Metrics.buttonPadding)
            .font(FontBook.paragraphBold)
    }()
   
    fileprivate lazy var btnCommentCreationPresentMode: UIButton = {
        let txt = NSLocalizedString("CommentCreationPresentMode", comment: "")

        return txt
            .button
            .adjustsFontSizeToFitWidth
            .backgroundColor(ColorPalette.blue)
            .textColor(ColorPalette.extraLightGrey)
            .corner(radius: Metrics.buttonCorners)
            .withHorizontalPadding(Metrics.buttonPadding)
            .font(FontBook.paragraphBold)
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
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupObservers()
    }
}

fileprivate extension UIFlowsVC {
    func setupViews() {
        view.backgroundColor = .white
        
        // Adding scroll view
        view.addSubview(optionsScrollView)
        optionsScrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        // Adding pre conversation buttons
        optionsScrollView.addSubview(btnPreConversationPushMode)
        btnPreConversationPushMode.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(Metrics.buttonHeight)
            make.top.equalTo(optionsScrollView.contentLayoutGuide).offset(Metrics.verticalMargin)
            make.leading.equalTo(optionsScrollView.contentLayoutGuide).offset(Metrics.horizontalMargin)
        }
        
        optionsScrollView.addSubview(btnPreConversationPresentMode)
        btnPreConversationPresentMode.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(Metrics.buttonHeight)
            make.top.equalTo(btnPreConversationPushMode.snp.bottom).offset(Metrics.buttonVerticalMargin)
            make.leading.equalTo(optionsScrollView.contentLayoutGuide).offset(Metrics.horizontalMargin)
        }
        
        // Adding full conversation buttons
        optionsScrollView.addSubview(btnFullConversationPushMode)
        btnFullConversationPushMode.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(Metrics.buttonHeight)
            make.top.equalTo(btnPreConversationPresentMode.snp.bottom).offset(Metrics.buttonVerticalMargin)
            make.leading.equalTo(optionsScrollView.contentLayoutGuide).offset(Metrics.horizontalMargin)
        }
        
        optionsScrollView.addSubview(btnFullConversationPresentMode)
        btnFullConversationPresentMode.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(Metrics.buttonHeight)
            make.top.equalTo(btnFullConversationPushMode.snp.bottom).offset(Metrics.buttonVerticalMargin)
            make.leading.equalTo(optionsScrollView.contentLayoutGuide).offset(Metrics.horizontalMargin)
        }
        
        // Adding comment creation buttons
        optionsScrollView.addSubview(btnCommentCreationPushMode)
        btnCommentCreationPushMode.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(Metrics.buttonHeight)
            make.top.equalTo(btnFullConversationPresentMode.snp.bottom).offset(Metrics.buttonVerticalMargin)
            make.leading.equalTo(optionsScrollView.contentLayoutGuide).offset(Metrics.horizontalMargin)
        }
        
        optionsScrollView.addSubview(btnCommentCreationPresentMode)
        btnCommentCreationPresentMode.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(Metrics.buttonHeight)
            make.top.equalTo(btnCommentCreationPushMode.snp.bottom).offset(Metrics.buttonVerticalMargin)
            make.leading.equalTo(optionsScrollView.contentLayoutGuide).offset(Metrics.horizontalMargin)
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


