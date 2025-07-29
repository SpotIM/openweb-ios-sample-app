//
//  AutomationVC.swift
//  OpenWeb-Development
//
//  Created by Alon Haiut on 06/07/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import UIKit
import Combine
import CombineCocoa
import SnapKit

#if AUTOMATION

class AutomationVC: UIViewController {
    private struct Metrics {
        static let identifier = "automation_vc_id"
        static let btnFontsIdentifier = "btn_fonts_id"
        static let btnUserInformationIdentifier = "btn_user_information_id"
        static let verticalMargin: CGFloat = 40
        static let horizontalMargin: CGFloat = 50
        static let buttonVerticalMargin: CGFloat = 20
        static let buttonHeight: CGFloat = 50
    }

    private let viewModel: AutomationViewModeling
    private var cancellables = Set<AnyCancellable>()

    private lazy var scrollView: UIScrollView = {
        var scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()

    private lazy var btnFonts: UIButton = {
        return NSLocalizedString("Fonts", comment: "").blueRoundedButton
    }()

    private lazy var btnUserInformation: UIButton = {
        return NSLocalizedString("UserInformation", comment: "").blueRoundedButton
    }()

    init(viewModel: AutomationViewModeling) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        applyAccessibility()
        setupObservers()
    }
}

private extension AutomationVC {
    func applyAccessibility() {
        view.accessibilityIdentifier = Metrics.identifier
        btnFonts.accessibilityIdentifier = Metrics.btnFontsIdentifier
        btnUserInformation.accessibilityIdentifier = Metrics.btnUserInformationIdentifier
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

    func setupObservers() {
        title = viewModel.outputs.title

        viewModel.inputs.setNavigationController(self.navigationController)

        btnFonts.tapPublisher
            .bind(to: viewModel.inputs.fontsTapped)
            .store(in: &cancellables)

        btnUserInformation.tapPublisher
            .bind(to: viewModel.inputs.userInformationTapped)
            .store(in: &cancellables)

        // Showing error if needed
        viewModel.outputs.showError
            .sink(receiveValue: { [weak self] message in
                self?.showError(message: message)
            })
            .store(in: &cancellables)
    }

    func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

#endif
