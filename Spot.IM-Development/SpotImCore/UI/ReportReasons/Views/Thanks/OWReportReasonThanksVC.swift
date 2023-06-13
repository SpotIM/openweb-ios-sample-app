//
//  OWReportReasonThanksVC.swift
//  SpotImCore
//
//  Created by Refael Sommer on 16/04/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class OWReportReasonThanksVC: UIViewController {
    fileprivate struct Metrics { }

    let reportReasonThanksViewViewModel: OWReportReasonThanksViewViewModeling

    fileprivate lazy var reportReasonThanksView: OWReportReasonThanksView = {
        return OWReportReasonThanksView(viewModel: reportReasonThanksViewViewModel)
    }()

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(reportReasonThanksViewViewModel: OWReportReasonThanksViewViewModeling) {
        self.reportReasonThanksViewViewModel = reportReasonThanksViewViewModel
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

fileprivate extension OWReportReasonThanksVC {
    func setupViews() {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        view.backgroundColor = OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle)
        view.addSubview(reportReasonThanksView)
        reportReasonThanksView.OWSnp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
