//
//  MockArticleIndependentViewsVC.swift
//  Spot-IM.Development
//
//  Created by Refael Sommer on 21/03/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

#if NEW_API

class MockArticleIndependentViewsVC: UIViewController {
    fileprivate struct Metrics {
        static let verticalMargin: CGFloat = 40
        static let horizontalMargin: CGFloat = 20
        static let loggerHeight: CGFloat = 0.3 * (UIApplication.shared.delegate?.window??.screen.bounds.height ?? 800)
        static let identifier = "mock_article_independent_views_vc_id"
        static let viewIdentifier = "mock_article_independent_views_view_id"
        static let settingsBarItemIdentifier = "settings_bar_item_id"
    }

    fileprivate let viewModel: MockArticleIndependentViewsViewModeling
    fileprivate let disposeBag = DisposeBag()

    fileprivate lazy var articleView: UIView = {
        let article = UIView()

        article.addSubview(loggerView)
        loggerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Metrics.verticalMargin)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(Metrics.loggerHeight)
            make.bottom.equalToSuperview()
        }

        return article
    }()

    fileprivate lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()

        scroll.contentLayoutGuide.snp.makeConstraints { make in
            make.width.equalTo(scroll.snp.width)
        }

        return scroll
    }()

    fileprivate var independentView: UIView? = nil

    fileprivate lazy var settingsBarItem: UIBarButtonItem = {
        return UIBarButtonItem(image: UIImage(named: "settingsIcon"),
                               style: .plain,
                               target: nil,
                               action: nil)
    }()

    fileprivate lazy var loggerView: UILoggerView = {
        return UILoggerView(viewModel: viewModel.outputs.loggerViewModel)
    }()

    init(viewModel: MockArticleIndependentViewsViewModeling) {
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
        navigationItem.rightBarButtonItems = [settingsBarItem]
    }
}

fileprivate extension MockArticleIndependentViewsVC {
    func applyAccessibility() {
        view.accessibilityIdentifier = Metrics.identifier
        articleView.accessibilityIdentifier = Metrics.viewIdentifier
        settingsBarItem.accessibilityIdentifier = Metrics.settingsBarItemIdentifier
    }

    func setupViews() {
        view.backgroundColor = ColorPalette.shared.color(type: .lightGrey)

        view.addSubview(articleView)
        articleView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
        }

        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
            make.top.equalTo(articleView.snp.bottom)
        }
    }

    func setupObservers() {
        title = viewModel.outputs.title

        settingsBarItem.rx.tap
            .bind(to: viewModel.inputs.settingsTapped)
            .disposed(by: disposeBag)

        viewModel.outputs.openSettings
            .subscribe(onNext: { [weak self] settingsType in
                guard let self = self else { return }
                let settingsVM = SettingsViewModel(settingViewTypes: [settingsType])
                let settingsVC = SettingsVC(viewModel: settingsVM)
                self.navigationController?.pushViewController(settingsVC, animated: true)
            })
            .disposed(by: disposeBag)

        viewModel.outputs.showComponent
            .subscribe(onNext: { [weak self] result in
                guard let self = self else { return }
                let view = result.0
                let type = result.1

                // Clean ups
                self.independentView?.removeFromSuperview()
                self.independentView = view

                switch type {
                case .preConversation:
                    self.handlePreConversationPresentation()
                case.conversation:
                    self.handleConversationPresentation()
                default:
                    // TODO: Implement for supported types
                    break
                }
            })
            .disposed(by: disposeBag)
    }

    func handlePreConversationPresentation() {
        guard let preConversation = self.independentView else { return }

        scrollView.addSubview(preConversation)
        preConversation.snp.makeConstraints { make in
            make.leading.trailing.equalTo(scrollView.contentLayoutGuide).inset(viewModel.outputs.independentViewHorizontalMargin)
            make.top.equalTo(scrollView.contentLayoutGuide.snp.top).offset(Metrics.verticalMargin)
            make.bottom.lessThanOrEqualTo(scrollView.contentLayoutGuide.snp.bottom)
        }
    }

    func handleConversationPresentation() {
        guard let conversation = self.independentView else { return }

        scrollView.addSubview(conversation)
        conversation.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.height.equalTo(scrollView.snp.height)
        }
    }
}
#endif
