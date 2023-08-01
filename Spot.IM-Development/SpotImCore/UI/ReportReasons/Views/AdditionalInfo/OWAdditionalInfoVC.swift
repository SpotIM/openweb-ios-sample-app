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

class OWAdditionalInfoVC: UIViewController {
    fileprivate let additionalInfoViewViewModel: OWAdditionalInfoViewViewModeling
    fileprivate let disposeBag = DisposeBag()

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
}

fileprivate extension OWAdditionalInfoVC {
    func setupViews() {
        self.title = additionalInfoViewViewModel.outputs.titleText
        view.backgroundColor = OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle)
        view.addSubview(additionalInfoView)
        additionalInfoView.OWSnp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    func setupObservers() {
        OWSharedServicesProvider.shared.statusBarStyleService()
            .forceStatusBarUpdate
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.setNeedsStatusBarAppearanceUpdate()
            })
            .disposed(by: disposeBag)
    }
}
