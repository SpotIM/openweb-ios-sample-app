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
    fileprivate struct Metrics {
        static let closeButtonSize: CGFloat = 40
        static let closeButtonIdentidier = "clarity_details_close_button_id"
    }

    fileprivate lazy var clarityDetailsView: OWClarityDetailsView = {
        return OWClarityDetailsView(viewModel: viewModel.outputs.clarityDetailsViewViewModel)
    }()

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

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}

fileprivate extension OWClarityDetailsVC {
    func setupViews() {
        view.backgroundColor = OWColorPalette.shared.color(type: .backgroundColor4, themeStyle: .light)

        view.addSubview(clarityDetailsView)
        clarityDetailsView.OWSnp.makeConstraints { make in
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
