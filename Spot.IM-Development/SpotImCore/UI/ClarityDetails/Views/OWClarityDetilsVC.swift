//
//  OWClarityDetilsVC.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 22/08/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class OWClarityDetilsVC: UIViewController, OWStatusBarStyleUpdaterProtocol {
    fileprivate struct Metrics {
        static let closeButtonSize: CGFloat = 40
        static let closeButtonIdentidier = "clarity_details_close_button_id"
    }

    fileprivate lazy var clarityDetailsView: OWClarityDetailsView = {
        return OWClarityDetailsView(viewModel: viewModel.outputs.clarityDetailsViewViewModel)
    }()

    fileprivate lazy var closeButton: UIButton = {
        return UIButton()
            .image(UIImage(spNamed: "closeCrossIcon", supportDarkMode: true), state: .normal)
            .contentMode(.center)
    }()

    fileprivate let viewModel: OWClarityDetailsViewModeling
    let disposeBag: DisposeBag = DisposeBag()

    init(viewModel: OWClarityDetailsViewModeling) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)

        setupViews()
        setupObservers()
        applyAccessibility()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

fileprivate extension OWClarityDetilsVC {
    func setupViews() {
        self.title = "Awaiting Review" // TODO: from VM according to type
        let navControllerCustomizer = OWSharedServicesProvider.shared.navigationControllerCustomizer()
        if navControllerCustomizer.isLargeTitlesEnabled() {
            self.navigationItem.largeTitleDisplayMode = .always
        }
        setupNavControllerSettings()
        
        view.backgroundColor = OWColorPalette.shared.color(type: .backgroundColor4, themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle)

        view.addSubview(clarityDetailsView)
        clarityDetailsView.OWSnp.makeConstraints { make in
            make.top.equalToSuperviewSafeArea()
            make.leading.trailing.bottom.equalToSuperview()
        }

        closeButton.OWSnp.makeConstraints { make in
            make.size.equalTo(Metrics.closeButtonSize)
        }
    }

    func setupNavControllerSettings() {
        // Setup close button
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: closeButton)

        // Hide navigation back button
        navigationItem.setHidesBackButton(true, animated: false)

        // Disable navigation back by swipe
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }

    func setupObservers() {
        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }
                self.view.backgroundColor = OWColorPalette.shared.color(type: .backgroundColor4, themeStyle: currentStyle)
                self.closeButton.image(UIImage(spNamed: "closeCrossIcon", supportDarkMode: true), state: .normal)
            })
            .disposed(by: disposeBag)

        self.setupStatusBarStyleUpdaterObservers()

//        closeButton.rx.tap
//            .bind(to: viewModel.outputs.reportReasonViewViewModel.inputs.cancelReportReasonTap)
//            .disposed(by: disposeBag)
    }

    func applyAccessibility() {
        closeButton.accessibilityIdentifier = Metrics.closeButtonIdentidier
    }
}
