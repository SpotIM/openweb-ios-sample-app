//
//  OWFilterTabsViewViewModel.swift
//  OpenWebSDK
//
//  Created by Refael Sommer on 02/06/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

import Foundation
import RxSwift

protocol OWFilterTabsViewViewModelingInputs {
    var selectTab: BehaviorSubject<OWFilterTabsCollectionCellViewModel?> { get }
    var setMinimumLeadingTrailingMargin: BehaviorSubject<CGFloat> { get }
}

protocol OWFilterTabsViewViewModelingOutputs {
    var tabs: Observable<[OWFilterTabsCollectionCellViewModel]> { get }
    var selectedTab: Observable<OWFilterTabsCollectionCellViewModel> { get }
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

    fileprivate let disposeBag = DisposeBag()
    fileprivate let servicesProvider: OWSharedServicesProviding
    fileprivate let sourceType: OWViewSourceType

    var _tabs = BehaviorSubject<[OWFilterTabsCollectionCellViewModel]>(value: [])
    var tabs: Observable<[OWFilterTabsCollectionCellViewModel]> {
        return _tabs
            .asObservable()
    }

    var selectTab = BehaviorSubject<OWFilterTabsCollectionCellViewModel?>(value: nil)
    var selectedTab: Observable<OWFilterTabsCollectionCellViewModel> {
        return selectTab
            .unwrap()
            .asObservable()
    }

    lazy var shouldShowFilterTabs: Observable<Bool> = {
        return tabs
            .map { $0.count > 1 }
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

    fileprivate lazy var getTabs: Observable<[OWFilterTabsCollectionCellViewModel]> = {
        return self.servicesProvider
            .networkAPI()
            .filterTabs
            .getTabs()
            .response
            .materialize()
            .map { event in
                switch event {
                case .next(let filterTabsResponse):

                    return filterTabsResponse.tabs
                        // .filter { $0.count > 0 }
                        .map {
                            let model = OWFilterTabObject(id: $0.id, count: $0.count, name: $0.label, sortOptions: $0.sortOptions)
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

        getTabs
            .observe(on: MainScheduler.instance)
            .withLatestFrom(serviceSelectedTabId) { ($0, $1) }
            .withLatestFrom(selectTab) { ($0.0, $0.1, $1) }
            .do(onNext: { [weak self] filterTabVMs, selectedTabId, selectedTabVM in
                guard let self = self else { return }
                if self.sourceType == .preConversation {
                    if let firstTabVM = filterTabVMs.first {
                        firstTabVM.inputs.selected.onNext(true)
                    }
                } else {
                    guard let selectedTabVm = filterTabVMs.first(where: { $0.outputs.tabId == selectedTabId }) else { return }
                    selectedTabVm.inputs.selected.onNext(true)
                    self.selectTab.onNext(selectedTabVm)
                }
            })
            .map { $0.0 }
            .bind(to: _tabs)
            .disposed(by: disposeBag)

        selectedTab
            .withLatestFrom(tabs) { ($0, $1) }
            .subscribe(onNext: { [weak self] tabToSelectVM, tabsToUnselectVMs in
                guard let self = self else { return }
                if self.sourceType != .preConversation {
                    tabsToUnselectVMs.forEach { tabToUnselectVM in
                        tabToUnselectVM.inputs.selected.onNext(false)
                    }
                    tabToSelectVM.inputs.selected.onNext(true)
                }
                self.servicesProvider
                    .filterTabsDictateService()
                    .update(filterTabId: tabToSelectVM.outputs.tabId, perPostId: postId)
            })
            .disposed(by: disposeBag)
    }
}

