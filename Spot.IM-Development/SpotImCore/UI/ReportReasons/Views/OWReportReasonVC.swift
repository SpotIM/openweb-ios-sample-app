//
//  OWReportReasonVC.swift
//  SpotImCore
//
//  Created by Refael Sommer on 17/04/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

#if NEW_API

class OWReportReasonVC: UIViewController {
    fileprivate struct Metrics {

    }

    fileprivate let viewModel: OWReportReasonViewModeling
    fileprivate let disposeBag = DisposeBag()

    fileprivate lazy var reportReasonView: OWReportReasonView = {
        let reportReasonView = OWReportReasonView(viewModel: viewModel.outputs.reportReasonViewViewModel)
        return reportReasonView
    }()

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(viewModel: OWReportReasonViewModeling = OWReportReasonViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    override func loadView() {
        super.loadView()
        setupViews()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.inputs.viewDidLoad.onNext()
    }
}

fileprivate extension OWReportReasonVC {
    func setupViews() {
        view.addSubview(reportReasonView)
        reportReasonView.OWSnp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

#endif
