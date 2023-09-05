//
//  OWConversationView.swift
//  SpotImCore
//
//  Created by Alon Haiut on 06/07/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class OWConversationView: UIView, OWThemeStyleInjectorProtocol {
    fileprivate struct Metrics {
        static let tableViewAnimationDuration: Double = 0.25
        static let separatorHeight: CGFloat = 1
        static let conversationEmptyStateHorizontalPadding: CGFloat = 16.5
        static let tableViewRowEstimatedHeight: Double = 130.0
        static let scrollToTopThrottleDelay: DispatchTimeInterval = .milliseconds(200)
    }

    fileprivate lazy var conversationTitleHeaderView: OWConversationTitleHeaderView = {
        return OWConversationTitleHeaderView(viewModel: self.viewModel.outputs.conversationTitleHeaderViewModel)
            .enforceSemanticAttribute()
    }()

    fileprivate lazy var articleDescriptionView: OWArticleDescriptionView = {
        return OWArticleDescriptionView(viewModel: self.viewModel.outputs.articleDescriptionViewModel)
            .enforceSemanticAttribute()
    }()

    fileprivate lazy var conversationSummaryView: OWConversationSummaryView = {
        return OWConversationSummaryView(viewModel: self.viewModel.outputs.conversationSummaryViewModel)
            .enforceSemanticAttribute()
    }()

    fileprivate lazy var conversationEmptyStateView: OWConversationEmptyStateView = {
        return OWConversationEmptyStateView(viewModel: self.viewModel.outputs.conversationEmptyStateViewModel)
            .enforceSemanticAttribute()
            .userInteractionEnabled(false)
    }()

    fileprivate lazy var commentingCTATopHorizontalSeparator: UIView = {
        return UIView()
            .backgroundColor(OWColorPalette.shared.color(type: .separatorColor1,
                                                         themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))
    }()

    fileprivate lazy var commentingCTAView: OWCommentingCTAView = {
        return OWCommentingCTAView(with: self.viewModel.outputs.commentingCTAViewModel)
            .enforceSemanticAttribute()
    }()

    fileprivate lazy var tableView: UITableView = {
        let tableView = UITableView()
            .enforceSemanticAttribute()
            .backgroundColor(UIColor.clear)
            .separatorStyle(.none)
        tableView.refreshControl = tableViewRefreshControl

        tableView.allowsSelection = false

        // Register cells
        for option in OWConversationCellOption.allCases {
            tableView.register(cellClass: option.cellClass)
        }

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = Metrics.tableViewRowEstimatedHeight

        return tableView
    }()

    fileprivate lazy var tableViewRefreshControl: UIRefreshControl = {
        let refresh = UIRefreshControl()
        return refresh
    }()

    fileprivate lazy var conversationDataSource: OWRxTableViewSectionedAnimatedDataSource<ConversationDataSourceModel> = {
        let dataSource = OWRxTableViewSectionedAnimatedDataSource<ConversationDataSourceModel>(decideViewTransition: { [weak self] _, _, _ in
            guard let self = self else { return .reload }
            return self.viewModel.outputs.dataSourceTransition
        }, configureCell: { [weak self] _, tableView, indexPath, item -> UITableViewCell in
            guard let self = self else { return UITableViewCell() }

            let cell = tableView.dequeueReusableCellAndReigsterIfNeeded(cellClass: item.cellClass, for: indexPath)
            cell.configure(with: item.viewModel)

            return cell
        })

        let animationConfiguration = OWAnimationConfiguration(insertAnimation: .top, reloadAnimation: .none, deleteAnimation: .fade)
        dataSource.animationConfiguration = animationConfiguration

        return dataSource
    }()

    fileprivate let viewModel: OWConversationViewViewModeling
    fileprivate let disposeBag = DisposeBag()

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(viewModel: OWConversationViewViewModeling) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        viewModel.inputs.viewInitialized.onNext()
        setupUI()
        setupObservers()
    }
}

