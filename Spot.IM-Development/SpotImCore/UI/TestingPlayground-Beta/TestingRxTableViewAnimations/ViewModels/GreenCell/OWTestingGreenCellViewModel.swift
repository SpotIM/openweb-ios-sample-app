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
    var changeCellState: Observable<OWTestingCellState> { get }
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
    var changeCellState: Observable<OWTestingCellState> {
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
    let id: String = UUID().uuidString

    init() {
        setupObservers()
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
