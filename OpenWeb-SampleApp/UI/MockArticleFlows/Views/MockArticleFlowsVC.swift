//
//  MockArticleFlowsVC.swift
//  OpenWeb-Development
//
//  Created by Alon Haiut on 04/09/2022.
//  Copyright © 2022 OpenWeb. All rights reserved.
//

import UIKit
import Combine
import CombineCocoa
import SnapKit

class MockArticleFlowsVC: UIViewController {
    private struct Metrics {
        static let verticalMargin: CGFloat = 40
        static let horizontalMargin: CGFloat = 20
        // 1.2 * screen height, defualt to 1200
        static let articleHeight: CGFloat = 1.2 * (UIApplication.shared.delegate?.window??.screen.bounds.height ?? 800)
        static let articleImageRatio: CGFloat = 2 / 3
        static let articelImageViewCornerRadius: CGFloat = 10
        static let buttonCorners: CGFloat = 16
        static let buttonPadding: CGFloat = 10
        static let buttonHeight: CGFloat = 50
        static let identifier = "mock_article_flows_vc_id"
        static let viewIdentifier = "mock_article_flows_view_id"
        static let loggerViewWidth: CGFloat = 300
        static let loggerViewHeight: CGFloat = 250
        static let loggerInitialTopPadding: CGFloat = 50
    }

    deinit {
        floatingLoggerView.removeFromSuperview()
    }

    private let viewModel: MockArticleFlowsViewModeling
    private var cancellables = Set<AnyCancellable>()

    private lazy var loggerView: UILoggerView = {
        return UILoggerView(viewModel: viewModel.outputs.loggerViewModel)
    }()

    private lazy var floatingLoggerView: OWFloatingView = {
        return OWFloatingView(viewModel: viewModel.outputs.floatingViewViewModel)
    }()

    private lazy var articleScrollView: UIScrollView = {
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

    private lazy var articleView: UIView = {
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

    private lazy var imgViewArticle: UIImageView = {
        return UIImageView()
            .image(UIImage(named: "general_placeholder")!)
            .contentMode(.scaleAspectFit)
            .corner(radius: Metrics.articelImageViewCornerRadius)
    }()

    private lazy var lblArticleDescription: UILabel = {
        let txt = NSLocalizedString("MockArticleDescription", comment: "")

        return txt
            .label
            .numberOfLines(0)
            .font(FontBook.secondaryHeadingMedium)
            .textColor(ColorPalette.shared.color(type: .text))
    }()

    private lazy var btnFullConversation: UIButton = {
        return UIButton()
            .backgroundColor(ColorPalette.shared.color(type: .blue))
            .textColor(ColorPalette.shared.color(type: .extraLightGrey))
            .corner(radius: Metrics.buttonCorners)
            .withHorizontalPadding(Metrics.buttonPadding)
            .font(FontBook.paragraphBold)
    }()

    private lazy var btnCommentCreation: UIButton = {
        return UIButton()
            .backgroundColor(ColorPalette.shared.color(type: .blue))
            .textColor(ColorPalette.shared.color(type: .extraLightGrey))
            .corner(radius: Metrics.buttonCorners)
            .withHorizontalPadding(Metrics.buttonPadding)
            .font(FontBook.paragraphBold)
    }()

    private lazy var btnCommentThread: UIButton = {
        return UIButton()
            .backgroundColor(ColorPalette.shared.color(type: .blue))
            .textColor(ColorPalette.shared.color(type: .extraLightGrey))
            .corner(radius: Metrics.buttonCorners)
            .withHorizontalPadding(Metrics.buttonPadding)
            .font(FontBook.paragraphBold)
    }()

    init(viewModel: MockArticleFlowsViewModeling) {
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
        applyAccessibility()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupObservers()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        applyLargeTitlesIfNeeded()
    }
}

private extension MockArticleFlowsVC {
    func applyAccessibility() {
        view.accessibilityIdentifier = Metrics.identifier
        articleView.accessibilityIdentifier = Metrics.viewIdentifier
    }

    func setupViews() {
        view.backgroundColor = ColorPalette.shared.color(type: .background)
        articleScrollView.backgroundColor = ColorPalette.shared.color(type: .background)

        applyLargeTitlesIfNeeded()

        view.addSubview(articleScrollView)
        articleScrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }

        #if !PUBLIC_DEMO_APP
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) {
            // Add it to the window
            floatingLoggerView.isHidden = true
            keyWindow.addSubview(floatingLoggerView)
            floatingLoggerView.snp.makeConstraints { make in
                make.width.equalTo(Metrics.loggerViewWidth)
                make.height.equalTo(Metrics.loggerViewHeight)
                make.top.equalToSuperview().offset(Metrics.loggerInitialTopPadding)
                make.centerX.equalToSuperview()
            }
        }
        #endif
    }

