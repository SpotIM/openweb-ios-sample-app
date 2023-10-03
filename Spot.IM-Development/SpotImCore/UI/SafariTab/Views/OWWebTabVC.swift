//
//  OWSafariViewController.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 09/11/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import UIKit
import SafariServices

class OWWebTabVC: UIViewController {
    private let viewModel: OWWebTabViewModeling

    fileprivate lazy var safariTabView: OWWebTabView = {
        return OWWebTabView(viewModel: self.viewModel.outputs.webTabViewVM)
    }()

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(viewModel: OWWebTabViewModeling) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.inputs.viewDidLoad.onNext()
    }

    override func loadView() {
        super.loadView()
        setupUI()
    }
}

fileprivate extension OWWebTabVC {
    func setupUI() {
        self.title = viewModel.outputs.options.title
        self.navigationItem.largeTitleDisplayMode = .never
        self.view.addSubview(safariTabView)
        safariTabView.OWSnp.makeConstraints { make in
            make.top.equalToSuperviewSafeArea()
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}
