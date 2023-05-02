//
//  OWTestingCellsGeneratorViewModel.swift
//  SpotImCore
//
//  Created by Alon Haiut on 27/04/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

#if BETA

import UIKit
import RxSwift

protocol OWTestingCellsGeneratorViewModelingInputs {
    var addTap: PublishSubject<Void> { get }
    var reloadAllTap: PublishSubject<Void> { get }
    var removeAllTap: PublishSubject<Void> { get }
    var textFieldFinish: PublishSubject<String> { get }
}

protocol OWTestingCellsGeneratorViewModelingOutputs {
    var mainText: Observable<String> { get }
    var mainTextColor: Observable<UIColor> { get }
    var textFieldNumberString: Observable<String> { get }
    var addCells: Observable<Int> { get }
    var reloadAll: Observable<Void> { get }
    var removeAll: Observable<Void> { get }
}

protocol OWTestingCellsGeneratorViewModeling {
    var inputs: OWTestingCellsGeneratorViewModelingInputs { get }
    var outputs: OWTestingCellsGeneratorViewModelingOutputs { get }
}

class OWTestingCellsGeneratorViewModel: OWTestingCellsGeneratorViewModeling,
                                OWTestingCellsGeneratorViewModelingInputs,
                                OWTestingCellsGeneratorViewModelingOutputs {
    var inputs: OWTestingCellsGeneratorViewModelingInputs { return self }
    var outputs: OWTestingCellsGeneratorViewModelingOutputs { return self }

    fileprivate struct Metrics {
        static let defaultCellsToAdd: Int = 1
        static let minCellsToAdd: Int = 1
        static let maxCellsToAdd: Int = 99
    }

    let addTap = PublishSubject<Void>()
    let reloadAllTap = PublishSubject<Void>()
    let removeAllTap = PublishSubject<Void>()
    var textFieldFinish = PublishSubject<String>()

    fileprivate let disposeBag = DisposeBag()

    init(requiredData: OWTestingCellsGeneratorRequiredData) {
        _mainText.onNext(requiredData.title)
        _mainTextColor.onNext(requiredData.color)
        setupObservers()
    }

    fileprivate let _mainText = BehaviorSubject<String?>(value: nil)
    var mainText: Observable<String> {
        return _mainText
            .unwrap()
    }

    fileprivate let _mainTextColor = BehaviorSubject<UIColor?>(value: nil)
    var mainTextColor: Observable<UIColor> {
        return _mainTextColor
            .unwrap()
    }

    fileprivate let _numberOfCellsToAdd = BehaviorSubject<Int>(value: Metrics.defaultCellsToAdd)
    var textFieldNumberString: Observable<String> {
        return _numberOfCellsToAdd
            .map { "\($0)" }
    }

    var addCells: Observable<Int> {
        return addTap
            .asObservable()
            .withLatestFrom(_numberOfCellsToAdd)
    }

    var reloadAll: Observable<Void> {
        return reloadAllTap
            .asObservable()
    }

    var removeAll: Observable<Void> {
        return removeAllTap
            .asObservable()
    }
}

fileprivate extension OWTestingCellsGeneratorViewModel {
    func setupObservers() {
        textFieldFinish
            .map { numberText -> Int in
                guard let number = Int(numberText) else { return Metrics.defaultCellsToAdd }

                if number > Metrics.maxCellsToAdd {
                    return Metrics.maxCellsToAdd
                } else if number < Metrics.minCellsToAdd {
                    return Metrics.minCellsToAdd
                } else {
                    return number
                }
            }
            .bind(to: _numberOfCellsToAdd)
            .disposed(by: disposeBag)
    }
}

#endif
