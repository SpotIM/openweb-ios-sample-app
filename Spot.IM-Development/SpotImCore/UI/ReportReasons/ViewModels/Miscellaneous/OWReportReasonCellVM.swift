//
//  OWReportReasonCellVM.swift
//  SpotImCore
//
//  Created by Refael Sommer on 16/04/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import RxSwift
import Foundation

protocol OWReportReasonCellViewModelingInputs {
    var setSelected: BehaviorSubject<Bool> { get }
}

protocol OWReportReasonCellViewModelingOutputs {
    var title: String { get }
    var subtitle: String { get }
    var isSelected: Observable<Bool> { get }
}

protocol OWReportReasonCellViewModeling {
    var inputs: OWReportReasonCellViewModelingInputs { get }
    var outputs: OWReportReasonCellViewModelingOutputs { get }
}

class OWReportReasonCellViewModel: OWReportReasonCellViewModelingInputs, OWReportReasonCellViewModelingOutputs, OWReportReasonCellViewModeling {

    let title: String
    let subtitle: String

    var setSelected = BehaviorSubject(value: false)
    var isSelected: Observable<Bool> {
        self.setSelected
            .asObservable()
    }

    var inputs: OWReportReasonCellViewModelingInputs { return self }
    var outputs: OWReportReasonCellViewModelingOutputs { return self }

    init(reason: OWReportReason) {
        self.title = reason.reportType.localizedTitle
        self.subtitle = reason.reportType.localizedSubtitle
    }
}
