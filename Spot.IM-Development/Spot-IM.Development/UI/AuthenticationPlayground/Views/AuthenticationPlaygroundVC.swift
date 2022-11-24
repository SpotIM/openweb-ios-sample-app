//
//  AuthenticationPlaygroundVC.swift
//  Spot-IM.Development
//
//  Created by Alon Haiut on 10/05/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift
import SnapKit

class AuthenticationPlaygroundVC: UIViewController {
    fileprivate struct Metrics {
        static let verticalMargin: CGFloat = 20
        static let verticalBigMargin: CGFloat = 60
        static let horizontalMargin: CGFloat = 20
        static let horizontalSmallMargin: CGFloat = 6
        static let roundCornerRadius: CGFloat = 10
        static let btnPadding: CGFloat = 6
    }
    
    fileprivate let viewModel: AuthenticationPlaygroundViewModeling
    fileprivate let disposeBag = DisposeBag()
    
    fileprivate lazy var lblInitializeSDK: UILabel = {
        let txt = NSLocalizedString("InitializeSDKFirst", comment: "") + ":"
        return txt
            .label
            .font(FontBook.secondaryHeadingBold)
            .textColor(ColorPalette.blackish)
    }()
    
    fileprivate lazy var switchInitializeSDK: UISwitch = {
        let aSwitch = UISwitch()
        return aSwitch
    }()
    
    fileprivate lazy var lblAutomaticallyDismiss: UILabel = {
        let txt = NSLocalizedString("AutomaticallyDismissAfterLogin", comment: "") + ":"
        return txt
            .label
            .font(FontBook.secondaryHeadingBold)
            .textColor(ColorPalette.blackish)
    }()
    
    fileprivate lazy var lblAutomaticallyDismissDescription: UILabel = {
        return NSLocalizedString("AutomaticallyDismissAfterLoginDescription", comment: "")
            .label
            .font(FontBook.helperLight)
            .textColor(ColorPalette.darkGrey)
    }()
    
    fileprivate lazy var switchAutomaticallyDismiss: UISwitch = {
        let aSwitch = UISwitch()
        aSwitch.setOn(true, animated: false)
        return aSwitch
    }()
    
    fileprivate lazy var lblGenericSSO: UILabel = {
        let txt = NSLocalizedString("GenericSSO", comment: "") + ":"
        return txt
            .label
            .font(FontBook.secondaryHeadingBold)
            .textColor(ColorPalette.blackish)
    }()
    
    fileprivate lazy var lblGenericSSOStatus: UILabel = {
        let txt = NSLocalizedString("Status", comment: "") + ":"
        return txt
            .label
            .font(FontBook.paragraph)
            .textColor(ColorPalette.darkGrey)
    }()
    
    fileprivate lazy var lblGenericSSOStatusSymbol: UILabel = {
        return ""
            .label
            .font(FontBook.paragraph)
    }()
    
    fileprivate lazy var btnGenericSSOAuthenticate: UIButton = {
        let txt = NSLocalizedString("Authenticate", comment: "")
        return txt
            .button
            .font(FontBook.secondaryHeading)
            .textColor(ColorPalette.extraLightGrey)
            .backgroundColor(ColorPalette.blue)
            .corner(radius: Metrics.roundCornerRadius)
            .withPadding(Metrics.btnPadding)
    }()
    
    fileprivate lazy var lblJWTSSO: UILabel = {
        let txt = NSLocalizedString("JWTSSO", comment: "") + ":"
        return txt
            .label
            .wrapContent(axis: .horizontal) // Needed to set compression resistance for some reason
            .font(FontBook.secondaryHeadingBold)
            .textColor(ColorPalette.blackish)
    }()
    
    fileprivate lazy var lblJWTSSOStatus: UILabel = {
        let txt = NSLocalizedString("Status", comment: "") + ":"
        return txt
            .label
            .font(FontBook.paragraph)
            .textColor(ColorPalette.darkGrey)
    }()
    
    fileprivate lazy var lblJWTSSOStatusSymbol: UILabel = {
        return ""
            .label
            .font(FontBook.paragraph)
    }()
    
    fileprivate lazy var btnJWTSSOAuthenticate: UIButton = {
        let txt = NSLocalizedString("Authenticate", comment: "")
        return txt
            .button
            .font(FontBook.secondaryHeading)
            .textColor(ColorPalette.extraLightGrey)
            .backgroundColor(ColorPalette.blue)
            .corner(radius: Metrics.roundCornerRadius)
            .withPadding(Metrics.btnPadding)
    }()
    
    fileprivate lazy var btnLogout: UIButton = {
        let txt = NSLocalizedString("Logout", comment: "")
        return txt
            .button
            .font(FontBook.secondaryHeading)
            .textColor(ColorPalette.extraLightGrey)
            .backgroundColor(ColorPalette.blue)
            .corner(radius: Metrics.roundCornerRadius)
            .withPadding(Metrics.btnPadding)
    }()

    fileprivate lazy var pickerGenericSSO: UIPickerView = {
        let picker = UIPickerView()
        return picker
    }()
    
    fileprivate lazy var pickerJWTSSO: UIPickerView = {
        let picker = UIPickerView()
        return picker
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
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupObservers()
    }
}

