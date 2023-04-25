//
//  OWTestingRxTableViewAnimationsView.swift
//  SpotImCore
//
//  Created by Alon Haiut on 25/04/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

#if BETA

import UIKit
import RxSwift
import RxCocoa

class OWTestingRxTableViewAnimationsView: UIView {

    fileprivate struct Metrics {
        static let cellsGeneratorViewHeight: CGFloat = 60.0
        static let horizontalMargin: CGFloat = 15.0
    }

    fileprivate lazy var cellsGeneratorView: UIView = {
        return UIView()
            .backgroundColor(.white)
    }()

    fileprivate var viewModel: OWTestingRxTableViewAnimationsViewViewModeling!

    init(viewModel: OWTestingRxTableViewAnimationsViewViewModeling) {
        super.init(frame: .zero)
        self.viewModel = viewModel

        setupUI()
        setupObservers()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate extension OWTestingRxTableViewAnimationsView {
    func setupUI() {
        self.backgroundColor = .white

    }

    func setupObservers() {

    }
}

#endif
