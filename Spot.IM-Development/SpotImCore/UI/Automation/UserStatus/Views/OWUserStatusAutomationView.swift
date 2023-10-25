//
//  OWUserStatusAutomationView.swift
//  SpotImCore
//
//  Created by Alon Haiut on 26/10/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

#if AUTOMATION

import UIKit
import RxSwift
import RxCocoa

class OWUserStatusAutomationView: UIView {

    fileprivate struct Metrics { }

    fileprivate let disposeBag = DisposeBag()

    fileprivate var viewModel: OWUserStatusAutomationViewViewModeling!

    init(viewModel: OWUserStatusAutomationViewViewModeling) {
        super.init(frame: .zero)
        self.viewModel = viewModel

        setupUI()
        setupObservers()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate extension OWUserStatusAutomationView {
    func setupUI() {

    }

    func setupObservers() {

    }
}

#endif
