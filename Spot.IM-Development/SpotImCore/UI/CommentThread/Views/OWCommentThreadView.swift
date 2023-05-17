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
        static let tableViewAnimationDuration: Double = 0.25
        static let identifier = "comment_thread_view_id"

        static let highlightScrollAnimationDuration: Double = 0.5
        static let highlightBackgroundColorAnimationDuration: Double = 0.5
        static let highlightBackgroundColorAnimationDelay: Double = 1.0
        static let highlightBackgroundColorAlpha: Double = 0.2
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
            .backgroundColor(OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: .light))
            .separatorStyle(.none)

        tableView.refreshControl = tableViewRefreshControl

        tableView.allowsSelection = false

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 130

        // Register cells
        for option in OWCommentThreadCellOption.allCases {
            tableView.register(cellClass: option.cellClass)
        }

        return tableView
    }()

    fileprivate lazy var tableViewRefreshControl: UIRefreshControl = {
        let refresh = UIRefreshControl()
        return refresh
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
        self.useAsThemeStyleInjector()

        self.addSubview(tableView)
        tableView.OWSnp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    func setupObservers() {
        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }
                self.tableView.backgroundColor = OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: currentStyle)
            })
            .disposed(by: disposeBag)

        viewModel.outputs.commentThreadDataSourceSections
            .observe(on: MainScheduler.instance)
            .do(onNext: { [weak self] _ in
                self?.tableViewRefreshControl.endRefreshing()
            })
            .bind(to: tableView.rx.items(dataSource: commentThreadDataSource))
            .disposed(by: disposeBag)

        tableView.rx.didEndDecelerating
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self, self.tableViewRefreshControl.isRefreshing else { return }
                self.viewModel.inputs.pullToRefresh.onNext()
            })
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

        viewModel.outputs.highlightCellIndex
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: { [weak self] index in
                    let cellIndexPath = IndexPath(row: index, section: 0)
                    guard let self = self, let cell = self.tableView.cellForRow(at: cellIndexPath) else { return }
                    let prevBackgroundColor = cell.backgroundColor
                    UIView.animate(withDuration: Metrics.highlightScrollAnimationDuration, animations: {
                        self.tableView.scrollToRow(at: cellIndexPath, at: .middle, animated: false)
                    }) { _ in
                        UIView.animate(withDuration: Metrics.highlightBackgroundColorAnimationDuration, animations: {
                            cell.backgroundColor = OWColorPalette.shared.color(
                                type: .brandColor,
                                themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle
                            ).withAlphaComponent(Metrics.highlightBackgroundColorAlpha)
                        }) { _ in
                            UIView.animate(withDuration: Metrics.highlightBackgroundColorAnimationDuration, delay: Metrics.highlightBackgroundColorAnimationDelay) {
                                cell.backgroundColor = prevBackgroundColor
                            }
                        }
                    }
                })
                .disposed(by: disposeBag)
    }
}
