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

    fileprivate let disposeBag = DisposeBag()

    fileprivate lazy var tableView: UITableView = {
        let tableView = UITableView()
            .backgroundColor(UIColor.clear)
            .separatorStyle(.none)

        tableView.allowsSelection = false

        // Register cells
        for option in OWTestingRxTableViewCellOption.allCases {
            tableView.register(cellClass: option.cellClass)
        }

        return tableView
    }()

    fileprivate lazy var tableViewDataDataSource: OWRxTableViewSectionedAnimatedDataSource<OWTestingRxDataSourceModel> = {
        let dataSource = OWRxTableViewSectionedAnimatedDataSource<OWTestingRxDataSourceModel>(configureCell: { [weak self] _, tableView, indexPath, item -> UITableViewCell in
            guard let self = self else { return UITableViewCell() }

            let cell = tableView.dequeueReusableCellAndReigsterIfNeeded(cellClass: item.cellClass, for: indexPath)
            cell.configure(with: item.viewModel)

            return cell
        })

        let animationConfiguration = OWAnimationConfiguration(insertAnimation: .top, reloadAnimation: .none, deleteAnimation: .bottom)
        dataSource.animationConfiguration = animationConfiguration
        return dataSource
    }()

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

        addSubview(tableView)
        tableView.OWSnp.makeConstraints { make in
            make.top.equalTo(cellsGeneratorView.OWSnp.bottom)
            make.bottom.leading.trailing.equalToSuperview()
        }
    }

    func setupObservers() {
        viewModel.outputs.cellsDataSourceSections
            .bind(to: tableView.rx.items(dataSource: tableViewDataDataSource))
            .disposed(by: disposeBag)

//        viewModel.outputs.updateCellSizeAtIndex
//            .observe(on: MainScheduler.instance)
//            .subscribe(onNext: { [weak self] index in
//                guard let self = self else { return }
//                self.tableView.reloadItemsAtIndexPaths([IndexPath(row: index, section: 0)], animationStyle: .none)
//            })
//            .disposed(by: disposeBag)
    }
}

#endif
