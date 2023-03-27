//
//  OWCommentThreadView.swift
//  SpotImCore
//
//  Created by Alon Shprung on 30/01/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class OWCommentThreadView: UIView, OWThemeStyleInjectorProtocol {
    fileprivate struct Metrics {
        static let horizontalOffset: CGFloat = 16.0

        static let identifier = "comment_thread_view_id"
    }

    fileprivate lazy var commentThreadDataSource: OWRxTableViewSectionedAnimatedDataSource<CommentThreadDataSourceModel> = {
        let dataSource = OWRxTableViewSectionedAnimatedDataSource<CommentThreadDataSourceModel>(configureCell: { [weak self] _, tableView, indexPath, item -> UITableViewCell in
            guard let self = self else { return UITableViewCell() }

            let cell = tableView.dequeueReusableCellAndReigsterIfNeeded(cellClass: item.cellClass, for: indexPath)
            cell.configure(with: item.viewModel)

            return cell
        })

        let animationConfiguration = OWAnimationConfiguration(insertAnimation: .top, reloadAnimation: .none, deleteAnimation: .fade)
        dataSource.animationConfiguration = animationConfiguration
        return dataSource
    }()

    fileprivate lazy var tableView: UITableView = {
        let tableView = UITableView()
            .enforceSemanticAttribute()
            .backgroundColor(UIColor.white)
            .separatorStyle(.none)

        tableView.allowsSelection = false

        // Register cells
        for option in OWCommentThreadCellOption.allCases {
            tableView.register(cellClass: option.cellClass)
        }

        return tableView
    }()

    fileprivate let viewModel: OWCommentThreadViewViewModeling
    fileprivate let disposeBag = DisposeBag()

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(viewModel: OWCommentThreadViewViewModeling) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        viewModel.inputs.viewInitialized.onNext()
        setupViews()
        setupObservers()
        applyAccessibility()
    }
}

fileprivate extension OWCommentThreadView {
    func applyAccessibility() {
        self.accessibilityIdentifier = Metrics.identifier
    }

    func setupViews() {
        self.backgroundColor = .cyan

        self.useAsThemeStyleInjector()

        self.addSubview(tableView)
        tableView.OWSnp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    func setupObservers() {
        viewModel.outputs.commentThreadDataSourceSections
            .observe(on: MainScheduler.instance)
            .bind(to: tableView.rx.items(dataSource: commentThreadDataSource))
            .disposed(by: disposeBag)

        tableView.rx.willDisplayCell
            .observe(on: MainScheduler.instance)
            .bind(to: viewModel.inputs.willDisplayCell)
            .disposed(by: disposeBag)

        viewModel.outputs.updateCellSizeAtIndex
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: { [weak self] index in
                    guard let self = self else { return }
                    UIView.performWithoutAnimation {
                        self.tableView.reloadItemsAtIndexPaths([IndexPath(row: index, section: 0)], animationStyle: .none)
                    }
                })
                .disposed(by: disposeBag)
    }
}
