//
//  OWAdditionalInfoVC.swift
//  SpotImCore
//
//  Created by Refael Sommer on 01/05/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class OWAdditionalInfoVC: UIViewController, OWStatusBarStyleUpdaterProtocol {
    fileprivate let additionalInfoViewViewModel: OWAdditionalInfoViewViewModeling
    let disposeBag = DisposeBag()

    fileprivate lazy var additionalInfoView: OWAdditionalInfoView = {
        return OWAdditionalInfoView(viewModel: additionalInfoViewViewModel)
    }()

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(additionalInfoViewViewModel: OWAdditionalInfoViewViewModeling) {
        self.additionalInfoViewViewModel = additionalInfoViewViewModel
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
}

fileprivate extension OWAdditionalInfoVC {
    func setupViews() {
        self.title = additionalInfoViewViewModel.outputs.titleText
        self.navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle)
        view.addSubview(additionalInfoView)
        additionalInfoView.OWSnp.makeConstraints { make in
            make.top.equalToSuperviewSafeArea()
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    func setupObservers() {
        self.setupStatusBarStyleUpdaterObservers()
    }
}
