//
//  AuthenticationPlaygroundNewAPIVC.swift
//  Spot-IM.Development
//
//  Created by Refael Sommer on 16/01/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift
import SnapKit

class AuthenticationPlaygroundNewAPIVC: UIViewController {
    fileprivate struct Metrics {
        static let identifier = "authentication_playground_new_api_vc_id"
        static let switchInitializeSDKIdentifier = "initialize_sdk"
        static let pickerGenericSSOIdentifier = "generic_sso"
        static let pickerJWTSSOIdentifier = "jwt_sso"
        static let switchAutomaticallyDismissIdentifier = "automatically_dismiss"
        static let verticalMargin: CGFloat = 20
        static let verticalBigMargin: CGFloat = 60
        static let horizontalMargin: CGFloat = 10
        static let horizontalSmallMargin: CGFloat = 6
        static let roundCornerRadius: CGFloat = 10
        static let btnPadding: CGFloat = 12
    }

    fileprivate let viewModel: AuthenticationPlaygroundNewAPIViewModeling
    fileprivate let disposeBag = DisposeBag()

    fileprivate lazy var scrollView: UIScrollView = {
        var scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()

    fileprivate lazy var switchInitializeSDK: SwitchSetting = {
        return SwitchSetting(title: NSLocalizedString("InitializeSDKFirst", comment: "") + ":",
                             accessibilityPrefixId: Metrics.switchInitializeSDKIdentifier)
    }()

    fileprivate lazy var lblAutomaticallyDismissDescription: UILabel = {
        return NSLocalizedString("AutomaticallyDismissAfterLoginDescription", comment: "")
            .label
            .font(FontBook.helperLight)
            .textColor(ColorPalette.shared.color(type: .darkGrey))
    }()

    fileprivate lazy var pickerGenericSSO: PickerSetting = {
        let title = NSLocalizedString("GenericSSO", comment: "") + ":"
        return PickerSetting(title: title, accessibilityPrefixId: Metrics.pickerGenericSSOIdentifier)
    }()

    fileprivate lazy var pickerJWTSSO: PickerSetting = {
        let title = NSLocalizedString("JWTSSO", comment: "") + ":"
        return PickerSetting(title: title, accessibilityPrefixId: Metrics.pickerJWTSSOIdentifier)
    }()

    fileprivate lazy var switchAutomaticallyDismiss: SwitchSetting = {
        return SwitchSetting(title: NSLocalizedString("AutomaticallyDismissAfterLogin", comment: "") + ":",
                             accessibilityPrefixId: Metrics.switchAutomaticallyDismissIdentifier, isOn: true)
    }()

    fileprivate lazy var lblGenericSSOStatus: UILabel = statusLabel
    fileprivate lazy var lblJWTSSOStatus: UILabel = statusLabel

    fileprivate lazy var btnGenericSSOAuthenticate: UIButton = blueRoundedButton(key: "Authenticate")
    fileprivate lazy var btnJWTSSOAuthenticate: UIButton = blueRoundedButton(key: "Authenticate")
    fileprivate lazy var btnLogout: UIButton = blueRoundedButton(key: "Logout")

    fileprivate lazy var lblGenericSSOStatusSymbol: UILabel = statusSymbol
    fileprivate lazy var lblJWTSSOStatusSymbol: UILabel = statusSymbol

    fileprivate func blueRoundedButton(key: String) -> UIButton {
        NSLocalizedString(key, comment: "")
            .blueRoundedButton
            .withPadding(Metrics.btnPadding)
    }

    fileprivate var statusLabel: UILabel {
        let text = NSLocalizedString("Status", comment: "") + ":"
        return text
            .label
            .font(FontBook.paragraph)
            .textColor(ColorPalette.shared.color(type: .darkGrey))
    }

    fileprivate var statusSymbol: UILabel {
        return ""
            .label
            .font(FontBook.paragraph)
    }

    init(viewModel: AuthenticationPlaygroundNewAPIViewModeling = AuthenticationPlaygroundNewAPIViewModel()) {
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
}

fileprivate extension AuthenticationPlaygroundNewAPIVC {
    func applyAccessibility() {
        view.accessibilityIdentifier = Metrics.identifier
    }

    func setupViews() {
        view.backgroundColor = ColorPalette.shared.color(type: .background)

        // Adding scroll view
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide)
        }

        // Initialize SDK section
        scrollView.addSubview(switchInitializeSDK)
        switchInitializeSDK.snp.makeConstraints { make in
            make.top.equalTo(scrollView.contentLayoutGuide).offset(2*Metrics.verticalMargin)
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
            make.leading.equalTo(scrollView).offset(2*Metrics.horizontalMargin)
            make.trailing.lessThanOrEqualTo(view.safeAreaLayoutGuide).offset(-Metrics.horizontalMargin)
        }

        // Generic SSO section
        scrollView.addSubview(pickerGenericSSO)
        pickerGenericSSO.snp.makeConstraints { make in
            make.top.equalTo(lblAutomaticallyDismissDescription.snp.bottom).offset(Metrics.verticalMargin)
            make.leading.equalTo(scrollView).offset(Metrics.horizontalMargin)
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-Metrics.horizontalMargin)
        }

