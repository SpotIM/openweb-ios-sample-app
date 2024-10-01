//
//  OWTestingRxTableViewAnimationsView.swift
//  OpenWebSDK
//
//  Created by Alon Haiut on 25/04/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

#if BETA

import UIKit
import RxSwift
import RxCocoa

class OWTestingRxTableViewAnimationsView: UIView {

    private struct Metrics {
        static let horizontalMargin: CGFloat = 15.0
        static let tableViewAnimationDuration: Double = 0.25 // 0.1 is equal to 100 ms
    }

    private let disposeBag = DisposeBag()

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
            .backgroundColor(UIColor.clear)
            .separatorStyle(.none)

        tableView.allowsSelection = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 130

        // Register cells
        for option in OWTestingRxTableViewCellOption.allCases {
            tableView.register(cellClass: option.cellClass)
        }

        return tableView
    }()

    private lazy var tableViewDataDataSource: OWRxTableViewSectionedAnimatedDataSource<OWTestingRxDataSourceModel> = {
        let dataSource = OWRxTableViewSectionedAnimatedDataSource<OWTestingRxDataSourceModel>(configureCell: { [weak self] _, tableView, indexPath, item -> UITableViewCell in
            guard let self = self else { return UITableViewCell() }

            let cell = tableView.dequeueReusableCellAndReigsterIfNeeded(cellClass: item.cellClass, for: indexPath)
            cell.configure(with: item.viewModel)

            return cell
        })

        let animationConfiguration = OWAnimationConfiguration(insertAnimation: .top, reloadAnimation: .fade, deleteAnimation: .bottom)
        dataSource.animationConfiguration = animationConfiguration
        return dataSource
    }()

    private lazy var cellsGeneratorView: UIStackView = {
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

    private lazy var redCellsGenerator: OWTestingCellsGenerator = {
        return OWTestingCellsGenerator(viewModel: viewModel.outputs.redCellsGeneratorVM)
    }()

    private lazy var blueCellsGenerator: OWTestingCellsGenerator = {
        return OWTestingCellsGenerator(viewModel: viewModel.outputs.blueCellsGeneratorVM)
    }()

    private lazy var greenCellsGenerator: OWTestingCellsGenerator = {
        return OWTestingCellsGenerator(viewModel: viewModel.outputs.greenCellsGeneratorVM)
    }()

    private var viewModel: OWTestingRxTableViewAnimationsViewViewModeling!

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

private extension OWTestingRxTableViewAnimationsView {
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

        viewModel.outputs.performTableViewAnimation
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                UIView.animate(withDuration: Metrics.tableViewAnimationDuration) {
                    self.tableView.beginUpdates()
                    self.tableView.endUpdates()
                }
            })
            .disposed(by: disposeBag)
    }
}

#endif
