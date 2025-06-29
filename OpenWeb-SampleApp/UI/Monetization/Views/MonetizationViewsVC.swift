//
//  MonetizationViewsVC.swift
//  OpenWeb-SampleApp
//
//  Created by Anael on 25/11/2024.
//

import Foundation
import UIKit
import Combine

class MonetizationViewsVC: UIViewController {
    private struct Metrics {
        static let identifier = "views_monetization_vc_id"
        static let btnPreConversationExampleIdentifier = "views_btn_pre_conversation_example_with_ad_id"
        static let btnSingleAdExampleIdentifier = "views_btn_single_ad_example_id"
        static let verticalMargin: CGFloat = 40
        static let horizontalMargin: CGFloat = 50
        static let buttonHeight: CGFloat = 50
        static let buttonVerticalMargin: CGFloat = 20
    }

    private let viewModel: MonetizationViewsViewModeling
    private var cancellables = Set<AnyCancellable>()

    private lazy var scrollView: UIScrollView = {
        var scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()

    private lazy var btnPreConversationExample: UIButton = {
        return NSLocalizedString("PreConversationWithAd", comment: "")
            .blueRoundedButton
    }()

    private lazy var btnSingleAdExample: UIButton = {
        return NSLocalizedString("SingleAd", comment: "")
            .blueRoundedButton
    }()

    init(viewModel: MonetizationViewsViewModeling) {
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

private extension MonetizationViewsVC {
    func applyAccessibility() {
        view.accessibilityIdentifier = Metrics.identifier
        btnPreConversationExample.accessibilityIdentifier = Metrics.btnPreConversationExampleIdentifier
        btnSingleAdExample.accessibilityIdentifier = Metrics.btnSingleAdExampleIdentifier
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

        // Adding social monetization example button
        scrollView.addSubview(btnSingleAdExample)
        btnSingleAdExample.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(Metrics.buttonHeight)
            make.top.equalTo(scrollView).offset(Metrics.verticalMargin)
            make.leading.equalTo(scrollView).offset(Metrics.horizontalMargin)
            make.top.equalTo(scrollView.contentLayoutGuide).offset(Metrics.verticalMargin)
        }

        // Adding preConversation Example button
        scrollView.addSubview(btnPreConversationExample)
        btnPreConversationExample.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(Metrics.buttonHeight)
            make.top.equalTo(btnSingleAdExample.snp.bottom).offset(Metrics.buttonVerticalMargin)
            make.leading.equalTo(scrollView).offset(Metrics.horizontalMargin)
            make.bottom.equalTo(scrollView.contentLayoutGuide).offset(-Metrics.verticalMargin)
        }
    }

    func setupObservers() {
        title = viewModel.outputs.title

        btnSingleAdExample.tapPublisher
            .bind(to: viewModel.inputs.singleAdExampleTapped)
            .store(in: &cancellables)

        btnPreConversationExample.tapPublisher
            .bind(to: viewModel.inputs.preConversationWithAdTapped)
            .store(in: &cancellables)
    }
}
