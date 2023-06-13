//
//  OWMenuSelectionViewModel.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 07/06/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import RxSwift

protocol OWMenuSelectionViewModelingInputs {}

protocol OWMenuSelectionViewModelingOutputs {
    var cellsViewModels: Observable<[OWMenuSelectionCellViewModeling]> { get }
}

protocol OWMenuSelectionViewModeling {
    var inputs: OWMenuSelectionViewModelingInputs { get }
    var outputs: OWMenuSelectionViewModelingOutputs { get }
}

class OWMenuSelectionViewModel: OWMenuSelectionViewModeling, OWMenuSelectionViewModelingInputs, OWMenuSelectionViewModelingOutputs {
    var inputs: OWMenuSelectionViewModelingInputs { return self }
    var outputs: OWMenuSelectionViewModelingOutputs { return self }

    fileprivate let _cellsViewModels = BehaviorSubject<[OWMenuSelectionCellViewModeling]>(value: [])
    var cellsViewModels: Observable<[OWMenuSelectionCellViewModeling]> {
        return _cellsViewModels
            .asObservable()
            .share(replay: 1)
    }

    init(items: [OWMenuSelectionItem]) {
        let vms = items.map { OWMenuSelectionCellViewModel(title: $0.title) }
        _cellsViewModels.onNext(vms)
    }
}

struct OWMenuSelectionItem {
    var title: String
    var onClick: PublishSubject<Void>
}
