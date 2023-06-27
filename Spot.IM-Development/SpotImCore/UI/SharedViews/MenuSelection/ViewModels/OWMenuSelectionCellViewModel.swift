//
//  OWMenuSelectionCellViewModel.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 07/06/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWMenuSelectionCellViewModelingInputs {

}

protocol OWMenuSelectionCellViewModelingOutputs {
    var titleText: Observable<String> { get }
}

protocol OWMenuSelectionCellViewModeling {
    var inputs: OWMenuSelectionCellViewModelingInputs { get }
    var outputs: OWMenuSelectionCellViewModelingOutputs { get }
}

class OWMenuSelectionCellViewModel:
    OWMenuSelectionCellViewModeling,
    OWMenuSelectionCellViewModelingInputs,
    OWMenuSelectionCellViewModelingOutputs {

    var inputs: OWMenuSelectionCellViewModelingInputs { return self }
    var outputs: OWMenuSelectionCellViewModelingOutputs { return self }

    fileprivate var _titleText = BehaviorSubject<String>(value: "")
    var titleText: Observable<String> {
        _titleText
            .asObserver()
    }

    init(title: String) {
        _titleText.onNext(title)
    }
}
