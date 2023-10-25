//
//  OWFontsAutomationView.swift
//  SpotImCore
//
//  Created by Alon Haiut on 26/10/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

#if AUTOMATION

import UIKit
import RxSwift
import RxCocoa

class OWFontsAutomationView: UIView {

    fileprivate struct Metrics { }

    fileprivate let disposeBag = DisposeBag()

    fileprivate var viewModel: OWFontsAutomationViewViewModeling!

    init(viewModel: OWFontsAutomationViewViewModeling) {
        super.init(frame: .zero)
        self.viewModel = viewModel

        setupUI()
        setupObservers()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate extension OWFontsAutomationView {
    func setupUI() {

    }

    func setupObservers() {

    }
}

#endif
