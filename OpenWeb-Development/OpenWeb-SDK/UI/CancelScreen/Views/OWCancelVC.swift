//
//  OWCancelVC.swift
//  OpenWebSDK
//
//  Created by Refael Sommer on 24/04/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class OWCancelVC: UIViewController, OWStatusBarStyleUpdaterProtocol {
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let viewModel: OWCancelViewModeling
    let disposeBag = DisposeBag()

    init(cancelViewModel: OWCancelViewModeling) {
        self.viewModel = cancelViewModel
        super.init(nibName: nil, bundle: nil)
    }

    override func loadView() {
        super.loadView()
        setupViews()
        setupObservers()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return OWSharedServicesProvider.shared.statusBarStyleService().currentStyle
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return OWSharedServicesProvider.shared.orientationService().interfaceOrientationMask
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}

private extension OWCancelVC {
    func setupViews() {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        view.backgroundColor = OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle)
        let cancelView = OWCancelView(viewModel: viewModel.outputs.cancelViewViewModel)
        view.addSubview(cancelView)
        cancelView.OWSnp.makeConstraints { make in
            make.top.equalToSuperviewSafeArea()
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    func setupObservers() {
        self.setupStatusBarStyleUpdaterObservers()
    }
}
