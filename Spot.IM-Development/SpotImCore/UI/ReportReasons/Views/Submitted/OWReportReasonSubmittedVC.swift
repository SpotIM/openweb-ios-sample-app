//
//  OWReportReasonSubmittedVC.swift
//  SpotImCore
//
//  Created by Refael Sommer on 16/04/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class OWReportReasonSubmittedVC: UIViewController, OWStatusBarStyleUpdaterProtocol {
    let reportReasonSubmittedViewViewModel: OWReportReasonSubmittedViewViewModeling
    let disposeBag = DisposeBag()

    fileprivate lazy var reportReasonSubmittedView: OWReportReasonSubmittedView = {
        return OWReportReasonSubmittedView(viewModel: reportReasonSubmittedViewViewModel)
    }()

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(reportReasonSubmittedViewViewModel: OWReportReasonSubmittedViewViewModeling) {
        self.reportReasonSubmittedViewViewModel = reportReasonSubmittedViewViewModel
        super.init(nibName: nil, bundle: nil)
    }

    override func loadView() {
        super.loadView()
        setupViews()
        setupObservers()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return OWSharedServicesProvider.shared.statusBarStyleService().currentStyle
    }
}

fileprivate extension OWReportReasonSubmittedVC {
    func setupViews() {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        view.backgroundColor = OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle)
        view.addSubview(reportReasonSubmittedView)
        reportReasonSubmittedView.OWSnp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    func setupObservers() {
        self.setupStatusBarStyleUpdaterObservers()
    }
}
