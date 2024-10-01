//
//  OWMenuSelectionCellViewModel.swift
//  OpenWebSDK
//
//  Created by  Nogah Melamed on 07/06/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation
import RxSwift

protocol OWMenuSelectionCellViewModelingInputs {

}

protocol OWMenuSelectionCellViewModelingOutputs {
    var titleText: Observable<String> { get }
    var titleIdentifier: String { get }
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

    private var _titleText = BehaviorSubject<String>(value: "")
    var titleText: Observable<String> {
        _titleText
            .asObserver()
    }

    let titleIdentifier: String

    init(title: String, titleIdentifier: String) {
        self.titleIdentifier = titleIdentifier
        _titleText.onNext(title)
    }
}
