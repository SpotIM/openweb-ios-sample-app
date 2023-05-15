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
        static let navigationTitleFontSize: CGFloat = 18.0
    }

    fileprivate let viewModel: OWReportReasonViewModeling
    fileprivate let disposeBag = DisposeBag()

    fileprivate lazy var reportReasonView: OWReportReasonView = {
        let reportReasonView = OWReportReasonView(viewModel: viewModel.outputs.reportReasonViewViewModel)
        return reportReasonView
    }()

    fileprivate lazy var closeButton: UIButton = {
        let closeButton = UIButton()
            .image(UIImage(spNamed: "closeCrossIcon", supportDarkMode: true), state: .normal)
            .horizontalAlignment(.left)
        return closeButton
    }()

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(viewModel: OWReportReasonViewModeling) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    override func loadView() {
        super.loadView()
        setupViews()
        setupObservers()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.inputs.viewDidLoad.onNext()
    }
}

fileprivate extension OWReportReasonVC {
    func setupViews() {
        self.title = viewModel.outputs.title
        view.backgroundColor = OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle)
        view.addSubview(reportReasonView)
        reportReasonView.OWSnp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        setupNavControllerUI()
    }

    func setupNavControllerUI(_ style: OWThemeStyle = OWSharedServicesProvider.shared.themeStyleService().currentStyle) {
        let navController = self.navigationController

        // Setup close button
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: closeButton)

        // Hide navigation back button
        navigationItem.setHidesBackButton(true, animated: false)

        // Disable navigation back by swipe
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false

        title = viewModel.outputs.title

        navController?.navigationBar.isTranslucent = false
        let navigationBarBackgroundColor = OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: style)

        // Setup Title
        let navigationTitleTextAttributes = [
            NSAttributedString.Key.font: OWFontBook.shared.font(style: .bold, size: Metrics.navigationTitleFontSize),
            NSAttributedString.Key.foregroundColor: OWColorPalette.shared.color(type: .textColor1, themeStyle: style)
        ]

        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = navigationBarBackgroundColor
            appearance.titleTextAttributes = navigationTitleTextAttributes

            // Setup Back button
            let backButtonAppearance = UIBarButtonItemAppearance(style: .plain)
            backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
            appearance.backButtonAppearance = backButtonAppearance

            navController?.navigationBar.standardAppearance = appearance
            navController?.navigationBar.scrollEdgeAppearance = navController?.navigationBar.standardAppearance
        } else {
            navController?.navigationBar.backgroundColor = navigationBarBackgroundColor
            navController?.navigationBar.titleTextAttributes = navigationTitleTextAttributes
        }
    }

    func setupObservers() {
        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }
                self.view.backgroundColor = OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: currentStyle)
                self.closeButton.image(UIImage(spNamed: "closeCrossIcon", supportDarkMode: true), state: .normal)
                self.setupNavControllerUI(currentStyle)
            })
            .disposed(by: disposeBag)

        closeButton.rx.tap
            .bind(to: viewModel.outputs.reportReasonViewViewModel.inputs.closeReportReasonTap)
            .disposed(by: disposeBag)
    }
}

#endif
