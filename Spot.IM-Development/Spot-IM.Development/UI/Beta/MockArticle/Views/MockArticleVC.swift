//
//  MockArticleVC.swift
//  Spot-IM.Development
//
//  Created by Alon Haiut on 04/09/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

#if NEW_API

class MockArticleVC: UIViewController {
    fileprivate struct Metrics {
        static let verticalMargin: CGFloat = 20
        static let horizontalMargin: CGFloat = 20
        // 1.5 * screen height, defualt to 1200
        static let articleHeight: CGFloat = 1.5 * (UIApplication.shared.delegate?.window??.screen.bounds.height ?? 800)
        static let articleImageRatio: CGFloat = 2/3
        static let buttonCorners: CGFloat = 16
        static let buttonPadding: CGFloat = 10
        static let buttonHeight: CGFloat = 50
    }
    
    fileprivate let viewModel: MockArticleViewModeling
    fileprivate let disposeBag = DisposeBag()
    
    fileprivate lazy var articleScrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.backgroundColor = ColorPalette.lightGrey
        
        scroll.contentLayoutGuide.snp.makeConstraints { make in
            make.width.equalTo(scroll)
            make.height.equalTo(Metrics.articleHeight)
        }
        
        scroll.addSubview(imgViewArticle)
        imgViewArticle.snp.makeConstraints { make in
            make.top.equalTo(scroll.contentLayoutGuide).offset(Metrics.verticalMargin)
            make.centerX.equalTo(scroll.contentLayoutGuide)
            make.width.equalTo(imgViewArticle.snp.height)
            make.width.equalTo(scroll.contentLayoutGuide).multipliedBy(Metrics.articleImageRatio)
        }
        
        scroll.addSubview(lblArticleDescription)
        lblArticleDescription.snp.makeConstraints { make in
            make.top.equalTo(imgViewArticle.snp.bottom).offset(Metrics.verticalMargin)
            make.leading.trailing.equalTo(scroll.contentLayoutGuide).inset(Metrics.horizontalMargin)
        }
        
        return scroll
    }()
    
    fileprivate lazy var imgViewArticle: UIImageView = {
        return UIImageView()
            .image(UIImage(named: "general_placeholder")!)
            .contentMode(.scaleAspectFit)
    }()
    
    fileprivate lazy var lblArticleDescription: UILabel = {
        let txt = NSLocalizedString("MockArticleDescription", comment: "")
        
        return txt
            .label
            .numberOfLines(0)
            .font(FontBook.secondaryHeadingMedium)
            .textColor(ColorPalette.blackish)
    }()
    
    fileprivate lazy var btnFullConversation: UIButton = {
        return UIButton()
            .backgroundColor(ColorPalette.blue)
            .textColor(ColorPalette.extraLightGrey)
            .corner(radius: Metrics.buttonCorners)
            .withHorizontalPadding(Metrics.buttonPadding)
            .font(FontBook.paragraphBold)
    }()
    
    fileprivate lazy var btnCommentCreation: UIButton = {
        return UIButton()
            .backgroundColor(ColorPalette.blue)
            .textColor(ColorPalette.extraLightGrey)
            .corner(radius: Metrics.buttonCorners)
            .withHorizontalPadding(Metrics.buttonPadding)
            .font(FontBook.paragraphBold)
    }()
    
    init(viewModel: MockArticleViewModeling) {
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

fileprivate extension MockArticleVC {
    func setupViews() {
        view.backgroundColor = ColorPalette.lightGrey
        
        view.addSubview(articleScrollView)
        articleScrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    func setupObservers() {
        title = viewModel.outputs.title
        
        // Binding buttons
        btnFullConversation.rx.tap
            .bind(to: viewModel.inputs.fullConversationButtonTapped)
            .disposed(by: disposeBag)
        
        btnCommentCreation.rx.tap
            .bind(to: viewModel.inputs.fullCommentCreationButtonTapped)
            .disposed(by: disposeBag)
        
        // Setup article image
        viewModel.outputs.articleImageURL
            .subscribe(onNext: { [weak self] url in
                self?.imgViewArticle.image(from: url)
            })
            .disposed(by: disposeBag)

        // Adding full conversation button if needed
        viewModel.outputs.showFullConversationButton
            .take(1)
            .subscribe(onNext: { [weak self] mode in
                guard let self = self else { return }
                let btnTitle: String
                switch mode {
                case .push:
                    btnTitle = NSLocalizedString("FullConversationPushMode", comment: "")
                case .present:
                    btnTitle = NSLocalizedString("FullConversationPresentMode", comment: "")
                }
                
                self.btnFullConversation.setTitle(btnTitle, for: .normal)
                
                self.articleScrollView.addSubview(self.btnFullConversation)
                self.btnFullConversation.snp.makeConstraints { make in
                    make.height.equalTo(Metrics.buttonHeight)
                    make.centerX.equalTo(self.articleScrollView.contentLayoutGuide)
                    make.bottom.equalTo(self.articleScrollView.contentLayoutGuide).offset(-Metrics.verticalMargin)
                }
            })
            .disposed(by: disposeBag)
        
        // Adding comment creation button if needed
        viewModel.outputs.showFullCommentCreationButton
            .take(1)
            .subscribe(onNext: { [weak self] mode in
                guard let self = self else { return }
                let btnTitle: String
                switch mode {
                case .push:
                    btnTitle = NSLocalizedString("CommentCreationPushMode", comment: "")
                case .present:
                    btnTitle = NSLocalizedString("CommentCreationPresentMode", comment: "")
                }
                
                self.btnCommentCreation.setTitle(btnTitle, for: .normal)
                
                self.articleScrollView.addSubview(self.btnCommentCreation)
                self.btnCommentCreation.snp.makeConstraints { make in
                    make.height.equalTo(Metrics.buttonHeight)
                    make.centerX.equalTo(self.articleScrollView.contentLayoutGuide)
                    make.bottom.equalTo(self.articleScrollView.contentLayoutGuide).offset(-Metrics.verticalMargin)
                }
            })
            .disposed(by: disposeBag)
    }
}

#endif
