//
//  AutomationVC.swift
//  Spot-IM.Development
//
//  Created by Alon Haiut on 06/07/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

#if AUTOMATION

class AutomationVC: UIViewController {
    fileprivate struct Metrics {
        static let identifier = "automation_vc_id"
        static let btnFontsIdentifier = "btn_fonts_id"
        static let btnUserInformationIdentifier = "btn_user_information_id"
        static let verticalMargin: CGFloat = 40
        static let horizontalMargin: CGFloat = 50
        static let buttonVerticalMargin: CGFloat = 20
        static let buttonPadding: CGFloat = 10
        static let buttonHeight: CGFloat = 50
    }

    fileprivate let viewModel: AutomationViewModeling
    fileprivate let disposeBag = DisposeBag()

    fileprivate lazy var scrollView: UIScrollView = {
        var scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()

    fileprivate lazy var btnFonts: UIButton = {
        return NSLocalizedString("Fonts", comment: "").blueRoundedButton
    }()

    fileprivate lazy var btnUserInformation: UIButton = {
        return NSLocalizedString("UserInformation", comment: "").blueRoundedButton
    }()

    init(viewModel: AutomationViewModeling) {
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

fileprivate extension AutomationVC {
    func applyAccessibility() {
        view.accessibilityIdentifier = Metrics.identifier
        btnFonts.accessibilityIdentifier = Metrics.btnFontsIdentifier
        btnUserInformation.accessibilityIdentifier = Metrics.btnUserInformationIdentifier
    }

    func setupViews() {
        view.backgroundColor = ColorPalette.shared.color(type: .background)

        // Adding scroll view
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide)
        }

        // Adding fonts button
        scrollView.addSubview(btnFonts)
        btnFonts.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(Metrics.buttonHeight)
            make.leading.equalTo(scrollView).offset(Metrics.horizontalMargin)
            make.top.equalTo(scrollView.contentLayoutGuide).offset(Metrics.verticalMargin)
        }

        // Adding user information button
        scrollView.addSubview(btnUserInformation)
        btnUserInformation.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(Metrics.buttonHeight)
            make.top.equalTo(btnFonts.snp.bottom).offset(Metrics.buttonVerticalMargin)
            make.leading.equalTo(scrollView).offset(Metrics.horizontalMargin)
            make.bottom.equalTo(scrollView.contentLayoutGuide).offset(-Metrics.verticalMargin)
        }

    }

    // swiftlint:disable function_body_length
    func setupObservers() {
        title = viewModel.outputs.title

        btnFonts.rx.tap
            .bind(to: viewModel.inputs.fontsTapped)
            .disposed(by: disposeBag)

        btnUserInformation.rx.tap
            .bind(to: viewModel.inputs.userInformationTapped)
            .disposed(by: disposeBag)
    }
}

#endif
