//
//  BetaNewAPIVC.swift
//  Spot-IM.Development
//
//  Created by Alon Haiut on 31/08/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

#if NEW_API

class BetaNewAPIVC: UIViewController {
    fileprivate struct Metrics {
        static let verticalMargin: CGFloat = 20
        static let horizontalMargin: CGFloat = 20
        static let textFieldHeight: CGFloat = 40
        static let textFieldCorners: CGFloat = 12
        static let buttonCorners: CGFloat = 16
        static let buttonPadding: CGFloat = 10
        static let buttonHeight: CGFloat = 50
    }
    
    fileprivate let viewModel: BetaNewAPIViewModeling
    fileprivate let disposeBag = DisposeBag()
    
    fileprivate lazy var lblSpotId: UILabel = {
        let txt = NSLocalizedString("SpotId", comment: "") + ":"

        return txt
            .label
            .hugContent(axis: .horizontal)
            .font(FontBook.mainHeading)
            .textColor(ColorPalette.blackish)
    }()
    
    fileprivate lazy var lblPostId: UILabel = {
        let txt = NSLocalizedString("PostId", comment: "") + ":"

        return txt
            .label
            .hugContent(axis: .horizontal)
            .font(FontBook.mainHeading)
            .textColor(ColorPalette.blackish)
    }()
    
    fileprivate lazy var txtFieldSpotId: UITextField = {
        let txtField = UITextField()
            .corner(radius: Metrics.textFieldCorners)
            .border(width: 1.0, color: ColorPalette.blackish)
        
        txtField.borderStyle = .roundedRect
        txtField.autocapitalizationType = .none
        return txtField
    }()
    
    fileprivate lazy var txtFieldPostId: UITextField = {
        let txtField = UITextField()
            .corner(radius: Metrics.textFieldCorners)
            .border(width: 1.0, color: ColorPalette.blackish)
        
        txtField.borderStyle = .roundedRect
        txtField.autocapitalizationType = .none
        return txtField
    }()
    
