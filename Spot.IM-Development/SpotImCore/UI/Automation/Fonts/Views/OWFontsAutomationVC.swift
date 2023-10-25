//
//  OWFontsAutomationVC.swift
//  SpotImCore
//
//  Created by Alon Haiut on 26/10/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

#if AUTOMATION

import UIKit

class OWFontsAutomationVC: UIViewController {
    fileprivate struct Metrics { }

    fileprivate let viewModel: OWFontsAutomationViewModeling

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
}

fileprivate extension OWFontsAutomationVC {
    func setupUI() {
        view.addSubview(fontsAutomationView)
        fontsAutomationView.OWSnp.makeConstraints { make in
            make.top.equalToSuperviewSafeArea()
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}

#endif