fileprivate extension AuthenticationPlaygroundVC {
    func setupViews() {
        view.backgroundColor = .white
        
        // Initialize SDK section
        view.addSubview(lblInitializeSDK)
        lblInitializeSDK.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(2*Metrics.verticalMargin)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(Metrics.horizontalMargin)
        }
        
        view.addSubview(switchInitializeSDK)
        switchInitializeSDK.snp.makeConstraints { make in
            make.centerY.equalTo(lblInitializeSDK)
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-Metrics.horizontalMargin)
        }
        
        // Automatically dismiss after login section
        view.addSubview(lblAutomaticallyDismiss)
        lblAutomaticallyDismiss.snp.makeConstraints { make in
            make.top.equalTo(lblInitializeSDK.snp.bottom).offset(Metrics.verticalMargin)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(Metrics.horizontalMargin)
        }
        
        view.addSubview(lblAutomaticallyDismissDescription)
        lblAutomaticallyDismissDescription.snp.makeConstraints { make in
            make.top.equalTo(lblAutomaticallyDismiss.snp.bottom).offset(0.5 * Metrics.verticalMargin)
            make.leading.equalTo(lblAutomaticallyDismiss)
            make.trailing.lessThanOrEqualTo(view.safeAreaLayoutGuide).offset(-Metrics.horizontalMargin)
        }
        
        view.addSubview(switchAutomaticallyDismiss)
        switchAutomaticallyDismiss.snp.makeConstraints { make in
            make.centerY.equalTo(lblAutomaticallyDismiss)
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-Metrics.horizontalMargin)
        }

        // Generic SSO section
        view.addSubview(lblGenericSSO)
        lblGenericSSO.snp.makeConstraints { make in
            make.top.equalTo(lblAutomaticallyDismissDescription.snp.bottom).offset(1.5*Metrics.verticalBigMargin)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(Metrics.horizontalMargin)
        }
        
        view.addSubview(pickerGenericSSO)
        pickerGenericSSO.snp.makeConstraints { make in
            make.centerY.equalTo(lblGenericSSO)
            make.leading.equalTo(lblGenericSSO.snp.trailing).offset(Metrics.horizontalSmallMargin)
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-Metrics.horizontalMargin)
        }
        
        view.addSubview(lblGenericSSOStatus)
        lblGenericSSOStatus.snp.makeConstraints { make in
            make.top.equalTo(lblGenericSSO.snp.bottom).offset(1.5*Metrics.verticalBigMargin)
            make.leading.equalTo(lblGenericSSO).offset(Metrics.horizontalMargin)
        }
        
        view.addSubview(lblGenericSSOStatusSymbol)
        lblGenericSSOStatusSymbol.snp.makeConstraints { make in
            make.centerY.equalTo(lblGenericSSOStatus)
            make.leading.equalTo(lblGenericSSOStatus.snp.trailing).offset(2*Metrics.horizontalSmallMargin)
        }
        
        view.addSubview(btnGenericSSOAuthenticate)
        btnGenericSSOAuthenticate.snp.makeConstraints { make in
            make.centerY.equalTo(lblGenericSSOStatusSymbol)
            make.leading.equalTo(lblGenericSSOStatusSymbol.snp.trailing).offset(2*Metrics.horizontalSmallMargin)
        }
        
        // JWT SSO section
        view.addSubview(lblJWTSSO)
        lblJWTSSO.snp.makeConstraints { make in
            make.top.equalTo(lblGenericSSOStatus.snp.bottom).offset(2 * Metrics.verticalBigMargin)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(Metrics.horizontalMargin)
        }
        
        view.addSubview(pickerJWTSSO)
        pickerJWTSSO.snp.makeConstraints { make in
            make.centerY.equalTo(lblJWTSSO)
            make.leading.equalTo(lblJWTSSO.snp.trailing).offset(Metrics.horizontalSmallMargin)
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-Metrics.horizontalMargin)
        }
        
        view.addSubview(lblJWTSSOStatus)
        lblJWTSSOStatus.snp.makeConstraints { make in
            make.top.equalTo(lblJWTSSO.snp.bottom).offset(1.5*Metrics.verticalBigMargin)
            make.leading.equalTo(lblJWTSSO).offset(Metrics.horizontalMargin)
        }
        
        view.addSubview(lblJWTSSOStatusSymbol)
        lblJWTSSOStatusSymbol.snp.makeConstraints { make in
            make.centerY.equalTo(lblJWTSSOStatus)
            make.leading.equalTo(lblJWTSSOStatus.snp.trailing).offset(2*Metrics.horizontalSmallMargin)
        }
        
        view.addSubview(btnJWTSSOAuthenticate)
        btnJWTSSOAuthenticate.snp.makeConstraints { make in
            make.centerY.equalTo(lblJWTSSOStatusSymbol)
            make.leading.equalTo(lblJWTSSOStatusSymbol.snp.trailing).offset(2*Metrics.horizontalSmallMargin)
        }
        
        // Logout
        view.addSubview(btnLogout)
        btnLogout.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.greaterThanOrEqualTo(btnJWTSSOAuthenticate.snp.bottom).offset(Metrics.verticalMargin)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-Metrics.verticalMargin)
        }
    }

    func setupObservers() {
        title = viewModel.outputs.title
        
        pickerGenericSSO.rx.itemSelected
            .map { event in
                return event.row
            }
            .distinctUntilChanged()
            .bind(to: viewModel.inputs.selectedGenericSSOOptionIndex)
            .disposed(by: disposeBag)
        
        pickerJWTSSO.rx.itemSelected
            .map { event in
                return event.row
            }
            .distinctUntilChanged()
            .bind(to: viewModel.inputs.selectedJWTSSOOptionIndex)
            .disposed(by: disposeBag)
        
        viewModel.outputs.genericSSOOptions
            .map { options in
                return options.map { $0.displayName }
            }
            .bind(to: pickerGenericSSO.rx.itemTitles) { _, item in
                return item
            }
            .disposed(by: disposeBag)
        
        viewModel.outputs.JWTSSOOptions
            .map { options in
                return options.map { $0.displayName }
            }
            .bind(to: pickerJWTSSO.rx.itemTitles) { _, item in
                return item
            }
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
