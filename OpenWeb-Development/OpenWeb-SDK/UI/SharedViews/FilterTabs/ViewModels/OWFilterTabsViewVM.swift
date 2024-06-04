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
    var selectTab: PublishSubject<OWFilterTabsCollectionCellViewModel> { get }
}

protocol OWFilterTabsViewViewModelingOutputs {
    var tabs: Observable<[OWFilterTabsCollectionCellViewModel]> { get }
    var selectedTab: Observable<OWFilterTabsCollectionCellViewModel> { get }
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

    var _tabs = BehaviorSubject<[OWFilterTabsCollectionCellViewModel]>(value: [])
    var tabs: Observable<[OWFilterTabsCollectionCellViewModel]> {
        return _tabs
            .asObservable()
    }

    var selectTab = PublishSubject<OWFilterTabsCollectionCellViewModel>()
    var selectedTab: Observable<OWFilterTabsCollectionCellViewModel> {
        return selectTab
            .asObservable()
    }

    init(servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.servicesProvider = servicesProvider
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
                        .map {
                            let model = OWFilterTabObject(id: $0.id, count: $0.count, name: $0.label)
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
        getTabs
            .observe(on: MainScheduler.instance)
            .bind(to: _tabs)
            .disposed(by: disposeBag)
    }
}

