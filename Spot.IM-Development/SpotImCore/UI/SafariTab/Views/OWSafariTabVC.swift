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

class OWSafariTabVC: UIViewController {
    private let viewModel: OWSafariTabViewModeling

    fileprivate lazy var safariTabView: OWSafariTabView = {
        return OWSafariTabView(viewModel: self.viewModel.outputs.safariTabViewVM)
    }()

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(viewModel: OWSafariTabViewModeling) {
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

fileprivate extension OWSafariTabVC {
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