fileprivate extension OWConversationView {
    func setupUI() {
        self.useAsThemeStyleInjector()

        let shouldShowTiTleHeader = viewModel.outputs.shouldShowTiTleHeader
        if shouldShowTiTleHeader {
            self.addSubview(conversationTitleHeaderView)
            conversationTitleHeaderView.OWSnp.makeConstraints { make in
                make.top.leading.trailing.equalToSuperview()
            }
        }

        let shouldShowArticleDescription = viewModel.outputs.shouldShowArticleDescription
        if shouldShowArticleDescription {
            self.addSubview(articleDescriptionView)
            articleDescriptionView.OWSnp.makeConstraints { make in
                if shouldShowTiTleHeader {
                    make.top.equalTo(conversationTitleHeaderView.OWSnp.bottom)
                } else {
                    make.top.equalToSuperview()
                }
                make.leading.trailing.equalToSuperview()
            }
        }

        self.addSubview(conversationSummaryView)
        conversationSummaryView.OWSnp.makeConstraints { make in
            if shouldShowArticleDescription {
                make.top.equalTo(articleDescriptionView.OWSnp.bottom)
            } else {
                if shouldShowTiTleHeader {
                    make.top.equalTo(conversationTitleHeaderView.OWSnp.bottom)
                } else {
                    make.top.equalToSuperview()
                }
            }
            make.leading.trailing.equalToSuperview()
        }

        // After building the other views, position the table view in the appropriate place
        self.addSubview(tableView)
        tableView.OWSnp.makeConstraints { make in
            make.top.equalTo(conversationSummaryView.OWSnp.bottom)
            make.leading.trailing.equalToSuperview()
        }

        // Setup bottom commentingCTA horizontal separator
        self.addSubview(commentingCTATopHorizontalSeparator)
        commentingCTATopHorizontalSeparator.OWSnp.makeConstraints { make in
            make.top.equalTo(tableView.OWSnp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(Metrics.separatorHeight)
        }

        self.addSubview(self.conversationEmptyStateView)
        self.conversationEmptyStateView.OWSnp.makeConstraints { make in
            make.top.equalTo(self.tableView.OWSnp.top)
            make.bottom.equalTo(self.commentingCTATopHorizontalSeparator.OWSnp.top)
            make.leading.trailing.equalToSuperview().inset(Metrics.conversationEmptyStateHorizontalPadding)
        }

        self.addSubview(commentingCTAView)
        commentingCTAView.OWSnp.makeConstraints { make in
            make.top.equalTo(commentingCTATopHorizontalSeparator.OWSnp.bottom)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(self.safeAreaLayoutGuide)
        }
    }

    func setupObservers() {
        viewModel.outputs.conversationDataSourceSections
            .observe(on: MainScheduler.instance)
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.tableViewRefreshControl.endRefreshing()
            })
            .bind(to: tableView.rx.items(dataSource: conversationDataSource))
            .disposed(by: disposeBag)

        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }

                self.backgroundColor = OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: currentStyle)
                self.commentingCTATopHorizontalSeparator.backgroundColor = OWColorPalette.shared.color(type: .separatorColor1, themeStyle: currentStyle)
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

        tableView.rx.willDisplayCell
            .observe(on: MainScheduler.instance)
            .bind(to: viewModel.inputs.willDisplayCell)
            .disposed(by: disposeBag)

        tableViewRefreshControl.rx.controlEvent(UIControl.Event.valueChanged)
            .flatMapLatest { [weak self] _ -> Observable<Void> in
                guard let self = self else { return .empty() }
                return self.tableView.rx.didEndDecelerating
                    .asObservable()
                    .take(1)
            }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.viewModel.inputs.pullToRefresh.onNext()
                self.tableView.setContentOffset(.zero, animated: true)
            })
            .disposed(by: disposeBag)

        viewModel.outputs.conversationDataJustReceived
            .observe(on: MainScheduler.instance)
            .throttle(Metrics.scrollToTopThrottleDelay, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .none, animated: false)
            })
            .disposed(by: disposeBag)

        tableView.rx.contentOffset
            .observe(on: MainScheduler.instance)
            .bind(to: viewModel.inputs.changeConversationOffset)
            .disposed(by: disposeBag)

        viewModel.outputs.scrollToCellIndex
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] index in
                let cellIndexPath = IndexPath(row: index, section: 0)
                guard let self = self else { return }

                CATransaction.begin()
                self.tableView.beginUpdates()
                CATransaction.setCompletionBlock {
                    // Code to be executed upon completion
                    self.viewModel.inputs.scrolledToCellIndex.onNext(index)
                }
                if (index > 0) {
                    self.tableView.scrollToRow(at: cellIndexPath, at: .top, animated: true)
                } else {
                    // it looks like set the content offset behave better when scroll to top
                    self.tableView.setContentOffset(.zero, animated: true)
                }
                self.tableView.endUpdates()
                CATransaction.commit()
            })
            .disposed(by: disposeBag)
    }
}
