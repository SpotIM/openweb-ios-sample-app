//
//  OWFilterTabsViewViewModel.swift
//  OpenWebSDK
//
//  Created by Refael Sommer on 02/06/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

import Foundation
import RxSwift

typealias FilterTabsDataSourceModel = OWAnimatableSectionModel<String, OWFilterTabsCellOption>

protocol OWFilterTabsViewViewModelingInputs {
    var selectTab: BehaviorSubject<OWFilterTabsSelectedTab> { get }
    var setMinimumLeadingTrailingMargin: BehaviorSubject<CGFloat> { get }
    var reloadTabs: PublishSubject<Void> { get }
    var selectTabAll: PublishSubject<Void> { get }
}

protocol OWFilterTabsViewViewModelingOutputs {
    var filterTabsDataSourceModel: Observable<[FilterTabsDataSourceModel]> { get }
    var tabs: Observable<[OWFilterTabsCollectionCellViewModel]> { get }
    var didSelectTab: Observable<OWFilterTabsSelectedTab> { get }
    var selectedTab: Observable<OWFilterTabsSelectedTab> { get }
    var shouldShowFilterTabs: Observable<Bool> { get }
    var minimumLeadingTrailingMargin: Observable<CGFloat> { get }
}

protocol OWFilterTabsViewViewModeling {
    var inputs: OWFilterTabsViewViewModelingInputs { get }
    var outputs: OWFilterTabsViewViewModelingOutputs { get }
}

class OWFilterTabsViewViewModel: OWFilterTabsViewViewModeling, OWFilterTabsViewViewModelingOutputs, OWFilterTabsViewViewModelingInputs {
    var inputs: OWFilterTabsViewViewModelingInputs { return self }
    var outputs: OWFilterTabsViewViewModelingOutputs { return self }

    fileprivate struct Metrics {
        static let numberOfSkeletons = 6
        static let debounceCellViewModelsDuration = 10
    }

    fileprivate let disposeBag = DisposeBag()
    fileprivate let servicesProvider: OWSharedServicesProviding
    fileprivate let sourceType: OWViewSourceType
    fileprivate let isLoading = BehaviorSubject<Bool>(value: true)

    var reloadTabs = PublishSubject<Void>()
    var selectTabAll = PublishSubject<Void>()

    var filterTabsDataSourceModel: Observable<[FilterTabsDataSourceModel]> {
        return cellsViewModels
            .map { items in
                let section = FilterTabsDataSourceModel(model: "", items: items)
                return [section]
            }
    }

    var _tabs = BehaviorSubject<[OWFilterTabsCollectionCellViewModel]>(value: [])
    var tabs: Observable<[OWFilterTabsCollectionCellViewModel]> {
        return _tabs
            .asObservable()
    }

    var selectTab = BehaviorSubject<OWFilterTabsSelectedTab>(value: .none)
    var selectedTab: Observable<OWFilterTabsSelectedTab> {
        return selectTab
            .asObservable()
    }
    var didSelectTab: Observable<OWFilterTabsSelectedTab> {
        let selectedTabObservable = {
            if sourceType == .conversation {
                return selectTab
                    .distinctUntilChanged()
            } else {
                return selectTab
            }
        }()
        return selectedTabObservable
            .filter { $0 != .none }
            .withLatestFrom(isLoading) { ($0, $1) }
            .filter { !$1 } // Only pass if not loading
            .map { $0.0 }
            .asObservable()
    }

    fileprivate lazy var hasMoreThanOneTab: Observable<Bool> = {
        return cellsViewModels
            .map { $0.count > 1 }
            // This is to prevent animation hide and show for a moment when tabs are initialized
            // There is a moment that there are no tabs and then they are filled in.
            .debounce(.milliseconds(Metrics.debounceCellViewModelsDuration), scheduler: MainScheduler.instance)
            .asObservable()
    }()

    // Show FilterTabsView according to conversationConfig isTabsEnabled and Tabs count
    lazy var shouldShowFilterTabs: Observable<Bool> = {
        let configurationService = servicesProvider.spotConfigurationService()
        return Observable.combineLatest(configurationService.config(spotId: OWManager.manager.spotId).take(1), hasMoreThanOneTab)
            .map { [weak self] config, shouldShowFilterTabs -> Bool in
                guard let self = self,
                      let conversationConfig = config.conversation else { return false }
                return conversationConfig.isTabsEnabled && shouldShowFilterTabs
            }
            .asObservable()
    }()

    var setMinimumLeadingTrailingMargin = BehaviorSubject<CGFloat>(value: 0)
    var minimumLeadingTrailingMargin: Observable<CGFloat> {
        return setMinimumLeadingTrailingMargin
            .asObservable()
    }

    init(servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared,
         sourceType: OWViewSourceType) {
        self.servicesProvider = servicesProvider
        self.sourceType = sourceType
        self.setupObservers()
    }

