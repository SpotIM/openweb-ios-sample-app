//
//  OWTestingBlueFirstLevelViewModel.swift
//  SpotImCore
//
//  Created by Alon Haiut on 25/04/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

#if BETA

import Foundation
import RxSwift

protocol OWTestingBlueFirstLevelViewModelingInputs {
    var removeTap: PublishSubject<Void> { get }
    var changeCellStateTap: PublishSubject<Void> { get }
    var changeCellStateTo: PublishSubject<OWTestingCellState> { get }
}

protocol OWTestingBlueFirstLevelViewModelingOutputs {
    var id: String { get } // Used for presentation inside the label
    var removeTapped: Observable<Void> { get }
    var changedCellState: Observable<OWTestingCellState> { get }
}

protocol OWTestingBlueFirstLevelViewModeling {
    var inputs: OWTestingBlueFirstLevelViewModelingInputs { get }
    var outputs: OWTestingBlueFirstLevelViewModelingOutputs { get }
}

class OWTestingBlueFirstLevelViewModel: OWTestingBlueFirstLevelViewModeling,
                                OWTestingBlueFirstLevelViewModelingInputs,
                                OWTestingBlueFirstLevelViewModelingOutputs {
    var inputs: OWTestingBlueFirstLevelViewModelingInputs { return self }
    var outputs: OWTestingBlueFirstLevelViewModelingOutputs { return self }

    fileprivate let disposeBag = DisposeBag()

    fileprivate let cellState = BehaviorSubject<OWTestingCellState>(value: .collapsed)
    var changedCellState: Observable<OWTestingCellState> {
        return cellState
            .distinctUntilChanged()
            .asObservable()
            .share(replay: 1)
    }

    var removeTap = PublishSubject<Void>()
    var removeTapped: Observable<Void> {
        return removeTap
            .asObservable()
    }

    var changeCellStateTap = PublishSubject<Void>()
    var changeCellStateTo = PublishSubject<OWTestingCellState>()

    let id: String

    init(id: String) {
        self.id = id
        setupObservers()
    }
}

fileprivate extension OWTestingBlueFirstLevelViewModel {
    func setupObservers() {
        changeCellStateTap
            .withLatestFrom(cellState)
            .map { $0.opposite }
            .bind(to: cellState)
            .disposed(by: disposeBag)

        changeCellStateTo
            .bind(to: cellState)
            .disposed(by: disposeBag)
    }
}

#endif
