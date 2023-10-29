//
//  OWUserStatusAutomationVC.swift
//  SpotImCore
//
//  Created by Alon Haiut on 26/10/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

#if AUTOMATION

import UIKit
import RxSwift

class OWUserStatusAutomationVC: UIViewController {

    fileprivate let viewModel: OWUserStatusAutomationViewModeling
    fileprivate let disposeBag = DisposeBag()

    fileprivate lazy var userStatusAutomationView: OWUserStatusAutomationView = {
        return OWUserStatusAutomationView(viewModel: viewModel.outputs.viewVM)
    }()

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(viewModel: OWUserStatusAutomationViewModeling) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    override func loadView() {
        super.loadView()
        setupUI()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupObservers()
    }
}

fileprivate extension OWUserStatusAutomationVC {
    func setupUI() {
        view.addSubview(userStatusAutomationView)
        userStatusAutomationView.OWSnp.makeConstraints { make in
            make.edges.equalToSuperviewSafeArea()
        }
    }

    func setupObservers() {
        self.title = viewModel.outputs.title
        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }
                self.view.backgroundColor = OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: currentStyle)
            })
            .disposed(by: disposeBag)
    }
}

#endif