    fileprivate var cellsViewModels: Observable<[OWFilterTabsCellOption]> {
        return Observable.combineLatest(tabs, isLoading)
            .flatMapLatest({ tabs, isLoading -> Observable<[OWFilterTabsCellOption]> in
                if isLoading {
                    let allFilterTabVM = OWFilterTabsCollectionCellViewModel.all()
                    allFilterTabVM.inputs.selected.onNext(true)
                    var skeletonVMs: [OWFilterTabsCellOption] = [OWFilterTabsCellOption.filterTab(viewModel: allFilterTabVM)]
                    for _ in 1...Metrics.numberOfSkeletons {
                        skeletonVMs.append(OWFilterTabsCellOption.filterTabSkeleton(viewModel: OWFilterTabsSkeletonCollectionCellVM()))
                    }
                    return Observable.just(skeletonVMs)
                }
                var viewModels: [OWFilterTabsCellOption] = []
                for tab in tabs {
                    let viewModel = OWFilterTabsCellOption.filterTab(viewModel: tab)
                    viewModels.append(viewModel)
                }
                return Observable.just(viewModels)
            })
            .asObservable()
    }

    fileprivate lazy var getTabs: Observable<[OWFilterTabsCollectionCellViewModel]> = {
        return self.servicesProvider
            .networkAPI()
            .conversation
            .getTabs()
            .response
            .materialize()
            .map { [weak self] event in
                self?.isLoading.onNext(false)
                switch event {
                case .next(let filterTabsResponse):
                    return filterTabsResponse.tabs
                        .filter { $0.count > 0 }
                        .map {
                            let model = OWFilterTabObject(id: $0.id,
                                                          count: $0.count,
                                                          name: $0.label,
                                                          sortOptions: $0.sortOptions)
                            return OWFilterTabsCollectionCellViewModel(model: model)
                        }
                case .error(_):
                    return nil
                default:
                    return nil
                }

            }
            .unwrap()
    }()
}

fileprivate extension OWFilterTabsViewViewModel {
    func setupObservers() {
        guard let postId = OWManager.manager.postId else { return }
        let serviceSelectedTabId = self.servicesProvider
            .filterTabsDictateService()
            .filterId(perPostId: postId)

        reloadTabs
            .flatMap { [weak self] _ -> Observable<[OWFilterTabsCollectionCellViewModel]> in
                guard let self = self else { return .empty() }
                return self.getTabs
            }
            .observe(on: MainScheduler.instance)
            .withLatestFrom(serviceSelectedTabId) { ($0, $1) }
            .subscribe(onNext: { [weak self] filterTabVMs, selectedTabId in
                guard let self = self else { return }
                self._tabs.onNext(filterTabVMs)
                if self.sourceType != .preConversation,
                   let selectedFilterTabVM = filterTabVMs.first(where: { ($0.outputs.tabId == selectedTabId) }) {
                    self.selectTab.onNext(OWFilterTabsSelectedTab.tab(selectedFilterTabVM))
                } else {
                    filterTabVMs.first?.inputs.selected.onNext(true)
                }
            })
            .disposed(by: disposeBag)

        getTabs
            .observe(on: MainScheduler.instance)
            .withLatestFrom(serviceSelectedTabId) { ($0, $1) }
            .withLatestFrom(selectTab) { ($0.0, $0.1, $1) }
            .do(onNext: { [weak self] filterTabVMs, selectedTabId, _ in
                guard let self = self else { return }
                if self.sourceType == .preConversation {
                    if let firstTabVM = filterTabVMs.first {
                        firstTabVM.inputs.selected.onNext(true)
                    }
                } else {
                    guard let selectedTabVm = filterTabVMs.first(where: { $0.outputs.tabId == selectedTabId }) else { return }
                    selectedTabVm.inputs.selected.onNext(true)
                    self.selectTab.onNext(OWFilterTabsSelectedTab.tab(selectedTabVm))
                }
            })
            .map { $0.0 }
            .subscribe(onNext: { [weak self] filterTabVMs in
                self?._tabs.onNext(filterTabVMs)
            })
            .disposed(by: disposeBag)

        didSelectTab
            .withLatestFrom(tabs) { ($0, $1) }
            .subscribe(onNext: { [weak self] tabToSelect, tabsToUnselectVMs in
                guard let self = self else { return }
                switch tabToSelect {
                case .tab(let tabToSelectVM):
                    if self.sourceType != .preConversation {
                        tabsToUnselectVMs.forEach { tabToUnselectVM in
                            tabToUnselectVM.inputs.selected.onNext(false)
                        }
                        tabToSelectVM.inputs.selected.onNext(true)
                    }
                    self.servicesProvider
                        .filterTabsDictateService()
                        .update(filterTabId: tabToSelectVM.outputs.tabId, for: postId)
                default:
                    return
                }
            })
            .disposed(by: disposeBag)

        selectTabAll
            .withLatestFrom(tabs)
            .map { tabs -> OWFilterTabsCollectionCellViewModel? in
                return tabs.first(where: { $0.outputs.tabId == OWFilterTabObject.defaultTabId })
            }
            .unwrap()
            .map { return OWFilterTabsSelectedTab.tab($0) }
            .bind(to: selectTab)
            .disposed(by: disposeBag)
    }
}

