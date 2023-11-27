//
//  OWFontsAutomationVC.swift
//  SpotImCore
//
//  Created by Alon Haiut on 26/10/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

#if AUTOMATION

import UIKit
import RxSwift

class OWFontsAutomationVC: UIViewController {

    fileprivate let viewModel: OWFontsAutomationViewModeling
    fileprivate let disposeBag = DisposeBag()

    fileprivate lazy var fontsAutomationView: OWFontsAutomationView = {
        return OWFontsAutomationView(viewModel: viewModel.outputs.viewVM)
    }()

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(viewModel: OWFontsAutomationViewModeling) {
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

fileprivate extension OWFontsAutomationVC {
    func setupUI() {
        view.addSubview(fontsAutomationView)
        fontsAutomationView.OWSnp.makeConstraints { make in
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
