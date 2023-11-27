//
//  OWSafariViewController.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 09/11/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import UIKit
import SafariServices
import RxSwift

class OWWebTabVC: UIViewController {
    fileprivate struct Metrics {
        static let closeButtonImageName: String = "closeButton"
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
        let closeButton = UIButton()
            .image(UIImage(spNamed: Metrics.closeButtonImageName, supportDarkMode: true), state: .normal)
            .horizontalAlignment(.left)

        closeButton.addTarget(self, action: #selector(self.closeWebTabTapped(_:)), for: .touchUpInside)
        return closeButton
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
        return OWManager.manager.helpers.orientationEnforcement.interfaceOrientationMask
    }
}

fileprivate extension OWWebTabVC {
    func setupUI() {
        self.title = viewModel.outputs.options.title
        self.navigationItem.largeTitleDisplayMode = .never
        self.view.addSubview(safariTabView)
        safariTabView.OWSnp.makeConstraints { make in
            make.top.equalToSuperviewSafeArea()
            make.leading.trailing.bottom.equalToSuperview()
        }

        addingCloseButtonIfNeeded()
    }

    func setupObservers() {
        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.closeButton.image(UIImage(spNamed: Metrics.closeButtonImageName, supportDarkMode: true), state: .normal)
            })
            .disposed(by: disposeBag)
    }

    func addingCloseButtonIfNeeded() {
        // Only on present mode when this is the only VC
        if self.navigationController?.viewControllers.count == 1 {
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: closeButton)
        }
    }

    @objc func closeWebTabTapped(_ sender: UIBarButtonItem) {
        viewModel.inputs.closeWebTabTapped.onNext()
    }
}
