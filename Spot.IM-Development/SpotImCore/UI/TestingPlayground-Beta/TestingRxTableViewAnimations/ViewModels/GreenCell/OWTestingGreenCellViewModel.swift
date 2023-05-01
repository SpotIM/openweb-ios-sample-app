//
//  OWTestingGreenCellViewModel.swift
//  SpotImCore
//
//  Created by Alon Haiut on 25/04/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

#if BETA

import Foundation
import RxSwift

protocol OWTestingGreenCellViewModelingInputs {
    var removeTap: PublishSubject<Void> { get }
    var changeCellStateTap: PublishSubject<Void> { get }
}

protocol OWTestingGreenCellViewModelingOutputs {
    var id: String { get }
    var removeTapped: Observable<Void> { get }
    var changedCellState: Observable<OWTestingCellState> { get }
    func copy() -> OWTestingGreenCellViewModeling
}

protocol OWTestingGreenCellViewModeling: OWCellViewModel {
    var inputs: OWTestingGreenCellViewModelingInputs { get }
    var outputs: OWTestingGreenCellViewModelingOutputs { get }
}

class OWTestingGreenCellViewModel: OWTestingGreenCellViewModeling,
                                OWTestingGreenCellViewModelingInputs,
                                OWTestingGreenCellViewModelingOutputs {
    var inputs: OWTestingGreenCellViewModelingInputs { return self }
    var outputs: OWTestingGreenCellViewModelingOutputs { return self }

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

    // Unique identifier
    let id: String

    init(id: String = UUID().uuidString) {
        self.id = id
        setupObservers()
    }

    func copy() -> OWTestingGreenCellViewModeling {
        let newVM = OWTestingGreenCellViewModel(id: self.id)
        _ = changedCellState
            .take(1)
            .subscribe(onNext: { state in
                newVM.cellState.onNext(state)
            })
        return newVM
    }
}

fileprivate extension OWTestingGreenCellViewModel {
    func setupObservers() {
        changeCellStateTap
            .withLatestFrom(cellState)
            .map { $0.opposite }
            .bind(to: cellState)
            .disposed(by: disposeBag)
    }
}

#endif
