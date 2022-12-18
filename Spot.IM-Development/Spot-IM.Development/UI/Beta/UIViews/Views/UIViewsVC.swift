//
//  UIViewsVC.swift
//  Spot-IM.Development
//
//  Created by Revital Pisman on 07/12/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

#if NEW_API

class UIViewsVC: UIViewController {
    
    fileprivate struct Metrics {
        static let verticalMargin: CGFloat = 40
        static let horizontalMargin: CGFloat = 50
        static let buttonVerticalMargin: CGFloat = 20
        static let buttonCorners: CGFloat = 16
        static let buttonPadding: CGFloat = 10
        static let buttonHeight: CGFloat = 50
    }
    
    fileprivate let viewModel: UIViewsViewModeling
    fileprivate let disposeBag = DisposeBag()
    
    fileprivate lazy var optionsScrollView: UIScrollView = {
        return UIScrollView()
    }()
    
    fileprivate lazy var btnPreConversation: UIButton = {
        let txt = NSLocalizedString("PreConversation", comment: "")

        return txt
            .button
            .backgroundColor(ColorPalette.blue)
            .textColor(ColorPalette.extraLightGrey)
            .corner(radius: Metrics.buttonCorners)
            .withHorizontalPadding(Metrics.buttonPadding)
            .font(FontBook.paragraphBold)
    }()

    fileprivate lazy var btnFullConversation: UIButton = {
        let txt = NSLocalizedString("FullConversation", comment: "")

        return txt
            .button
            .backgroundColor(ColorPalette.blue)
            .textColor(ColorPalette.extraLightGrey)
            .corner(radius: Metrics.buttonCorners)
            .withHorizontalPadding(Metrics.buttonPadding)
            .font(FontBook.paragraphBold)
    }()
    
    fileprivate lazy var btnCommentCreation: UIButton = {
        let txt = NSLocalizedString("CommentCreation", comment: "")

        return txt
            .button
            .backgroundColor(ColorPalette.blue)
            .textColor(ColorPalette.extraLightGrey)
            .corner(radius: Metrics.buttonCorners)
            .withHorizontalPadding(Metrics.buttonPadding)
            .font(FontBook.paragraphBold)
    }()
   
    fileprivate lazy var btnIndependentAdUnit: UIButton = {
        let txt = NSLocalizedString("IndependentAdUnit", comment: "")

        return txt
            .button
            .backgroundColor(ColorPalette.blue)
            .textColor(ColorPalette.extraLightGrey)
            .corner(radius: Metrics.buttonCorners)
            .withHorizontalPadding(Metrics.buttonPadding)
            .font(FontBook.paragraphBold)
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
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupObservers()
    }
}

fileprivate extension UIViewsVC {
    func setupViews() {
        view.backgroundColor = .white
        
        // Adding scroll view
        view.addSubview(optionsScrollView)
        optionsScrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        // Adding pre conversation button
        optionsScrollView.addSubview(btnPreConversation)
        btnPreConversation.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(Metrics.buttonHeight)
            make.top.equalTo(optionsScrollView.contentLayoutGuide).offset(Metrics.verticalMargin)
            make.leading.equalTo(optionsScrollView.contentLayoutGuide).offset(Metrics.horizontalMargin)
        }
        
        // Adding full conversation button
        optionsScrollView.addSubview(btnFullConversation)
        btnFullConversation.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(Metrics.buttonHeight)
            make.top.equalTo(btnPreConversation.snp.bottom).offset(Metrics.buttonVerticalMargin)
            make.leading.equalTo(optionsScrollView.contentLayoutGuide).offset(Metrics.horizontalMargin)
        }
        
        // Adding comment creation button
        optionsScrollView.addSubview(btnCommentCreation)
        btnCommentCreation.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(Metrics.buttonHeight)
            make.top.equalTo(btnFullConversation.snp.bottom).offset(Metrics.buttonVerticalMargin)
            make.leading.equalTo(optionsScrollView.contentLayoutGuide).offset(Metrics.horizontalMargin)
        }
        
        // Adding independent ad unit button
        optionsScrollView.addSubview(btnIndependentAdUnit)
        btnIndependentAdUnit.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(Metrics.buttonHeight)
            make.top.equalTo(btnCommentCreation.snp.bottom).offset(Metrics.buttonVerticalMargin)
            make.leading.equalTo(optionsScrollView.contentLayoutGuide).offset(Metrics.horizontalMargin)
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
        
        btnIndependentAdUnit.rx.tap
            .bind(to: viewModel.inputs.independentAdUnitTapped)
            .disposed(by: disposeBag)
    }
}

#endif