        scrollView.addSubview(lblGenericSSOStatus)
        lblGenericSSOStatus.snp.makeConstraints { make in
            make.top.equalTo(pickerGenericSSO.snp.bottom).offset(Metrics.verticalMargin)
            make.leading.equalTo(pickerGenericSSO).offset(Metrics.horizontalMargin)
        }

        scrollView.addSubview(lblGenericSSOStatusSymbol)
        lblGenericSSOStatusSymbol.snp.makeConstraints { make in
            make.centerY.equalTo(lblGenericSSOStatus)
            make.leading.equalTo(lblGenericSSOStatus.snp.trailing).offset(2*Metrics.horizontalSmallMargin)
        }

        scrollView.addSubview(btnGenericSSOAuthenticate)
        btnGenericSSOAuthenticate.snp.makeConstraints { make in
            make.centerY.equalTo(lblGenericSSOStatusSymbol)
            make.leading.equalTo(lblGenericSSOStatusSymbol.snp.trailing).offset(2*Metrics.horizontalSmallMargin)
        }

        // JWT SSO section
        scrollView.addSubview(pickerJWTSSO)
        pickerJWTSSO.snp.makeConstraints { make in
            make.top.equalTo(lblGenericSSOStatus.snp.bottom).offset(Metrics.verticalMargin)
            make.leading.equalTo(scrollView).offset(Metrics.horizontalMargin)
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-Metrics.horizontalMargin)
        }

        scrollView.addSubview(lblJWTSSOStatus)
        lblJWTSSOStatus.snp.makeConstraints { make in
            make.top.equalTo(pickerJWTSSO.snp.bottom).offset(Metrics.verticalMargin)
            make.leading.equalTo(pickerJWTSSO).offset(Metrics.horizontalMargin)
        }

        scrollView.addSubview(lblJWTSSOStatusSymbol)
        lblJWTSSOStatusSymbol.snp.makeConstraints { make in
            make.centerY.equalTo(lblJWTSSOStatus)
            make.leading.equalTo(lblJWTSSOStatus.snp.trailing).offset(2*Metrics.horizontalSmallMargin)
        }

        scrollView.addSubview(btnJWTSSOAuthenticate)
        btnJWTSSOAuthenticate.snp.makeConstraints { make in
            make.centerY.equalTo(lblJWTSSOStatusSymbol)
            make.leading.equalTo(lblJWTSSOStatusSymbol.snp.trailing).offset(2*Metrics.horizontalSmallMargin)
        }

        // Logout
        scrollView.addSubview(btnLogout)
        btnLogout.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(btnJWTSSOAuthenticate.snp.bottom).offset(Metrics.verticalBigMargin)
            make.bottom.equalTo(scrollView.contentLayoutGuide).offset(-Metrics.verticalMargin)
        }
    }

    func setupObservers() {
        title = viewModel.outputs.title

        pickerGenericSSO.rx.selectedPickerIndex
            .map { $0.row }
            .distinctUntilChanged()
            .bind(to: viewModel.inputs.selectedGenericSSOOptionIndex)
            .disposed(by: disposeBag)

        pickerJWTSSO.rx.selectedPickerIndex
            .map { $0.row }
            .distinctUntilChanged()
            .bind(to: viewModel.inputs.selectedJWTSSOOptionIndex)
            .disposed(by: disposeBag)

        viewModel.outputs.genericSSOOptions
            .map { return $0.map { $0.displayName } }
            .bind(to: pickerGenericSSO.rx.setPickerTitles)
            .disposed(by: disposeBag)

        viewModel.outputs.JWTSSOOptions
            .map { return $0.map { $0.displayName } }
            .bind(to: pickerJWTSSO.rx.setPickerTitles)
            .disposed(by: disposeBag)

        viewModel.outputs.genericSSOAuthenticationStatus
            .map { $0.symbol }
            .bind(to: lblGenericSSOStatusSymbol.rx.text)
            .disposed(by: disposeBag)

        viewModel.outputs.JWTSSOAuthenticationStatus
            .map { $0.symbol }
            .bind(to: lblJWTSSOStatusSymbol.rx.text)
            .disposed(by: disposeBag)

        btnGenericSSOAuthenticate.rx.tap
            .bind(to: viewModel.inputs.genericSSOAuthenticatePressed)
            .disposed(by: disposeBag)

        btnJWTSSOAuthenticate.rx.tap
            .bind(to: viewModel.inputs.JWTSSOAuthenticatePressed)
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

        viewModel.outputs.dismissVC
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                if let navController = self.navigationController {
                    navController.popViewController(animated: true)
                } else {
                    self.dismiss(animated: true, completion: nil)
                }
            })
            .disposed(by: disposeBag)
    }
}
