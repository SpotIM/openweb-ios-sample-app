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

class OWReportReasonVC: UIViewController, OWStatusBarStyleUpdaterProtocol {
    fileprivate struct Metrics {
        static let closeButtonSize: CGFloat = 40

        static let closeButtonIdentidier = "report_reason_close_button_id"
        static let closeCrossIcon = "closeCrossIcon"
        static let animationTimeForLargeTitle: Double = 0.15
    }

    fileprivate let viewModel: OWReportReasonViewModeling
    let disposeBag = DisposeBag()

    fileprivate lazy var reportReasonView: OWReportReasonView = {
        let reportReasonView = OWReportReasonView(viewModel: viewModel.outputs.reportReasonViewViewModel)
        return reportReasonView
    }()

    fileprivate lazy var closeButton: UIButton = {
        let closeButton = UIButton()
            .image(UIImage(spNamed: Metrics.closeCrossIcon, supportDarkMode: true), state: .normal)
            .contentMode(.center)
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
        applyAccessibility()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.inputs.viewDidLoad.onNext()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Enable navigation back by swipe
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return OWSharedServicesProvider.shared.statusBarStyleService().currentStyle
    }
}

fileprivate extension OWReportReasonVC {
    func setupViews() {
        self.title = viewModel.outputs.title
        self.navigationItem.largeTitleDisplayMode = .always
        view.backgroundColor = OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle)
        view.addSubview(reportReasonView)
        reportReasonView.OWSnp.makeConstraints { make in
            make.top.equalToSuperviewSafeArea()
            make.leading.trailing.bottom.equalToSuperview()
        }

        closeButton.OWSnp.makeConstraints { make in
            make.size.equalTo(Metrics.closeButtonSize)
        }
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
        navController?.navigationBar.prefersLargeTitles = true

        let navigationBarBackgroundColor = OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: style)

        // Setup Title
        let navigationTitleTextAttributes = [
            NSAttributedString.Key.font: OWFontBook.shared.font(typography: .bodyContext),
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
                self.closeButton.image(UIImage(spNamed: Metrics.closeCrossIcon, supportDarkMode: true), state: .normal)
                self.setupNavControllerUI(currentStyle)
            })
            .disposed(by: disposeBag)

        self.setupStatusBarStyleUpdaterObservers()

        closeButton.rx.tap
            .bind(to: viewModel.outputs.reportReasonViewViewModel.inputs.cancelReportReasonTap)
            .disposed(by: disposeBag)

        let reportOffset = viewModel.outputs.reportReasonViewViewModel
            .outputs.reportOffset
            .share()

        let shouldShouldChangeToLargeTitleDisplay = reportOffset
            .filter { $0.y <= 0 }
            .withLatestFrom(viewModel.outputs.isLargeTitleDisplay)
            .filter { !$0 }
            .voidify()
            .map { return UINavigationItem.LargeTitleDisplayMode.always }

        let shouldShouldChangeToRegularTitleDisplay = reportOffset
            .filter { $0.y > 0 }
            .withLatestFrom(viewModel.outputs.isLargeTitleDisplay)
            .filter { $0 }
            .voidify()
            .map { return UINavigationItem.LargeTitleDisplayMode.never }

        Observable.merge(shouldShouldChangeToLargeTitleDisplay, shouldShouldChangeToRegularTitleDisplay)
            .subscribe(onNext: { [weak self] displayMode in
                guard let self = self else { return }

                let isLargeTitleGoingToBeDisplay = displayMode == .always
                self.viewModel.inputs.changeIsLargeTitleDisplay.onNext(isLargeTitleGoingToBeDisplay)
                self.navigationItem.largeTitleDisplayMode = displayMode
                UIView.animate(withDuration: Metrics.animationTimeForLargeTitle, animations: {
                    self.navigationController?.navigationBar.layoutIfNeeded()
                })
            })
            .disposed(by: disposeBag)
    }

    func applyAccessibility() {
        closeButton.accessibilityIdentifier = Metrics.closeButtonIdentidier
    }
}
