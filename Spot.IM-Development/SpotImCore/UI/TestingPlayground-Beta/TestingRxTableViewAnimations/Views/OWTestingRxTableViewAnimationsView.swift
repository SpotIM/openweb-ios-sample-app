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
        static let horizontalMargin: CGFloat = 15.0
    }

    fileprivate lazy var cellsGeneratorView: UIStackView = {
        let stack = UIStackView()
            .backgroundColor(.white)

        stack.axis = .horizontal
        stack.distribution = .fillEqually

        stack.addArrangedSubview(redCellsGenerator)
        stack.addArrangedSubview(blueCellsGenerator)
        stack.addArrangedSubview(greenCellsGenerator)

        redCellsGenerator.OWSnp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
        }

        blueCellsGenerator.OWSnp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
        }

        greenCellsGenerator.OWSnp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
        }

        return stack
    }()

    fileprivate lazy var redCellsGenerator: OWTestingCellsGenerator = {
        return OWTestingCellsGenerator(viewModel: viewModel.outputs.redCellsGeneratorVM)
    }()

    fileprivate lazy var blueCellsGenerator: OWTestingCellsGenerator = {
        return OWTestingCellsGenerator(viewModel: viewModel.outputs.blueCellsGeneratorVM)
    }()

    fileprivate lazy var greenCellsGenerator: OWTestingCellsGenerator = {
        return OWTestingCellsGenerator(viewModel: viewModel.outputs.greenCellsGeneratorVM)
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

        addSubview(cellsGeneratorView)
        cellsGeneratorView.OWSnp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

    }

    func setupObservers() {

    }
}

#endif
