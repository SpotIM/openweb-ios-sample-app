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
        static let ctaViewSlideAnimationDelay = 50
        static let ctaViewSlideAnimationDuration: Double = 0.25
        static let separatorHeight: CGFloat = 1
        static let conversationEmptyStateHorizontalPadding: CGFloat = 16.5
        static let tableViewRowEstimatedHeight: Double = 130.0
        static let scrollToTopThrottleDelay: DispatchTimeInterval = .milliseconds(200)
        static let throttleObserveTableViewDuration = 500
        static let scrolledToTopDelay = 300
        static let realtimeIndicationAnimationViewHeight: CGFloat = 150
        static let loginPromptVerticalPadding: CGFloat = 12
    }

    fileprivate lazy var conversationTitleHeaderView: OWConversationTitleHeaderView = {
        return OWConversationTitleHeaderView(viewModel: self.viewModel.outputs.conversationTitleHeaderViewModel)
            .enforceSemanticAttribute()
    }()

    fileprivate lazy var articleDescriptionView: OWArticleDescriptionView = {
        return OWArticleDescriptionView(viewModel: self.viewModel.outputs.articleDescriptionViewModel)
            .enforceSemanticAttribute()
    }()

    fileprivate lazy var loginPromptView: OWLoginPromptView = {
        return OWLoginPromptView(with: self.viewModel.outputs.loginPromptViewModel)
    }()

    fileprivate lazy var loginPromptBottomDivider: UIView = {
        return UIView()
            .backgroundColor(OWColorPalette.shared.color(type: .separatorColor3, themeStyle: .light))
    }()

    fileprivate lazy var conversationSummaryView: OWConversationSummaryView = {
        return OWConversationSummaryView(viewModel: self.viewModel.outputs.conversationSummaryViewModel)
            .enforceSemanticAttribute()
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

    fileprivate lazy var realtimeIndicationAnimationView: OWRealtimeIndicationAnimationView = {
        return OWRealtimeIndicationAnimationView(viewModel: self.viewModel.outputs.realtimeIndicationAnimationViewModel)
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
        refresh.tintColor(OWColorPalette.shared.color(type: .separatorColor2,
                                                      themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))

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

    fileprivate var loginPromptTopConstraint: OWConstraint? = nil

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

        let shouldShowTitleHeader = viewModel.outputs.shouldShowTitleHeader
        if shouldShowTitleHeader {
            self.addSubview(conversationTitleHeaderView)
            conversationTitleHeaderView.OWSnp.makeConstraints { make in
                make.top.leading.trailing.equalToSuperview()
            }
        }

        let shouldShowArticleDescription = viewModel.outputs.shouldShowArticleDescription
        if shouldShowArticleDescription {
            self.addSubview(articleDescriptionView)
            articleDescriptionView.OWSnp.makeConstraints { make in
                if shouldShowTitleHeader {
                    make.top.equalTo(conversationTitleHeaderView.OWSnp.bottom)
                } else {
                    make.top.equalToSuperview()
                }
                make.leading.trailing.equalToSuperview()
            }
        }

        self.addSubview(loginPromptView)
        loginPromptView.OWSnp.makeConstraints { make in
            if shouldShowArticleDescription {
                loginPromptTopConstraint = make.top.equalTo(articleDescriptionView.OWSnp.bottom).offset(Metrics.loginPromptVerticalPadding).constraint
            } else if shouldShowTitleHeader {
                loginPromptTopConstraint = make.top.equalTo(conversationTitleHeaderView.OWSnp.bottom).offset(Metrics.loginPromptVerticalPadding).constraint
            } else {
                loginPromptTopConstraint = make.top.equalToSuperview().offset(Metrics.loginPromptVerticalPadding).constraint
            }
            make.centerX.equalToSuperview()
        }

        self.addSubview(loginPromptBottomDivider)
        loginPromptBottomDivider.OWSnp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(loginPromptView.OWSnp.bottom).offset(Metrics.loginPromptVerticalPadding)
            make.height.equalTo(Metrics.separatorHeight)
        }

        self.addSubview(conversationSummaryView)
        conversationSummaryView.OWSnp.makeConstraints { make in
            make.top.equalTo(loginPromptBottomDivider.OWSnp.bottom)
            make.leading.trailing.equalToSuperview()
        }

        // After building the other views, position the table view in the appropriate place
        self.addSubview(tableView)
        tableView.OWSnp.makeConstraints { make in
            make.top.equalTo(conversationSummaryView.OWSnp.bottom)
            make.leading.trailing.equalToSuperview()
        }

        self.addSubview(commentingCTAView)
        commentingCTAView.OWSnp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(self.safeAreaLayoutGuide).offset(0)
        }

        // Setup bottom commentingCTA horizontal separator
        self.addSubview(commentingCTATopHorizontalSeparator)
        commentingCTATopHorizontalSeparator.OWSnp.makeConstraints { make in
            make.top.equalTo(tableView.OWSnp.bottom)
            make.bottom.equalTo(commentingCTAView.OWSnp.top)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(Metrics.separatorHeight)
        }

        self.addSubview(self.realtimeIndicationAnimationView)
        realtimeIndicationAnimationView.OWSnp.makeConstraints { make in
            make.bottom.equalTo(self.tableView.OWSnp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(Metrics.realtimeIndicationAnimationViewHeight)
        }
    }

    // swiftlint:disable function_body_length
    func setupObservers() {
        viewModel.outputs.shouldShowErrorLoadingComments
            .delay(.milliseconds(Metrics.ctaViewSlideAnimationDelay), scheduler: MainScheduler.instance)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] shouldShowErrorLoadingComments in
                guard let self = self else { return }
                self.commentingCTAView.OWSnp.updateConstraints { make in
                    if shouldShowErrorLoadingComments {
                        let bottomPadding: CGFloat = self.window?.safeAreaInsets.bottom ?? 0
                        make.bottom.equalTo(self.safeAreaLayoutGuide).offset(self.commentingCTAView.frame.size.height + bottomPadding)
                    } else {
                        make.bottom.equalTo(self.safeAreaLayoutGuide).offset(0)
                    }
                }
                UIView.animate(withDuration: Metrics.ctaViewSlideAnimationDuration) {
                    self.layoutIfNeeded()
                }
            })
            .disposed(by: disposeBag)

        tableView.rx.observe(CGRect.self, #keyPath(UITableView.bounds))
            .unwrap()
            .map { $0.size.height }
            .bind(to: viewModel.inputs.tableViewHeight)
            .disposed(by: disposeBag)

        tableView.rx.observe(CGPoint.self, #keyPath(UITableView.contentOffset))
            .throttle(.milliseconds(Metrics.throttleObserveTableViewDuration), scheduler: MainScheduler.instance)
            .unwrap()
            .map { $0.y }
            .bind(to: viewModel.inputs.tableViewContentOffsetY)
            .disposed(by: disposeBag)

        tableView.rx.observe(CGSize.self, #keyPath(UITableView.contentSize))
            .throttle(.milliseconds(Metrics.throttleObserveTableViewDuration), scheduler: MainScheduler.instance)
            .unwrap()
            .map { $0.height }
            .bind(to: viewModel.inputs.tableViewContentSizeHeight)
            .disposed(by: disposeBag)

        viewModel.outputs.conversationDataSourceSections
            .observe(on: MainScheduler.instance)
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.tableViewRefreshControl.endRefreshing()
            })
            .bind(to: tableView.rx.items(dataSource: conversationDataSource))
            .disposed(by: disposeBag)

        viewModel.outputs.loginPromptViewModel
                .outputs.shouldShowView
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: { [weak self] shouldShow in
                    guard let self = self,
                          let topConstraint = self.loginPromptTopConstraint else { return }
                    topConstraint.update(offset: shouldShow ? Metrics.loginPromptVerticalPadding : 0)
                    self.loginPromptBottomDivider.OWSnp.updateConstraints { make in
                        make.top.equalTo(self.loginPromptView.OWSnp.bottom).offset(shouldShow ? Metrics.loginPromptVerticalPadding : 0)
                        make.height.equalTo(shouldShow ? Metrics.separatorHeight : 0)
                    }
                })
                .disposed(by: disposeBag)

        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }

                self.backgroundColor = OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: currentStyle)
                self.commentingCTATopHorizontalSeparator.backgroundColor = OWColorPalette.shared.color(type: .separatorColor1, themeStyle: currentStyle)
                self.tableViewRefreshControl.tintColor = OWColorPalette.shared.color(type: .separatorColor2, themeStyle: currentStyle)
                self.loginPromptBottomDivider.backgroundColor = OWColorPalette.shared.color(type: .separatorColor3, themeStyle: currentStyle)
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

        viewModel.outputs.updateTableViewInstantly
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.tableView.reloadData()
                self.tableView.layoutIfNeeded()
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

        viewModel.outputs.scrollToTopAnimated
        // filter only when animated = false
            .filter { !$0 }
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

        viewModel.outputs.scrollToTopAnimated
        // filter only when animated = true
            .filter { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.tableView.beginUpdates()
                // it looks like set the content offset behave better when scroll to top
                self.tableView.setContentOffset(.zero, animated: true)
                self.tableView.endUpdates()
            })
            .disposed(by: disposeBag)

        viewModel.outputs.scrollToTopAnimated
        // filter only when animated = true
            .filter { $0 }
            .voidify()
            .delay(.milliseconds(Metrics.scrolledToTopDelay), scheduler: MainScheduler.instance)
            .observe(on: MainScheduler.instance)
            .bind(to: viewModel.inputs.scrolledToTop)
            .disposed(by: disposeBag)

        viewModel.outputs.scrollToCellIndex
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] index in
                guard let self = self else { return }
                let cellIndexPath = IndexPath(row: index, section: 0)
                self.tableView.scrollToRow(at: cellIndexPath, at: .top, animated: true)
            })
            .disposed(by: disposeBag)

        viewModel.outputs.reloadCellIndex
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] index in
                guard let self = self else { return }
                self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
            })
            .disposed(by: disposeBag)
    }
    // swiftlint:enable function_body_length
}
