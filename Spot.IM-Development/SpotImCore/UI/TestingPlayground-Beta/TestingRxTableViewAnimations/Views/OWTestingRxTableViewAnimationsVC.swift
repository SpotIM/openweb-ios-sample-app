//
//  OWTestingRxTableViewAnimationsVC.swift
//  SpotImCore
//
//  Created by Alon Haiut on 25/04/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

#if BETA

import UIKit

class OWTestingRxTableViewAnimationsVC: UIViewController {
    fileprivate struct Metrics { }

    fileprivate let viewModel: OWTestingRxTableViewAnimationsViewModeling

    fileprivate lazy var testingRxTableViewAnimationsView: OWTestingRxTableViewAnimationsView = {
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

fileprivate extension OWTestingRxTableViewAnimationsVC {
    func setupUI() {
        view.addSubview(testingRxTableViewAnimationsView)
        testingRxTableViewAnimationsView.OWSnp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

#endif
