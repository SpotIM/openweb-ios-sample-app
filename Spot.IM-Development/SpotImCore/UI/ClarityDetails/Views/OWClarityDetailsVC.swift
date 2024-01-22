//
//  OWClarityDetailsVC.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 22/08/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class OWClarityDetailsVC: UIViewController {
    fileprivate lazy var clarityDetailsView: OWClarityDetailsView = {
        return OWClarityDetailsView(viewModel: viewModel.outputs.clarityDetailsViewViewModel)
    }()

    fileprivate weak var dismissNavigationController: UINavigationController?

    fileprivate let viewModel: OWClarityDetailsViewModeling
    let disposeBag: DisposeBag = DisposeBag()

    init(viewModel: OWClarityDetailsViewModeling) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)

        setupViews()
        setupObservers()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.inputs.viewDidLoad.onNext()
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        // If modalPresentationStyle is pageSheet and animated by pulling down the VC
        // we want to bring back the navigation bar after the VC is dismissed
        // Fixes navigation bar showing over title bar.
        if modalPresentationStyle == .pageSheet && animated {
            dismissNavigationController = navigationController
        } else {
            navigationController?.setNavigationBarHidden(false, animated: animated)
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        dismissNavigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return OWSharedServicesProvider.shared.orientationService().interfaceOrientationMask
    }
}

fileprivate extension OWClarityDetailsVC {
    func setupViews() {
        view.backgroundColor = OWColorPalette.shared.color(type: .backgroundColor4, themeStyle: .light)

        view.addSubview(clarityDetailsView)
        clarityDetailsView.OWSnp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperviewSafeArea()
            make.bottom.equalToSuperview()
        }
    }

    func setupObservers() {
        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }
                self.view.backgroundColor = OWColorPalette.shared.color(type: .backgroundColor4, themeStyle: currentStyle)
            })
            .disposed(by: disposeBag)
    }
}
