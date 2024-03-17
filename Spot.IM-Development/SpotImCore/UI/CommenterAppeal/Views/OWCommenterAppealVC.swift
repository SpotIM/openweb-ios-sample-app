//
//  OWCommenterAppealVC.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 01/11/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class OWCommenterAppealVC: UIViewController {
    fileprivate lazy var commenterAppealView: OWCommenterAppealView = {
        return OWCommenterAppealView(viewModel: viewModel.outputs.commenterAppealViewViewModel)
    }()

    fileprivate let viewModel: OWCommenterAppealViewModeling
    let disposeBag: DisposeBag = DisposeBag()

    init(viewModel: OWCommenterAppealViewModeling) {
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
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return OWManager.manager.helpers.orientationEnforcement.interfaceOrientationMask
    }
}

fileprivate extension OWCommenterAppealVC {
    func setupViews() {
        view.backgroundColor = OWColorPalette.shared.color(type: .backgroundColor4, themeStyle: .light)

        view.addSubview(commenterAppealView)
        commenterAppealView.OWSnp.makeConstraints { make in
            make.top.equalToSuperviewSafeArea()
            make.leading.trailing.bottom.equalToSuperview()
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
