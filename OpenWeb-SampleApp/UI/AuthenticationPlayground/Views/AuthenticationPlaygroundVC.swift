//
//  AuthenticationPlaygroundNewAPIVC.swift
//  OpenWeb-Development
//
//  Created by Refael Sommer on 16/01/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import UIKit
import RxSwift
import SnapKit

class AuthenticationPlaygroundVC: UIViewController {
    private struct Metrics {
        static let identifier = "authentication_playground_new_api_vc_id"
        static let switchInitializeSDKIdentifier = "initialize_sdk"
        static let pickerGenericSSOIdentifier = "generic_sso"
        static let pickerThirdPartySSOIdentifier = "third_party_sso"
        static let switchAutomaticallyDismissIdentifier = "automatically_dismiss"
        static let textFieldSSOTokenIdentifier = "text_field_sso_token"
        static let textFieldUsernameIdentifier = "text_field_username"
        static let textFieldPasswordIdentifier = "text_field_password"
        static let verticalMargin: CGFloat = 20
        static let verticalBigMargin: CGFloat = 60
        static let horizontalMargin: CGFloat = 10
        static let horizontalSmallMargin: CGFloat = 6
        static let btnPadding: CGFloat = 12
    }

    private let viewModel: AuthenticationPlaygroundViewModeling
    private let disposeBag = DisposeBag()

    private lazy var scrollView: UIScrollView = {
        var scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()

    private lazy var switchInitializeSDK: SwitchSetting = {
        return SwitchSetting(title: NSLocalizedString("InitializeSDKFirst", comment: "") + ":",
                             accessibilityPrefixId: Metrics.switchInitializeSDKIdentifier)
    }()

    private lazy var lblAutomaticallyDismissDescription: UILabel = {
        return NSLocalizedString("AutomaticallyDismissAfterLoginDescription", comment: "")
            .label
            .font(FontBook.helperLight)
            .textColor(ColorPalette.shared.color(type: .darkGrey))
    }()

    private lazy var pickerGenericSSO: PickerSetting = {
        let title = NSLocalizedString("GenericSSO", comment: "") + ":"
        return PickerSetting(title: title, accessibilityPrefixId: Metrics.pickerGenericSSOIdentifier)
    }()

    private lazy var textFieldSSOToken: TextFieldSetting = {
        let title = NSLocalizedString("SSOToken", comment: "") + ":"
        return TextFieldSetting(title: title, accessibilityPrefixId: Metrics.textFieldSSOTokenIdentifier, font: FontBook.paragraph)
    }()

    private lazy var textFieldUsername: TextFieldSetting = {
        let title = NSLocalizedString("Username", comment: "") + ":"
        return TextFieldSetting(title: title, accessibilityPrefixId: Metrics.textFieldUsernameIdentifier, font: FontBook.paragraph)
    }()

    private lazy var textFieldPassword: TextFieldSetting = {
        let title = NSLocalizedString("Password", comment: "") + ":"
        return TextFieldSetting(title: title, accessibilityPrefixId: Metrics.textFieldPasswordIdentifier, font: FontBook.paragraph)
    }()

    private lazy var pickerThirdPartySSO: PickerSetting = {
        let title = NSLocalizedString("ThirdPartySSO", comment: "") + ":"
        return PickerSetting(title: title, accessibilityPrefixId: Metrics.pickerThirdPartySSOIdentifier)
    }()

    private lazy var switchAutomaticallyDismiss: SwitchSetting = {
        return SwitchSetting(title: NSLocalizedString("AutomaticallyDismissAfterLogin", comment: "") + ":",
                             accessibilityPrefixId: Metrics.switchAutomaticallyDismissIdentifier, isOn: true)
    }()

    private lazy var customAuthStackView: UIStackView = {
        let customAuthStackView = UIStackView()
        customAuthStackView.axis = .vertical
        customAuthStackView.spacing = Metrics.verticalMargin
        return customAuthStackView
    }()

    private lazy var lblGenericSSOStatus: UILabel = statusLabel
    private lazy var lblThirdPartySSOStatus: UILabel = statusLabel
    private lazy var lblLogoutStatus: UILabel = statusLabel

    private lazy var btnGenericSSOAuthenticate: UIButton = blueRoundedButton(key: "Authenticate")
    private lazy var btnThirdPartySSOAuthenticate: UIButton = blueRoundedButton(key: "Authenticate")
    private lazy var btnLogout: UIButton = blueRoundedButton(key: "Logout")

    private lazy var lblGenericSSOStatusSymbol: UILabel = statusSymbol
    private lazy var lblThirdPartySSOStatusSymbol: UILabel = statusSymbol
    private lazy var lblLogoutStatusSymbol: UILabel = statusSymbol

    private func blueRoundedButton(key: String) -> UIButton {
        NSLocalizedString(key, comment: "")
            .blueRoundedButton
            .withPadding(Metrics.btnPadding)
    }

    private var statusLabel: UILabel {
        let text = NSLocalizedString("Status", comment: "") + ":"
        return text
            .label
            .font(FontBook.paragraph)
            .textColor(ColorPalette.shared.color(type: .darkGrey))
    }

    private var statusSymbol: UILabel {
        return ""
            .label
            .font(FontBook.paragraph)
    }

    private lazy var closeButton: UIButton = {
        var closeButton = UIButton()
        closeButton.setImage(UIImage(named: "closeButton"), for: .normal)
        return closeButton
    }()

    init(viewModel: AuthenticationPlaygroundViewModeling = AuthenticationPlaygroundViewModel()) {
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

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        if isBeingDismissed {
            // Handling dismiss from "presented" mode
            viewModel.inputs.dismissing.onNext()
        } else if isMovingFromParent {
            // Handling dismiss from "push" mode
            viewModel.inputs.dismissing.onNext()
        }
    }
}

private extension AuthenticationPlaygroundVC {
    func applyAccessibility() {
        view.accessibilityIdentifier = Metrics.identifier
    }

