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
        static let verticalMargin: CGFloat = 40
        static let horizontalMargin: CGFloat = 20
        // 1.5 * screen height, defualt to 1200
        static let articleHeight: CGFloat = 1.2 * (UIApplication.shared.delegate?.window??.screen.bounds.height ?? 800)
        static let articleImageRatio: CGFloat = 2/3
        static let buttonCorners: CGFloat = 16
        static let buttonPadding: CGFloat = 10
        static let buttonHeight: CGFloat = 50
    }

    fileprivate let viewModel: MockArticleViewModeling
    fileprivate let disposeBag = DisposeBag()

    fileprivate lazy var articleScrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.backgroundColor = ColorPalette.shared.color(type: .lightGrey)

        scroll.contentLayoutGuide.snp.makeConstraints { make in
            make.width.equalTo(scroll)
        }

        scroll.addSubview(articleView)
        articleView.snp.makeConstraints { make in
            make.edges.equalTo(scroll.contentLayoutGuide)
        }

        return scroll
    }()

    fileprivate lazy var articleView: UIView = {
        let article = UIView()

        article.snp.makeConstraints { make in
            make.height.equalTo(Metrics.articleHeight)
        }

        article.addSubview(imgViewArticle)
        imgViewArticle.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Metrics.verticalMargin)
            make.centerX.equalToSuperview()
            make.width.equalTo(imgViewArticle.snp.height)
            make.width.equalToSuperview().multipliedBy(Metrics.articleImageRatio)
        }

        article.addSubview(lblArticleDescription)
        lblArticleDescription.snp.makeConstraints { make in
            make.top.equalTo(imgViewArticle.snp.bottom).offset(Metrics.verticalMargin)
            make.leading.trailing.equalToSuperview().inset(Metrics.horizontalMargin)
        }

        return article
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
            .textColor(ColorPalette.shared.color(type: .blackish))
    }()

    fileprivate lazy var btnFullConversation: UIButton = {
        return UIButton()
            .backgroundColor(ColorPalette.shared.color(type: .blue))
            .textColor(ColorPalette.shared.color(type: .extraLightGrey))
            .corner(radius: Metrics.buttonCorners)
            .withHorizontalPadding(Metrics.buttonPadding)
            .font(FontBook.paragraphBold)
    }()

    fileprivate lazy var btnCommentCreation: UIButton = {
        return UIButton()
            .backgroundColor(ColorPalette.shared.color(type: .blue))
            .textColor(ColorPalette.shared.color(type: .extraLightGrey))
            .corner(radius: Metrics.buttonCorners)
            .withHorizontalPadding(Metrics.buttonPadding)
            .font(FontBook.paragraphBold)
    }()

    fileprivate lazy var btnCommentThread: UIButton = {
        return UIButton()
            .backgroundColor(ColorPalette.shared.color(type: .blue))
            .textColor(ColorPalette.shared.color(type: .extraLightGrey))
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
        view.backgroundColor = ColorPalette.shared.color(type: .lightGrey)

        view.addSubview(articleScrollView)
        articleScrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }

    // swiftlint:disable function_body_length
    func setupObservers() {
        title = viewModel.outputs.title

        // Setting those in the VM for integration with the SDK
        viewModel.inputs.setNavigationController(self.navigationController)
        viewModel.inputs.setPresentationalVC(self)

        // Binding button
        btnFullConversation.rx.tap
            .bind(to: viewModel.inputs.fullConversationButtonTapped)
            .disposed(by: disposeBag)

        btnCommentCreation.rx.tap
            .bind(to: viewModel.inputs.commentCreationButtonTapped)
            .disposed(by: disposeBag)

        btnCommentThread.rx.tap
            .bind(to: viewModel.inputs.commentThreadButtonTapped)
            .disposed(by: disposeBag)

        // Setup article image
        viewModel.outputs.articleImageURL
            .subscribe(onNext: { [weak self] url in
                self?.imgViewArticle.image(from: url)
            })
            .disposed(by: disposeBag)

        // Adding full conversation button if needed
        let btnFullConversationObservable = viewModel.outputs.showFullConversationButton
            .take(1)
            .do(onNext: { [weak self] mode in
                guard let self = self else { return }
                let btnTitle: String
                switch mode {
                case .push:
                    btnTitle = NSLocalizedString("FullConversationPushMode", comment: "")
                case .present:
                    btnTitle = NSLocalizedString("FullConversationPresentMode", comment: "")
                }

                self.btnFullConversation.setTitle(btnTitle, for: .normal)
            })
            .map { [weak self] _ -> UIButton? in
                guard let self = self else { return nil }
                return self.btnFullConversation
            }
            .unwrap()

        // Adding comment creation button if needed
        let btnCommentCreationObservable = viewModel.outputs.showCommentCreationButton
            .take(1)
            .do(onNext: { [weak self] mode in
                guard let self = self else { return }
                let btnTitle: String
                switch mode {
                case .push:
                    btnTitle = NSLocalizedString("CommentCreationPushMode", comment: "")
                case .present:
                    btnTitle = NSLocalizedString("CommentCreationPresentMode", comment: "")
                }

                self.btnCommentCreation.setTitle(btnTitle, for: .normal)
            })
            .map { [weak self] _ -> UIButton? in
                guard let self = self else { return nil }
                return self.btnCommentCreation
            }
            .unwrap()

        // Adding comment thread button if needed
        let btnCommentThreadObservable = viewModel.outputs.showCommentThreadButton
            .take(1)
            .do(onNext: { [weak self] mode in
                guard let self = self else { return }
                let btnTitle: String
                switch mode {
                case .push:
                    btnTitle = NSLocalizedString("CommentThreadPushMode", comment: "")
                case .present:
                    btnTitle = NSLocalizedString("CommentThreadPresentMode", comment: "")
                }

                self.btnCommentThread.setTitle(btnTitle, for: .normal)
            })
            .map { [weak self] _ -> UIButton? in
                guard let self = self else { return nil }
                return self.btnCommentThread
            }
            .unwrap()

        Observable.merge(btnFullConversationObservable, btnCommentCreationObservable, btnCommentThreadObservable)
            .subscribe(onNext: { [weak self] btn in
                guard let self = self else { return }

                self.articleView.removeFromSuperview()
                self.articleScrollView.addSubview(self.articleView)
                self.articleScrollView.addSubview(btn)

                btn.snp.makeConstraints { make in
                    make.height.equalTo(Metrics.buttonHeight)
                    make.centerX.equalTo(self.articleScrollView.contentLayoutGuide)
                    make.bottom.equalTo(self.articleScrollView.contentLayoutGuide).offset(-Metrics.verticalMargin)
                }

                self.articleView.snp.makeConstraints { make in
                    make.leading.trailing.top.equalTo(self.articleScrollView.contentLayoutGuide)
                    make.bottom.equalTo(btn.snp.top).offset(-Metrics.verticalMargin)
                }
            })
            .disposed(by: disposeBag)

        // Adding pre conversation
        viewModel.outputs.showPreConversation
            .subscribe(onNext: { [weak self] preConversationView in
                guard let self = self else { return }

                self.articleView.removeFromSuperview()
                self.articleScrollView.addSubview(self.articleView)
                self.articleScrollView.addSubview(preConversationView)

                preConversationView.snp.makeConstraints { make in
                    make.leading.trailing.bottom.equalTo(self.articleScrollView.contentLayoutGuide)
                }

                self.articleView.snp.makeConstraints { make in
                    make.leading.trailing.top.equalTo(self.articleScrollView.contentLayoutGuide)
                    make.bottom.equalTo(preConversationView.snp.top).offset(-Metrics.verticalMargin)
                }
            })
            .disposed(by: disposeBag)

        // Showing error if needed
        viewModel.outputs.showError
            .subscribe(onNext: { [weak self] message in
                self?.showError(message: message)
            })
            .disposed(by: disposeBag)
    }

    func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
#endif
