//
//  OWUserStatusAutomationVC.swift
//  SpotImCore
//
//  Created by Alon Haiut on 26/10/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

#if AUTOMATION

import UIKit

class OWUserStatusAutomationVC: UIViewController {
    fileprivate struct Metrics { }

    fileprivate let viewModel: OWUserStatusAutomationViewModeling

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
}

fileprivate extension OWUserStatusAutomationVC {
    func setupUI() {
        view.addSubview(userStatusAutomationView)
        userStatusAutomationView.OWSnp.makeConstraints { make in
            make.top.equalToSuperviewSafeArea()
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}

#endif
