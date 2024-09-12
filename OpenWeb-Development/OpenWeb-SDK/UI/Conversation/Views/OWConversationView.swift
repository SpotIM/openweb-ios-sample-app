//
//  OWConversationView.swift
//  OpenWebSDK
//
//  Created by Alon Haiut on 06/07/2022.
//  Copyright © 2022 OpenWeb. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class OWConversationView: UIView, OWThemeStyleInjectorProtocol, OWToastNotificationPresenterProtocol {
    fileprivate struct Metrics {
        static let tableViewAnimationDuration: Double = 0.25
        static let ctaViewSlideAnimationDelay = 50
        static let ctaViewSlideAnimationDuration: Double = 0.25
        static let separatorHeight: CGFloat = 1
        static let conversationEmptyStateHorizontalPadding: CGFloat = 16.5
        static let scrollToTopThrottleDelay: DispatchTimeInterval = .milliseconds(200)
        static let throttleObserveTableViewDuration = 50
        static let scrolledToTopDelay = 300
        static let realtimeIndicationAnimationViewHeight: CGFloat = 150
        static let loginPromptOrientationChangeAnimationDuration: CGFloat = 0.3
        static let horizontalLandscapeMargin: CGFloat = 66.0
        static let horizontalPortraitMargin: CGFloat = 16.0
        static let highlightScrollAnimationDuration: Double = 0.5
        static let highlightBackgroundColorAnimationDuration: Double = 0.5
        static let highlightBackgroundColorAnimationDelay: Double = 1.0
        static let highlightBackgroundColorAlpha: Double = 0.2
        static let delayPullToRefreshDuration = 250
        static let identifier = "conversation_view_id"
        static let animateHideShowFilterTabsDuration: CGFloat = 0.3
    }

    fileprivate let conversationViewScheduler: SchedulerType = SerialDispatchQueueScheduler(qos: .userInteractive, internalSerialQueueName: "conversationViewQueue")

    var toastView: OWToastView? = nil

    fileprivate lazy var filterTabsView: OWFilterTabsView = {
        return OWFilterTabsView(viewModel: self.viewModel.outputs.filterTabsVM)
    }()

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

    fileprivate lazy var conversationSummaryView: OWConversationSummaryView = {
        return OWConversationSummaryView(viewModel: self.viewModel.outputs.conversationSummaryViewModel)
            .enforceSemanticAttribute()
    }()

    fileprivate lazy var commentingCTATopHorizontalSeparator: UIView = {
        return UIView()
            .backgroundColor(OWColorPalette.shared.color(type: .separatorColor1,
                                                         themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))
    }()

    fileprivate lazy var commentingCTAContainerView: UIView = {
        return UIView()
            .backgroundColor(OWColorPalette.shared.color(type: .backgroundColor2,
                                                         themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))
            .enforceSemanticAttribute()
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

        return tableView
    }()

    fileprivate lazy var tableViewRefreshControl: UIRefreshControl = {
        let refresh = UIRefreshControl()
        refresh.tintColor(OWColorPalette.shared.color(type: .loaderColor,
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
            OWScheduler.runOnMainThreadIfNeeded {
                cell.configure(with: item.viewModel)
            }

            return cell
        })

        let animationConfiguration = OWAnimationConfiguration(insertAnimation: .top, reloadAnimation: .none, deleteAnimation: .fade)
        dataSource.animationConfiguration = animationConfiguration

        return dataSource
    }()

    fileprivate var loginPromptPortraitConstraints: [OWConstraint] = []
    fileprivate var loginPromptLandscapeConstraints: [OWConstraint] = []
    fileprivate var summaryPortraitLeadingConstraint: OWConstraint? = nil
    fileprivate var summaryLandscapeLeadingConstraint: OWConstraint? = nil
    fileprivate var filterTabsHeightConstraint: OWConstraint? = nil

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
        applyAccessibility()
        setupObservers()
    }
}

