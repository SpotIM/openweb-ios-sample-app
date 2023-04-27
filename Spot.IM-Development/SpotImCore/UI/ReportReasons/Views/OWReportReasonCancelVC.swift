//
//  OWReportReasonCancelVC.swift
//  SpotImCore
//
//  Created by Refael Sommer on 24/04/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

#if NEW_API

class OWReportReasonCancelVC: UIViewController {
    fileprivate struct Metrics {
    }

    let reportReasonCancelViewViewModel: OWReportReasonCancelViewViewModeling

    fileprivate lazy var reportReasonCancelView: OWReportReasonCancelView = {
        let reportReasonCancelView = OWReportReasonCancelView(viewModel: reportReasonCancelViewViewModel)
        return reportReasonCancelView
    }()

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(reportReasonCancelViewViewModel: OWReportReasonCancelViewViewModeling) {
        self.reportReasonCancelViewViewModel = reportReasonCancelViewViewModel
        super.init(nibName: nil, bundle: nil)
    }

    override func loadView() {
        super.loadView()
        setupViews()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

fileprivate extension OWReportReasonCancelVC {
    func setupViews() {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        view.backgroundColor = OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle)
        view.addSubview(reportReasonCancelView)
        reportReasonCancelView.OWSnp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

#endif