    // swiftlint:disable function_body_length
    func setupObservers() {
        title = viewModel.outputs.title

        viewModel.outputs.floatingViewViewModel.inputs.setContentView.send(loggerView)

        // Setting those in the VM for integration with the SDK
        viewModel.inputs.setNavigationController(self.navigationController)
        viewModel.inputs.setPresentationalVC(self)

        // Binding button
        btnFullConversation.tapPublisher
            .bind(to: viewModel.inputs.fullConversationButtonTapped)
            .store(in: &cancellables)

        btnCommentCreation.tapPublisher
            .bind(to: viewModel.inputs.commentCreationButtonTapped)
            .store(in: &cancellables)

        btnCommentThread.tapPublisher
            .bind(to: viewModel.inputs.commentThreadButtonTapped)
            .store(in: &cancellables)

        // Setup article image
        viewModel.outputs.articleImageURL
            .sink(receiveValue: { [weak self] url in
                self?.imgViewArticle.image(from: url)
            })
            .store(in: &cancellables)

        // Adding full conversation button if needed
        let btnFullConversationObservable = viewModel.outputs.showFullConversationButton
            .prefix(1)
            .handleEvents(receiveOutput: { [weak self] mode in
                guard let self else { return }
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
                guard let self else { return nil }
                return self.btnFullConversation
            }
            .unwrap()

        // Adding comment creation button if needed
        let btnCommentCreationObservable = viewModel.outputs.showCommentCreationButton
            .prefix(1)
            .handleEvents(receiveOutput: { [weak self] mode in
                guard let self else { return }
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
                guard let self else { return nil }
                return self.btnCommentCreation
            }
            .unwrap()

        // Adding comment thread button if needed
        let btnCommentThreadObservable = viewModel.outputs.showCommentThreadButton
            .prefix(1)
            .handleEvents(receiveOutput: { [weak self] mode in
                guard let self else { return }
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
                guard let self else { return nil }
                return self.btnCommentThread
            }
            .unwrap()

        Publishers.MergeMany(btnFullConversationObservable, btnCommentCreationObservable, btnCommentThreadObservable)
            .sink(receiveValue: { [weak self] btn in
                guard let self else { return }

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
            .store(in: &cancellables)

        // Adding pre conversation
        viewModel.outputs.showPreConversation
            .sink(receiveValue: { [weak self] preConversationView in
                guard let self else { return }

                self.articleView.removeFromSuperview()
                self.articleScrollView.addSubview(self.articleView)
                self.articleScrollView.addSubview(preConversationView)

                preConversationView.snp.makeConstraints { make in
                    make.bottom.equalTo(self.articleScrollView.snp.bottom).inset(300)
                    make.leading.trailing.equalTo(self.articleScrollView.contentLayoutGuide).inset(self.viewModel.outputs.preConversationHorizontalMargin)
                }

                self.articleView.snp.makeConstraints { make in
                    make.leading.trailing.top.equalTo(self.articleScrollView.contentLayoutGuide)
                    make.bottom.equalTo(preConversationView.snp.top).offset(-Metrics.verticalMargin)
                }
            })
            .store(in: &cancellables)

        // Showing error if needed
        viewModel.outputs.showError
            .sink(receiveValue: { [weak self] message in
                self?.showError(message: message)
            })
            .store(in: &cancellables)

        viewModel.outputs.loggerEnabled
            .delay(for: .milliseconds(10), scheduler: DispatchQueue.main)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] loggerEnabled in
                guard let self else { return }
                self.floatingLoggerView.isHidden = !loggerEnabled
            })
            .store(in: &cancellables)
    }

    func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