    func setupViews() {
        view.backgroundColor = ColorPalette.shared.color(type: .background)
        applyLargeTitlesIfNeeded()

        // Adding scroll view
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide)
        }

        // Initialize SDK section
        scrollView.addSubview(switchInitializeSDK)
        switchInitializeSDK.snp.makeConstraints { make in
            make.top.equalTo(scrollView.contentLayoutGuide).offset(2 * Metrics.verticalMargin)
            make.leading.equalTo(scrollView).offset(Metrics.horizontalMargin)
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-Metrics.horizontalMargin)
        }

        // Automatically dismiss after login section
        scrollView.addSubview(switchAutomaticallyDismiss)
        switchAutomaticallyDismiss.snp.makeConstraints { make in
            make.top.equalTo(switchInitializeSDK.snp.bottom).offset(Metrics.verticalMargin)
            make.leading.equalTo(switchInitializeSDK)
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-Metrics.horizontalMargin)
        }

        scrollView.addSubview(lblAutomaticallyDismissDescription)
        lblAutomaticallyDismissDescription.snp.makeConstraints { make in
            make.top.equalTo(switchAutomaticallyDismiss.snp.bottom).offset(Metrics.verticalMargin)
            make.leading.equalTo(scrollView).offset(2 * Metrics.horizontalMargin)
            make.trailing.lessThanOrEqualTo(view.safeAreaLayoutGuide).offset(-Metrics.horizontalMargin)
        }

        // Generic SSO section
        scrollView.addSubview(pickerGenericSSO)
        pickerGenericSSO.snp.makeConstraints { make in
            make.top.equalTo(lblAutomaticallyDismissDescription.snp.bottom).offset(Metrics.verticalMargin)
            make.leading.equalTo(scrollView).offset(Metrics.horizontalMargin)
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-Metrics.horizontalMargin)
        }

        scrollView.addSubview(customAuthStackView)
        customAuthStackView.snp.makeConstraints { make in
            make.top.equalTo(pickerGenericSSO.snp.bottom).offset(Metrics.verticalMargin)
            make.leading.equalTo(scrollView).offset(Metrics.horizontalMargin)
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-Metrics.horizontalMargin)
        }

        #if !PUBLIC_DEMO_APP
        customAuthStackView.addArrangedSubview(textFieldSSOToken)
        customAuthStackView.addArrangedSubview(textFieldUsername)
        customAuthStackView.addArrangedSubview(textFieldPassword)
        #endif

        scrollView.addSubview(lblGenericSSOStatus)
        lblGenericSSOStatus.snp.makeConstraints { make in
            make.top.equalTo(customAuthStackView.snp.bottom).offset(2 * Metrics.verticalMargin)
            make.leading.equalTo(pickerGenericSSO).offset(Metrics.horizontalMargin)
        }

        scrollView.addSubview(lblGenericSSOStatusSymbol)
        lblGenericSSOStatusSymbol.snp.makeConstraints { make in
            make.centerY.equalTo(lblGenericSSOStatus)
            make.leading.equalTo(lblGenericSSOStatus.snp.trailing).offset(2 * Metrics.horizontalSmallMargin)
        }

        scrollView.addSubview(btnGenericSSOAuthenticate)
        btnGenericSSOAuthenticate.snp.makeConstraints { make in
            make.centerY.equalTo(lblGenericSSOStatusSymbol)
            make.leading.equalTo(lblGenericSSOStatusSymbol.snp.trailing).offset(2 * Metrics.horizontalSmallMargin)
        }

        // Third-party SSO section
        scrollView.addSubview(pickerThirdPartySSO)
        pickerThirdPartySSO.snp.makeConstraints { make in
            make.top.equalTo(lblGenericSSOStatus.snp.bottom).offset(Metrics.verticalMargin)
            make.leading.equalTo(scrollView).offset(Metrics.horizontalMargin)
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-Metrics.horizontalMargin)
        }

        scrollView.addSubview(lblThirdPartySSOStatus)
        lblThirdPartySSOStatus.snp.makeConstraints { make in
            make.top.equalTo(pickerThirdPartySSO.snp.bottom).offset(Metrics.verticalMargin)
            make.leading.equalTo(pickerThirdPartySSO).offset(Metrics.horizontalMargin)
        }

        scrollView.addSubview(lblThirdPartySSOStatusSymbol)
        lblThirdPartySSOStatusSymbol.snp.makeConstraints { make in
            make.centerY.equalTo(lblThirdPartySSOStatus)
            make.leading.equalTo(lblThirdPartySSOStatus.snp.trailing).offset(2 * Metrics.horizontalSmallMargin)
        }

        scrollView.addSubview(btnThirdPartySSOAuthenticate)
        btnThirdPartySSOAuthenticate.snp.makeConstraints { make in
            make.centerY.equalTo(lblThirdPartySSOStatusSymbol)
            make.leading.equalTo(lblThirdPartySSOStatusSymbol.snp.trailing).offset(2 * Metrics.horizontalSmallMargin)
        }

        // Logout
        scrollView.addSubview(lblLogoutStatus)
        lblLogoutStatus.snp.makeConstraints { make in
            make.top.equalTo(btnThirdPartySSOAuthenticate.snp.bottom).offset(Metrics.verticalBigMargin)
            make.leading.equalTo(lblThirdPartySSOStatus)
        }

        scrollView.addSubview(lblLogoutStatusSymbol)
        lblLogoutStatusSymbol.snp.makeConstraints { make in
            make.centerY.equalTo(lblLogoutStatus)
            make.leading.equalTo(lblLogoutStatus.snp.trailing).offset(2 * Metrics.horizontalSmallMargin)
        }

        scrollView.addSubview(btnLogout)
        btnLogout.snp.makeConstraints { make in
            make.centerY.equalTo(lblLogoutStatusSymbol)
            make.leading.equalTo(lblLogoutStatusSymbol.snp.trailing).offset(2 * Metrics.horizontalSmallMargin)
            make.bottom.equalTo(scrollView.contentLayoutGuide).offset(-Metrics.verticalMargin)
        }

        // If auth VC is the only one on the navigation - add close button
        if navigationController?.viewControllers.count == 1 {
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: closeButton)
        }
    }

    func setupObservers() {
        title = viewModel.outputs.title

        pickerGenericSSO.rx.selectedPickerIndex
            .map { $0.row }
            .distinctUntilChanged()
            .bind(to: viewModel.inputs.selectedGenericSSOOptionIndex)
            .disposed(by: disposeBag)

        textFieldSSOToken.rx.textFieldText
            .unwrap()
            .bind(to: viewModel.inputs.customSSOToken)
            .disposed(by: disposeBag)

        textFieldUsername.rx.textFieldText
            .unwrap()
            .bind(to: viewModel.inputs.customUsername)
            .disposed(by: disposeBag)

        textFieldPassword.rx.textFieldText
            .unwrap()
            .bind(to: viewModel.inputs.customPassword)
            .disposed(by: disposeBag)

        pickerThirdPartySSO.rx.selectedPickerIndex
            .map { $0.row }
            .distinctUntilChanged()
            .bind(to: viewModel.inputs.selectedThirdPartySSOOptionIndex)
            .disposed(by: disposeBag)

        viewModel.outputs.genericSSOOptions
            .map { return $0.map { $0.displayName } }
            .bind(to: pickerGenericSSO.rx.setPickerTitles)
            .disposed(by: disposeBag)

        viewModel.outputs.thirdPartySSOOptions
            .map { return $0.map { $0.displayName } }
            .bind(to: pickerThirdPartySSO.rx.setPickerTitles)
            .disposed(by: disposeBag)

        viewModel.outputs.genericSSOAuthenticationStatus
            .map { $0.symbol }
            .bind(to: lblGenericSSOStatusSymbol.rx.text)
            .disposed(by: disposeBag)

        viewModel.outputs.thirdPartySSOAuthenticationStatus
            .map { $0.symbol }
            .bind(to: lblThirdPartySSOStatusSymbol.rx.text)
            .disposed(by: disposeBag)

        viewModel.outputs.logoutAuthenticationStatus
            .map { $0.symbol }
            .bind(to: lblLogoutStatusSymbol.rx.text)
            .disposed(by: disposeBag)

        btnGenericSSOAuthenticate.rx.tap
            .bind(to: viewModel.inputs.genericSSOAuthenticatePressed)
            .disposed(by: disposeBag)

        btnThirdPartySSOAuthenticate.rx.tap
            .bind(to: viewModel.inputs.thirdPartySSOAuthenticatePressed)
            .disposed(by: disposeBag)

        btnLogout.rx.tap
            .bind(to: viewModel.inputs.logoutPressed)
            .disposed(by: disposeBag)

        switchInitializeSDK.rx.isOn
            .bind(to: viewModel.inputs.initializeSDKToggled)
            .disposed(by: disposeBag)

        switchAutomaticallyDismiss.rx.isOn
            .bind(to: viewModel.inputs.automaticallyDismissToggled)
            .disposed(by: disposeBag)

        closeButton.rx.tap
            .bind(to: viewModel.inputs.closeClick)
            .disposed(by: disposeBag)

        viewModel.outputs.customSSOTokenChanged
            .bind(to: textFieldSSOToken.rx.textFieldText)
            .disposed(by: disposeBag)

        viewModel.outputs.customPasswordChanged
            .bind(to: textFieldPassword.rx.textFieldText)
            .disposed(by: disposeBag)

        viewModel.outputs.customUsernameChanged
            .bind(to: textFieldUsername.rx.textFieldText)
            .disposed(by: disposeBag)

        /*
         Responding to VC dismissed here and not at the Coordinator layer because this screen is a "mock" screen for
         autentication for the SDK. Therefore it's easier to dismiss it simply from here here, at least for now.
         */
        viewModel.outputs.dismissVC
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                if let navController = self.navigationController {
                    navController.popViewController(animated: true)
                } else {
                    self.dismiss(animated: true, completion: nil)
                }

                self.viewModel.inputs.dismissing.onNext(())
            })
            .disposed(by: disposeBag)
    }
}
