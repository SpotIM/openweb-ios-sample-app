//
//  OWFilterTabsCollectionCellVM.swift
//  OpenWebSDK
//
//  Created by Refael Sommer on 03/06/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

import Foundation
import RxSwift

protocol OWFilterTabsCollectionCellViewModelingInputs {
    var selected: BehaviorSubject<Bool> { get }
}

protocol OWFilterTabsCollectionCellViewModelingOutputs {
    var accessibilityPrefix: String { get }
    var isSelected: Observable<Bool> { get }
    var text: String { get }
    var tabId: String { get }
    var sortOptions: [String]? { get }
}

protocol OWFilterTabsCollectionCellViewModeling {
    var inputs: OWFilterTabsCollectionCellViewModelingInputs { get }
    var outputs: OWFilterTabsCollectionCellViewModelingOutputs { get }
}

class OWFilterTabsCollectionCellViewModel: OWFilterTabsCollectionCellViewModeling,
                                           OWFilterTabsCollectionCellViewModelingInputs,
                                           OWFilterTabsCollectionCellViewModelingOutputs {
    var inputs: OWFilterTabsCollectionCellViewModelingInputs { return self }
    var outputs: OWFilterTabsCollectionCellViewModelingOutputs { return self }

    fileprivate let disposeBag = DisposeBag()
    fileprivate let model: OWFilterTabObject

    var accessibilityPrefix: String {
        model.name
    }

    lazy var sortOptions: [String]? = {
        return model.sortOptions
    }()

    lazy var tabId: String = {
        return model.id
    }()

    lazy var text: String = {
        return model.name + (model.id == "all" ? "" : " (\(model.count))")
    }()

    var selected = BehaviorSubject<Bool>(value: false)
    var isSelected: Observable<Bool> {
        return selected
            .asObservable()
    }

    init(model: OWFilterTabObject) {
        self.model = model
    }
}

fileprivate extension OWFilterTabsCollectionCellViewModel {
    func setupObservers() {
        isSelected
            .subscribe(onNext: { [weak self] isSelected in
                guard let self = self else { return }
                self.model.selected = isSelected
            })
            .disposed(by: disposeBag)
    }
}
