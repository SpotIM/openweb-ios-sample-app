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

class OWReportReasonCancelVC: UIViewController {
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate let viewModel: OWReportReasonCancelViewModeling

    init(reportReasonCancelViewModel: OWReportReasonCancelViewModeling) {
        self.viewModel = reportReasonCancelViewModel
        super.init(nibName: nil, bundle: nil)
    }

    override func loadView() {
        super.loadView()
        setupViews()
    }
}

fileprivate extension OWReportReasonCancelVC {
    func setupViews() {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        view.backgroundColor = OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle)
        let reportReasonCancelView = OWReportReasonCancelView(viewModel: viewModel.outputs.reportReasonCancelViewViewModel)
        view.addSubview(reportReasonCancelView)
        reportReasonCancelView.OWSnp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
