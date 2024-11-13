//
//  OWFloatingViewModel.swift
//  OpenWeb-SampleApp
//
//  Created by Refael Sommer on 06/11/2024.
//

import RxSwift
import RxCocoa

protocol OWFloatingViewModelOutputs {
    var contentView: Observable<UIView> { get }
}

protocol OWFloatingViewModelInputs {
    var setContentView: PublishSubject<UIView> { get }
}

protocol OWFloatingViewModeling {
    var inputs: OWFloatingViewModelInputs { get }
}

class OWFloatingViewModel: OWFloatingViewModeling, OWFloatingViewModelOutputs, OWFloatingViewModelInputs {
    var inputs: OWFloatingViewModelInputs { return self }
    var outputs: OWFloatingViewModelOutputs { return self }

    var setContentView = PublishSubject<UIView>()
    var contentView: Observable<UIView> {
        return setContentView
            .asObservable()
    }

    init() {
    }
}
