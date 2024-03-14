//
//  OWAppealCellViewModel.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 06/11/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import RxSwift
import Foundation

protocol OWAppealCellViewModelingInputs {
    var setSelected: BehaviorSubject<Bool> { get }
}

protocol OWAppealCellViewModelingOutputs {
    var title: String { get }
    var isSelected: Observable<Bool> { get }
}

protocol OWAppealCellViewModeling {
    var inputs: OWAppealCellViewModelingInputs { get }
    var outputs: OWAppealCellViewModelingOutputs { get }
}

class OWAppealCellViewModel: OWAppealCellViewModelingInputs, OWAppealCellViewModelingOutputs, OWAppealCellViewModeling {

    let title: String

    var setSelected = BehaviorSubject(value: false)
    var isSelected: Observable<Bool> {
        self.setSelected
            .asObservable()
    }

    var inputs: OWAppealCellViewModelingInputs { return self }
    var outputs: OWAppealCellViewModelingOutputs { return self }

    init(reason: OWAppealReason) {
        self.title = reason.type.localizedTitle
    }
}
