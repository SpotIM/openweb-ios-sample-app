//
//  TestingPlaygroundIndependentViewVC.swift
//  Spot-IM.Development
//
//  Created by Alon Haiut on 20/04/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class TestingPlaygroundIndependentViewVC: UIViewController {
    fileprivate struct Metrics {
        static let verticalMargin: CGFloat = 40
        static let loggerHeight: CGFloat = 0.3 * (UIApplication.shared.delegate?.window??.screen.bounds.height ?? 800)
        static let identifier = "testing_playground_independent_view_vc_id"
    }

    fileprivate let viewModel: TestingPlaygroundIndependentViewModeling
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

    init(viewModel: TestingPlaygroundIndependentViewModeling) {
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

fileprivate extension TestingPlaygroundIndependentViewVC {
    func applyAccessibility() {
        view.accessibilityIdentifier = Metrics.identifier
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
