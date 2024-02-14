//
//  OWSafariViewController.swift
//  OpenWebSDK
//
//  Created by  Nogah Melamed on 09/11/2022.
//  Copyright © 2022 OpenWeb. All rights reserved.
//

import Foundation
import UIKit
import SafariServices
import RxSwift
import RxCocoa

class OWWebTabVC: UIViewController {
    fileprivate struct Metrics {
        static let closeButtonImageName: String = "closeButton"
        static let backButtonImageName: String = "backButton"
    }

    private let viewModel: OWWebTabViewModeling
    let disposeBag = DisposeBag()

    fileprivate lazy var safariTabView: OWWebTabView = {
        return OWWebTabView(viewModel: self.viewModel.outputs.webTabViewVM)
    }()

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate lazy var closeButton: UIButton = {
        return UIButton()
            .image(UIImage(spNamed: Metrics.closeButtonImageName, supportDarkMode: true), state: .normal)
            .horizontalAlignment(.left)
    }()

    fileprivate lazy var backButton: UIButton = {
        return UIButton()
            .image(UIImage(spNamed: Metrics.backButtonImageName, supportDarkMode: true), state: .normal)
            .horizontalAlignment(.left)
    }()

    init(viewModel: OWWebTabViewModeling) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.inputs.viewDidLoad.onNext()
    }

    override func loadView() {
        super.loadView()
        setupUI()
        setupObservers()
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return OWSharedServicesProvider.shared.orientationService().interfaceOrientationMask
    }
}

fileprivate extension OWWebTabVC {
    func setupUI() {
        self.navigationItem.largeTitleDisplayMode = .never
        self.view.addSubview(safariTabView)
        safariTabView.OWSnp.makeConstraints { make in
            make.top.equalToSuperviewSafeArea()
            make.leading.trailing.bottom.equalToSuperview()
        }

        addCloseButtonIfNeeded()
    }

    func setupObservers() {
        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.closeButton.image(UIImage(spNamed: Metrics.closeButtonImageName, supportDarkMode: true), state: .normal)
                self.backButton.image(UIImage(spNamed: Metrics.backButtonImageName, supportDarkMode: true), state: .normal)
            })
            .disposed(by: disposeBag)

        closeButton.rx.tap
            .bind(to: viewModel.inputs.closeWebTabTapped)
            .disposed(by: disposeBag)

        viewModel.outputs
            .webTabViewVM
            .outputs
            .shouldShowCloseButton
            .subscribe(onNext: { [weak self] shouldShow in
                guard let self = self else { return }
                addCloseButtonIfNeeded(shouldShow)
            })
            .disposed(by: disposeBag)

        backButton.rx.tap
            .bind(to: viewModel.outputs.webTabViewVM.inputs.backWebTabTapped)
            .disposed(by: disposeBag)

        viewModel.outputs
            .webTabViewVM.outputs
            .shouldShowBackButton
            .subscribe(onNext: { [weak self] shouldShow in
                guard let self = self else { return }
                addBackButtonIfNeeded(shouldShow)
            })
            .disposed(by: disposeBag)

        viewModel.outputs
            .webTabViewVM.outputs
            .title
            .subscribe(onNext: { [weak self] title in
                guard let self = self else { return }
                self.title = title
            })
            .disposed(by: disposeBag)
    }

    func addCloseButtonIfNeeded(_ shouldShow: Bool = false) {
        // Only on present mode when this is the only VC
        let isRootViewController = (self.navigationController?.viewControllers.count == 1)

        let _shouldShow = isRootViewController || shouldShow

        navigationItem.rightBarButtonItem = _shouldShow ? UIBarButtonItem(customView: closeButton) : nil
    }

    func addBackButtonIfNeeded(_ shouldShow: Bool) {
        navigationItem.leftBarButtonItem = shouldShow ? UIBarButtonItem(customView: backButton) : nil
    }
}
