//
//  OWMenuSelectionViewModel.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 07/06/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import RxSwift

protocol OWMenuSelectionViewModelingInputs {
    var cellSelected: PublishSubject<Int> { get }
    var menuDismissed: PublishSubject<Void> { get }
}

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

    var menuDismissed = PublishSubject<Void>()
    fileprivate var menuDismissedObservable: Observable<Void> {
        return menuDismissed
            .asObservable()
    }

    var cellSelected = PublishSubject<Int>()
    var disposeBag = DisposeBag()

    init(items: [OWMenuSelectionItem], onDismiss: @escaping () -> Void) {
        let vms = items.map {
            OWMenuSelectionCellViewModel(title: $0.title,
                                         titleIdentifier: $0.titleIdentifier)
        }
        _cellsViewModels.onNext(vms)

        cellSelected
            .asObservable()
            .subscribe(onNext: { index in
                items[index].handler()
            })
            .disposed(by: disposeBag)

        menuDismissedObservable
            .subscribe(onNext: {
                onDismiss()
            })
            .disposed(by: disposeBag)
    }
}

struct OWMenuSelectionItem {
    var title: String
    var titleIdentifier: String
    var handler: (() -> Void)
}
