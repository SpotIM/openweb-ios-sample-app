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
    var isSelectedNonRx: Bool { get }
    var sortOptions: [String]? { get }
}

protocol OWFilterTabsCollectionCellViewModeling: OWCellViewModel {
    var inputs: OWFilterTabsCollectionCellViewModelingInputs { get }
    var outputs: OWFilterTabsCollectionCellViewModelingOutputs { get }
}

class OWFilterTabsCollectionCellViewModel: OWFilterTabsCollectionCellViewModeling,
                                           OWFilterTabsCollectionCellViewModelingInputs,
                                           OWFilterTabsCollectionCellViewModelingOutputs {
    var inputs: OWFilterTabsCollectionCellViewModelingInputs { return self }
    var outputs: OWFilterTabsCollectionCellViewModelingOutputs { return self }

    private let disposeBag = DisposeBag()
    private let model: OWFilterTabObject

    var accessibilityPrefix: String {
        model.name
    }

    lazy var sortOptions: [String]? = {
        return model.sortOptions
    }()

    lazy var tabId: String = {
        return model.id
    }()

    var isSelectedNonRx: Bool {
        return model.selected
    }

    lazy var text: String = {
        let localizedName = OWLocalizationManager.shared.localizedString(key: model.name)
        let countString = model.id == "all" ? "" : " (\(model.count))"
        return localizedName + countString
    }()

    var selected = BehaviorSubject<Bool>(value: false)
    var isSelected: Observable<Bool> {
        return selected
            .asObservable()
    }

    init(model: OWFilterTabObject) {
        self.model = model
        self.setupObservers()
    }
}

private extension OWFilterTabsCollectionCellViewModel {
    func setupObservers() {
        isSelected
            .subscribe(onNext: { [weak self] isSelected in
                guard let self = self else { return }
                self.model.selected = isSelected
            })
            .disposed(by: disposeBag)
    }
}

extension OWFilterTabsCollectionCellViewModel {
    static func stub() -> OWFilterTabsCollectionCellViewModel {
        return OWFilterTabsCollectionCellViewModel(model: OWFilterTabObject.defaultTab)
    }

    static func all() -> OWFilterTabsCollectionCellViewModel {
        return OWFilterTabsCollectionCellViewModel(model: OWFilterTabObject.defaultTab)
    }
}
