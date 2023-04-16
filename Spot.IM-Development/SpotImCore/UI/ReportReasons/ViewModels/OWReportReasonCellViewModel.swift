//
//  OWReportReasonCellViewModel.swift
//  SpotImCore
//
//  Created by Refael Sommer on 16/04/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

protocol OWReportReasonCellViewModelingInputs {

}

protocol OWReportReasonCellViewModelingOutputs {
    var title: String { get }
    var subtitle: String { get }
}

protocol OWReportReasonCellViewModeling {
    var inputs: OWReportReasonCellViewModelingInputs { get }
    var outputs: OWReportReasonCellViewModelingOutputs { get }
}

class OWReportReasonCellViewModel: OWReportReasonCellViewModelingInputs, OWReportReasonCellViewModelingOutputs, OWReportReasonCellViewModeling {
    let title: String
    let subtitle: String

    var inputs: OWReportReasonCellViewModelingInputs { return self }
    var outputs: OWReportReasonCellViewModelingOutputs { return self }

    init(reason: OWReportReason) {
        self.title = NSLocalizedString("\(reason.reportType)_title", comment: "")
        self.subtitle = NSLocalizedString("\(reason.reportType)_subtitle", comment: "")
    }
}