fileprivate extension OWConversationView {
    func applyAccessibility() {
        self.accessibilityIdentifier = Metrics.identifier
    }

    func setupUI() {
        self.useAsThemeStyleInjector()

        // Adding filter tabs first so it should hide under title details.
        // Adding it later and sending it to back creates a bug with large titles.
        self.addSubview(filterTabsView)

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

        let currentOrientation = OWSharedServicesProvider.shared.orientationService().currentOrientation
        let isLandscape = currentOrientation == .landscape

        self.addSubview(loginPromptView)
        loginPromptView.OWSnp.makeConstraints { make in
            if shouldShowArticleDescription {
                make.top.equalTo(articleDescriptionView.OWSnp.bottom)
            } else if shouldShowTitleHeader {
                make.top.equalTo(conversationTitleHeaderView.OWSnp.bottom)
            } else {
                make.top.equalToSuperview()
            }
            make.leading.equalToSuperview()
            loginPromptPortraitConstraints.append(make.trailing.equalToSuperview().constraint)
            loginPromptLandscapeConstraints.append(make.trailing.equalToSuperview().multipliedBy(0.5).constraint)
        }

        self.addSubview(conversationSummaryView)
        conversationSummaryView.OWSnp.makeConstraints { make in
            let portraitLeading = make.leading.equalToSuperview().constraint
            let landscapeLeading = make.leading.equalTo(loginPromptView.OWSnp.trailing).constraint

            summaryPortraitLeadingConstraint = portraitLeading
            summaryLandscapeLeadingConstraint = landscapeLeading

            loginPromptPortraitConstraints.append(make.top.equalTo(loginPromptView.OWSnp.bottom).constraint)
            loginPromptLandscapeConstraints.append(make.top.equalTo(loginPromptView.OWSnp.top).constraint)
            make.trailing.equalToSuperview()
        }

        if currentOrientation == .portrait {
            loginPromptLandscapeConstraints.forEach { $0.deactivate() }
            loginPromptPortraitConstraints.forEach { $0.activate() }
        } else {
            loginPromptPortraitConstraints.forEach { $0.deactivate() }
            loginPromptLandscapeConstraints.forEach { $0.activate() }
        }

        filterTabsView.OWSnp.makeConstraints { make in
            make.top.equalTo(conversationSummaryView.OWSnp.bottom).offset(0)
            make.leading.trailing.equalToSuperview()
            filterTabsHeightConstraint = make.height.equalTo(0).constraint
        }
        self.viewModel.outputs.filterTabsVM
            .inputs.setMinimumLeadingTrailingMargin.onNext(isLandscape ? Metrics.horizontalLandscapeMargin : Metrics.horizontalPortraitMargin)

        // After building the other views, position the table view in the appropriate place
        self.addSubview(tableView)
        tableView.OWSnp.makeConstraints { make in
            make.top.equalTo(filterTabsView.OWSnp.bottom)
            make.leading.trailing.equalToSuperviewSafeArea()
        }

        self.addSubview(commentingCTAContainerView)
        commentingCTAContainerView.OWSnp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(0)
        }

        commentingCTAContainerView.addSubview(commentingCTAView)
        commentingCTAView.OWSnp.makeConstraints { make in
            make.leading.trailing.equalToSuperviewSafeArea().inset(self.horizontalMargin(isLandscape: currentOrientation == .landscape))
            make.top.bottom.equalToSuperview()
        }

        // Setup bottom commentingCTA horizontal separator
        self.addSubview(commentingCTATopHorizontalSeparator)
        commentingCTATopHorizontalSeparator.OWSnp.makeConstraints { make in
            make.top.equalTo(tableView.OWSnp.bottom)
            make.bottom.equalTo(commentingCTAContainerView.OWSnp.top)
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
        viewModel.outputs.displayToast
            .subscribe(onNext: { [weak self] data in
                guard var self = self else { return }
                let completions: [OWToastCompletion: PublishSubject<Void>?] = [.action: data.actionCompletion, .dismiss: self.viewModel.inputs.dismissToast]
                self.presentToast(requiredData: data.presentData.data,
                                  completions: completions,
                                  disposeBag: self.disposeBag)
            })
            .disposed(by: disposeBag)

        viewModel.outputs.hideToast
            .subscribe(onNext: { [weak self] in
                self?.dismissToast()
            })
            .disposed(by: disposeBag)

        viewModel.outputs.shouldShowFilterTabsView
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] shouldShowFilterTabsView in
                OWScheduler.runOnMainThreadIfNeeded {
                    guard let self = self else { return }
                    if let filterTabsHeightConstraint = self.filterTabsHeightConstraint,
                       filterTabsHeightConstraint.isActive,
                       shouldShowFilterTabsView {
                        filterTabsHeightConstraint.isActive = false
                    }
                    let filterTabsHeight = self.filterTabsView.frame.size.height
                    let offset: CGFloat = shouldShowFilterTabsView ? 0 : filterTabsHeight
                    self.filterTabsView.OWSnp.updateConstraints { make in
                        make.top.equalTo(self.conversationSummaryView.OWSnp.bottom).offset(-offset)
                    }
                    UIView.animate(withDuration: Metrics.animateHideShowFilterTabsDuration) {
                        self.layoutSubviews()
                    }
                }
            })
            .disposed(by: disposeBag)

        viewModel.outputs.shouldShowErrorLoadingComments
            .delay(.milliseconds(Metrics.ctaViewSlideAnimationDelay), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] shouldShowErrorLoadingComments in
                OWScheduler.runOnMainThreadIfNeeded {
                    guard let self = self else { return }
                    self.commentingCTAContainerView.OWSnp.updateConstraints { make in
                        if shouldShowErrorLoadingComments {
                            let bottomPadding: CGFloat = self.window?.safeAreaInsets.bottom ?? 0
                            make.bottom.equalToSuperview().offset(self.commentingCTAView.frame.size.height + bottomPadding)
                        } else {
                            make.bottom.equalToSuperview().offset(0)
                        }
                    }
                    UIView.animate(withDuration: Metrics.ctaViewSlideAnimationDuration) {
                        self.layoutIfNeeded()
                    }
                }
            })
            .disposed(by: disposeBag)

        tableView.rx.observe(CGRect.self, #keyPath(UITableView.bounds))
            .unwrap()
            .map { $0.size }
            .bind(to: viewModel.inputs.tableViewSize)
            .disposed(by: disposeBag)

        tableView.rx.willBeginDragging
            .map { [weak self] _ in
                return self?.tableView.contentOffset.y
            }
            .unwrap()
            .bind(to: viewModel.inputs.tableViewDragBeginContentOffsetY)
            .disposed(by: disposeBag)

        tableView.rx.observe(CGPoint.self, #keyPath(UITableView.contentOffset))
            .throttle(.milliseconds(Metrics.throttleObserveTableViewDuration), scheduler: MainScheduler.instance)
            .unwrap()
            .map { $0.y }
            .subscribe(onNext: { [weak self] value in
                guard let self = self else { return }
                OWScheduler.runOnMainThreadIfNeeded {
                    self.viewModel.inputs.tableViewContentOffsetY.onNext(value)
                }
            })
            .disposed(by: disposeBag)

        tableView.rx.observe(CGSize.self, #keyPath(UITableView.contentSize))
            .throttle(.milliseconds(Metrics.throttleObserveTableViewDuration), scheduler: MainScheduler.instance)
            .unwrap()
            .map { $0.height }
            .subscribe(onNext: { [weak self] value in
                OWScheduler.runOnMainThreadIfNeeded {
                    self?.viewModel.inputs.tableViewContentSizeHeight.onNext(value)
                }
            })
            .disposed(by: disposeBag)

        viewModel.outputs.conversationDataSourceSections
            .do(onNext: { [weak self] _ in
                OWScheduler.runOnMainThreadIfNeeded {
                    guard let self = self else { return }
                    self.tableViewRefreshControl.endRefreshing()
                }
            })
            .bind(to: tableView.rx.items(dataSource: conversationDataSource))
            .disposed(by: disposeBag)

        Observable.combineLatest(OWSharedServicesProvider.shared.themeStyleService().style,
                                 OWSharedServicesProvider.shared.orientationService().orientation)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] currentStyle, currentOrientation in
                guard let self = self else { return }
                let isLandscape = currentOrientation == .landscape

                self.backgroundColor = isLandscape ? .clear : OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: currentStyle)
                self.commentingCTATopHorizontalSeparator.backgroundColor = OWColorPalette.shared.color(type: .separatorColor1, themeStyle: currentStyle)
                self.tableViewRefreshControl.tintColor = OWColorPalette.shared.color(type: .loaderColor, themeStyle: currentStyle)
                self.commentingCTAContainerView.backgroundColor = OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: currentStyle)
                self.tableView.indicatorStyle = currentStyle == .light ? .black : .white
            })
            .disposed(by: disposeBag)

        viewModel.outputs.performTableViewAnimation
            .subscribe(onNext: { [weak self] _ in
                OWScheduler.runOnMainThreadIfNeeded {
                    guard let self = self else { return }
                    UIView.animate(withDuration: Metrics.tableViewAnimationDuration) {
                        self.tableView.beginUpdates()
                        self.tableView.endUpdates()
                    }
                }
            })
            .disposed(by: disposeBag)

        tableView.rx.willDisplayCell
            .bind(to: viewModel.inputs.willDisplayCell)
            .disposed(by: disposeBag)

        tableViewRefreshControl.rx.controlEvent(UIControl.Event.valueChanged)
            .flatMapLatest { [weak self] _ -> Observable<Void> in
                guard let self = self else { return .empty() }
                return self.tableView.rx.didEndDecelerating
                    .asObservable()
                    .take(1)
            }
            .do(onNext: { [weak self] _ in
                OWScheduler.runOnMainThreadIfNeeded {
                    guard let self = self else { return }
                    self.tableView.setContentOffset(.zero, animated: true)
                }
            })
            .delay(.milliseconds(Metrics.delayPullToRefreshDuration), scheduler: conversationViewScheduler)
            .subscribe(onNext: { [weak self] _ in
                OWScheduler.runOnMainThreadIfNeeded {
                    guard let self = self else { return }
                    self.viewModel.inputs.pullToRefresh.onNext()
                }
            })
            .disposed(by: disposeBag)

        viewModel.outputs.scrollToTopAnimated
        // filter only when animated = false
            .filter { !$0 }
            .throttle(Metrics.scrollToTopThrottleDelay, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                OWScheduler.runOnMainThreadIfNeeded {
                    guard let self = self else { return }
                    self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .none, animated: false)
                }
            })
            .disposed(by: disposeBag)

        tableView.rx.contentOffset
            .subscribe(onNext: { [weak self] value in
                OWScheduler.runOnMainThreadIfNeeded {
                    self?.viewModel.inputs.changeConversationOffset.onNext(value)
                }
            })
            .disposed(by: disposeBag)

        viewModel.outputs.scrollToTopAnimated
        // filter only when animated = true
            .filter { $0 }
            .subscribe(onNext: { [weak self] _ in
                OWScheduler.runOnMainThreadIfNeeded {
                    guard let self = self else { return }
                    self.tableView.beginUpdates()
                    // it looks like set the content offset behave better when scroll to top
                    self.tableView.setContentOffset(.zero, animated: true)
                    self.tableView.endUpdates()
                }
            })
            .disposed(by: disposeBag)

        viewModel.outputs.scrollToTopAnimated
        // filter only when animated = true
            .filter { $0 }
            .voidify()
            .delay(.milliseconds(Metrics.scrolledToTopDelay), scheduler: conversationViewScheduler)
            .subscribe(onNext: { [weak self] in
                OWScheduler.runOnMainThreadIfNeeded {
                    self?.viewModel.inputs.scrolledToTop.onNext()
                }
            })
            .disposed(by: disposeBag)

        viewModel.outputs.scrollToCellIndex
            .do(onNext: { [weak self] index in
                OWScheduler.runOnMainThreadIfNeeded {
                    guard let self = self else { return }
                    let cellIndexPath = IndexPath(row: index, section: 0)
                    self.tableView.scrollToRow(at: cellIndexPath, at: .top, animated: true)
                }
            })
            .bind(to: viewModel.inputs.scrolledToCellIndex)
            .disposed(by: disposeBag)

        viewModel.outputs.scrollToCellIndexIfNotVisible
            .do(onNext: { [weak self] index in
                guard let self = self else { return }
                OWScheduler.runOnMainThreadIfNeeded {
                    let cellIndexPath = IndexPath(row: index, section: 0)

                    // only if cell not visible scroll to it
                    guard let visibleRows = self.tableView.indexPathsForVisibleRows,
                            !visibleRows.contains(cellIndexPath) else {
                        self.viewModel.inputs.scrolledToCellIndex.onNext(index)
                        return
                    }

                    // Temporarily disable table interactions to ensure smooth scrolling to the first comment.
                    self.tableView.isUserInteractionEnabled = false
                    self.tableView.scrollToRow(at: cellIndexPath, at: .top, animated: true)
                }
            })
            .observe(on: MainScheduler.instance)
            .flatMapLatest { [weak self] index -> Observable<Int> in
                guard let self = self else { return .empty() }
                return self.tableView.rx.didEndScrollingAnimation
                    .asObservable()
                    .take(1)
                    .map { _ in return index }
            }
            .subscribe(onNext: { [weak self] index in
                OWScheduler.runOnMainThreadIfNeeded {
                    guard let self = self else { return }
                    self.tableView.isUserInteractionEnabled = true
                    self.viewModel.inputs.scrolledToCellIndex.onNext(index)
                }
            })
            .disposed(by: disposeBag)

        viewModel.outputs.highlightCellsIndexes
            .subscribe(onNext: { [weak self] indexes in
                OWScheduler.runOnMainThreadIfNeeded {
                    guard let self = self,
                          let indexPathsForVisibleRows = self.tableView.indexPathsForVisibleRows else { return }

                    // Create a filtered and mapped array of non-nil cells
                    let cellsToHighlight = indexPathsForVisibleRows
                        .filter { indexes.contains($0.row) }
                        .compactMap { [weak self] in self?.tableView.cellForRow(at: $0) }

                    // Animate visible cells that need highlighting
                    for cell in cellsToHighlight {
                        let prevBackgroundColor = cell.backgroundColor

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
                }
            })
            .disposed(by: disposeBag)

        viewModel.outputs.reloadCellIndex
            .subscribe(onNext: { [weak self] index in
                OWScheduler.runOnMainThreadIfNeeded {
                    guard let self = self else { return }
                    self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
                }
            })
            .disposed(by: disposeBag)

        // Handle orientation change

        Observable.combineLatest(OWSharedServicesProvider.shared.orientationService().orientation,
                                 viewModel.outputs.loginPromptViewModel.outputs.shouldShowView)
            .subscribe(onNext: { [weak self] currentOrientation, shouldShowLoginPrompt in
                OWScheduler.runOnMainThreadIfNeeded {
                    guard let self = self else { return }

                    if currentOrientation == .portrait || !shouldShowLoginPrompt {
                        self.summaryPortraitLeadingConstraint?.activate()
                        self.summaryLandscapeLeadingConstraint?.deactivate()
                    } else {
                        self.summaryPortraitLeadingConstraint?.deactivate()
                        self.summaryLandscapeLeadingConstraint?.activate()
                    }
                }
            })
            .disposed(by: disposeBag)

        OWSharedServicesProvider.shared.orientationService()
            .orientation
            // skip first orientation share(replay: 1) as we do
            // not want animation at conversation loading state
            // the correct constraints are set anyway at view setup
            .skip(1)
            .subscribe(onNext: { [weak self] currentOrientation in
                OWScheduler.runOnMainThreadIfNeeded {
                    guard let self = self else { return }
                    let isLandscape = currentOrientation == .landscape

                    self.tableView.OWSnp.updateConstraints { make in
                        make.leading.trailing.equalToSuperviewSafeArea().inset(isLandscape ? Metrics.horizontalLandscapeMargin : 0)
                    }

                    UIView.animate(withDuration: Metrics.loginPromptOrientationChangeAnimationDuration) {
                        if currentOrientation == .portrait {
                            self.loginPromptLandscapeConstraints.forEach { $0.deactivate() }
                            self.loginPromptPortraitConstraints.forEach { $0.activate() }
                        } else {
                            self.loginPromptPortraitConstraints.forEach { $0.deactivate() }
                            self.loginPromptLandscapeConstraints.forEach { $0.activate() }
                        }
                        self.layoutIfNeeded()
                    }

                    self.commentingCTAView.OWSnp.updateConstraints { make in
                        make.leading.trailing.equalToSuperviewSafeArea().inset(self.horizontalMargin(isLandscape: isLandscape))
                    }

                    self.viewModel.outputs.filterTabsVM
                        .inputs.setMinimumLeadingTrailingMargin.onNext(isLandscape ? Metrics.horizontalLandscapeMargin : Metrics.horizontalPortraitMargin)
                }
            })
            .disposed(by: disposeBag)
    }
    // swiftlint:enable function_body_length

    func horizontalMargin(isLandscape: Bool) -> CGFloat {
        return isLandscape ? Metrics.horizontalLandscapeMargin : Metrics.horizontalPortraitMargin
    }
}