    fileprivate lazy var optionsScrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.backgroundColor = ColorPalette.lightGrey
        return scroll
    }()
    
    fileprivate lazy var btnPreConversationPushMode: UIButton = {
        let txt = NSLocalizedString("PreConversationPushMode", comment: "")

        return txt
            .button
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
            .backgroundColor(ColorPalette.blue)
            .textColor(ColorPalette.extraLightGrey)
            .corner(radius: Metrics.buttonCorners)
            .withHorizontalPadding(Metrics.buttonPadding)
            .font(FontBook.paragraphBold)
    }()
    
    fileprivate lazy var btnConversationCounter: UIButton = {
        let txt = NSLocalizedString("ConversationCounter", comment: "")

        return txt
            .button
            .backgroundColor(ColorPalette.blue)
            .textColor(ColorPalette.extraLightGrey)
            .corner(radius: Metrics.buttonCorners)
            .withHorizontalPadding(Metrics.buttonPadding)
            .font(FontBook.paragraphBold)
    }()
    
    init(viewModel: BetaNewAPIViewModeling = BetaNewAPIViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
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

fileprivate extension BetaNewAPIVC {
    func setupViews() {
        view.backgroundColor = ColorPalette.lightGrey
        
        view.addSubview(lblSpotId)
        lblSpotId.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(Metrics.verticalMargin)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(Metrics.horizontalMargin)
        }
        
        view.addSubview(txtFieldSpotId)
        txtFieldSpotId.snp.makeConstraints { make in
            make.centerY.equalTo(lblSpotId)
            make.leading.equalTo(lblSpotId.snp.trailing).offset(Metrics.horizontalMargin)
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-Metrics.horizontalMargin)
            make.height.equalTo(Metrics.textFieldHeight)
        }
        
        view.addSubview(lblPostId)
        lblPostId.snp.makeConstraints { make in
            make.top.equalTo(lblSpotId.snp.bottom).offset(Metrics.verticalMargin)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(Metrics.horizontalMargin)
        }
        
        view.addSubview(txtFieldPostId)
        txtFieldPostId.snp.makeConstraints { make in
            make.centerY.equalTo(lblPostId)
            make.leading.equalTo(lblPostId.snp.trailing).offset(Metrics.horizontalMargin)
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-Metrics.horizontalMargin)
            make.height.equalTo(Metrics.textFieldHeight)
        }
        
        view.addSubview(optionsScrollView)
        optionsScrollView.snp.makeConstraints { make in
            make.top.equalTo(txtFieldPostId.snp.bottom).offset(Metrics.verticalMargin)
            make.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        optionsScrollView.contentLayoutGuide.snp.makeConstraints { make in
            make.width.equalTo(optionsScrollView.snp.width)
        }
        
        optionsScrollView.addSubview(btnPreConversationPushMode)
        btnPreConversationPushMode.snp.makeConstraints { make in
            make.centerX.equalTo(optionsScrollView.contentLayoutGuide)
            make.height.equalTo(Metrics.buttonHeight)
            make.top.equalTo(optionsScrollView.contentLayoutGuide).offset(Metrics.verticalMargin)
        }
        
        optionsScrollView.addSubview(btnFullConversationPresentMode)
        btnFullConversationPresentMode.snp.makeConstraints { make in
            make.centerX.equalTo(optionsScrollView.contentLayoutGuide)
            make.height.equalTo(Metrics.buttonHeight)
            make.top.equalTo(btnPreConversationPushMode.snp.bottom).offset(Metrics.verticalMargin)
        }
        
        optionsScrollView.addSubview(btnFullConversationPushMode)
        btnFullConversationPushMode.snp.makeConstraints { make in
            make.centerX.equalTo(optionsScrollView.contentLayoutGuide)
            make.height.equalTo(Metrics.buttonHeight)
            make.top.equalTo(btnFullConversationPresentMode.snp.bottom).offset(Metrics.verticalMargin)
        }
        
        optionsScrollView.addSubview(btnFullConversationPresentMode)
        btnFullConversationPresentMode.snp.makeConstraints { make in
            make.centerX.equalTo(optionsScrollView.contentLayoutGuide)
            make.height.equalTo(Metrics.buttonHeight)
            make.top.equalTo(btnFullConversationPushMode.snp.bottom).offset(Metrics.verticalMargin)
        }
        
        optionsScrollView.addSubview(btnCommentCreationPushMode)
        btnCommentCreationPushMode.snp.makeConstraints { make in
            make.centerX.equalTo(optionsScrollView.contentLayoutGuide)
            make.height.equalTo(Metrics.buttonHeight)
            make.top.equalTo(btnFullConversationPresentMode.snp.bottom).offset(Metrics.verticalMargin)
        }
        
        optionsScrollView.addSubview(btnCommentCreationPresentMode)
        btnCommentCreationPresentMode.snp.makeConstraints { make in
            make.centerX.equalTo(optionsScrollView.contentLayoutGuide)
            make.height.equalTo(Metrics.buttonHeight)
            make.top.equalTo(btnCommentCreationPushMode.snp.bottom).offset(Metrics.verticalMargin)
        }
        
        optionsScrollView.addSubview(btnConversationCounter)
        btnConversationCounter.snp.makeConstraints { make in
            make.centerX.equalTo(optionsScrollView.contentLayoutGuide)
            make.height.equalTo(Metrics.buttonHeight)
            make.top.equalTo(btnCommentCreationPresentMode.snp.bottom).offset(Metrics.verticalMargin)
            make.bottom.lessThanOrEqualTo(optionsScrollView.contentLayoutGuide).offset(-Metrics.verticalMargin)
        }
    }

    func setupObservers() {
        title = viewModel.outputs.title
        
        // Pre filled
        viewModel.outputs.preFilledSpotId
            .take(1)
            .bind(to: txtFieldSpotId.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.outputs.preFilledPostId
            .take(1)
            .bind(to: txtFieldPostId.rx.text)
            .disposed(by: disposeBag)
        
        // Dismiss keyboard
        txtFieldSpotId.rx.controlEvent([.editingDidEnd, .editingDidEndOnExit])
            .subscribe(onNext: { [weak self] _ in
                self?.txtFieldSpotId.endEditing(true)
            })
            .disposed(by: disposeBag)
        
        txtFieldPostId.rx.controlEvent([.editingDidEnd, .editingDidEndOnExit])
            .subscribe(onNext: { [weak self] _ in
                self?.txtFieldPostId.endEditing(true)
            })
            .disposed(by: disposeBag)
        
        // Bind text fields
        txtFieldSpotId.rx.text
            .unwrap()
            .bind(to: viewModel.inputs.enteredSpotId)
            .disposed(by: disposeBag)
        
        txtFieldPostId.rx.text
            .unwrap()
            .bind(to: viewModel.inputs.enteredPostId)
            .disposed(by: disposeBag)
        
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
        
        btnConversationCounter.rx.tap
            .bind(to: viewModel.inputs.conversationCounterTapped)
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
