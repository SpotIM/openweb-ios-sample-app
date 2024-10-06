//
//  OWTestingRxTableViewAnimationsVC.swift
//  OpenWebSDK
//
//  Created by Alon Haiut on 25/04/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

#if BETA

import UIKit

class OWTestingRxTableViewAnimationsVC: UIViewController {
    private struct Metrics { }

    private let viewModel: OWTestingRxTableViewAnimationsViewModeling

    private lazy var testingRxTableViewAnimationsView: OWTestingRxTableViewAnimationsView = {
        return OWTestingRxTableViewAnimationsView(viewModel: viewModel.outputs.viewVM)
    }()

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(viewModel: OWTestingRxTableViewAnimationsViewModeling) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    override func loadView() {
        super.loadView()
        setupUI()
    }
}

private extension OWTestingRxTableViewAnimationsVC {
    func setupUI() {
        view.addSubview(testingRxTableViewAnimationsView)
        testingRxTableViewAnimationsView.OWSnp.makeConstraints { make in
            make.top.equalToSuperviewSafeArea()
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}

#endif
