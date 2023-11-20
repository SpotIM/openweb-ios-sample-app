//
//  OWSubmittedVC.swift
//  SpotImCore
//
//  Created by Refael Sommer on 16/04/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class OWSubmittedVC: UIViewController, OWStatusBarStyleUpdaterProtocol {
    let submittedViewViewModel: OWSubmittedViewViewModeling
    let disposeBag = DisposeBag()

    fileprivate lazy var submittedView: OWSubmittedView = {
        return OWSubmittedView(viewModel: submittedViewViewModel)
    }()

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(submittedViewViewModel: OWSubmittedViewViewModeling) {
        self.submittedViewViewModel = submittedViewViewModel
        super.init(nibName: nil, bundle: nil)
    }

    override func loadView() {
        super.loadView()
        setupViews()
        setupObservers()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return OWSharedServicesProvider.shared.statusBarStyleService().currentStyle
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return OWManager.manager.helpers.orientationEnforcement.interfaceOrientationMask
    }
}

fileprivate extension OWSubmittedVC {
    func setupViews() {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        view.backgroundColor = OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle)
        view.addSubview(submittedView)
        submittedView.OWSnp.makeConstraints { make in
            make.top.equalToSuperviewSafeArea()
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    func setupObservers() {
        self.setupStatusBarStyleUpdaterObservers()
    }
}
