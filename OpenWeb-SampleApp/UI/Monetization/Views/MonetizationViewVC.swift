//
//  MonetizationViewVC.swift
//  OpenWeb-SampleApp
//
//  Created by Anael on 25/11/2024.
//

import Foundation
import UIKit
import RxSwift

class MonetizationViewVC: UIViewController {
    private struct Metrics {
        static let identifier = "uiviews_monetization_vc_id"
        static let btnPreConversationExampleIdentifier = "btn_pre_conversation_example_id"
        static let btnSocialMonetizationExampleIdentifier = "btn_social_monetization_example_id"
        static let verticalMargin: CGFloat = 40
        static let horizontalMargin: CGFloat = 50
        static let buttonHeight: CGFloat = 50
        static let buttonVerticalMargin: CGFloat = 20
    }

    private let viewModel: MonetizationViewViewModeling
    private let disposeBag = DisposeBag()

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

    private lazy var btnSocialMonetizationExample: UIButton = {
        return NSLocalizedString("SingleAd", comment: "")
            .blueRoundedButton
    }()

    init(viewModel: MonetizationViewViewModeling) {
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

private extension MonetizationViewVC {
    func applyAccessibility() {
        view.accessibilityIdentifier = Metrics.identifier
        btnPreConversationExample.accessibilityIdentifier = Metrics.btnPreConversationExampleIdentifier
        btnSocialMonetizationExample.accessibilityIdentifier = Metrics.btnSocialMonetizationExampleIdentifier
    }

    func setupViews() {
        view.backgroundColor = ColorPalette.shared.color(type: .background)
        self.navigationItem.largeTitleDisplayMode = .never

        // Adding scroll view
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide)
        }

        // Adding social monetization example button
        scrollView.addSubview(btnSocialMonetizationExample)
        btnSocialMonetizationExample.snp.makeConstraints { make in
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
            make.top.equalTo(btnSocialMonetizationExample.snp.bottom).offset(Metrics.buttonVerticalMargin)
            make.leading.equalTo(scrollView).offset(Metrics.horizontalMargin)
            make.bottom.equalTo(scrollView.contentLayoutGuide).offset(-Metrics.verticalMargin)
        }
    }

    func setupObservers() {
        title = viewModel.outputs.title

        btnSocialMonetizationExample.rx.tap
            .bind(to: viewModel.inputs.socialMonetizationExampleTapped)
            .disposed(by: disposeBag)

        btnPreConversationExample.rx.tap
            .bind(to: viewModel.inputs.preConversationExampleTapped)
            .disposed(by: disposeBag)
    }
}
