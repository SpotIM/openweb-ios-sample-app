//
//  OWReportReasonCancelVM.swift
//  SpotImCore
//
//  Created by Refael Sommer on 24/04/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWReportReasonCancelViewModelingInputs { }
protocol OWReportReasonCancelViewModelingOutputs {
    var reportReasonCancelViewViewModel: OWReportReasonCancelViewViewModeling { get }
}

protocol OWReportReasonCancelViewModeling {
    var inputs: OWReportReasonCancelViewModelingInputs { get }
    var outputs: OWReportReasonCancelViewModelingOutputs { get }
}

class OWReportReasonCancelViewModel: OWReportReasonCancelViewModeling, OWReportReasonCancelViewModelingOutputs, OWReportReasonCancelViewModelingInputs {
    var inputs: OWReportReasonCancelViewModelingInputs { return self }
    var outputs: OWReportReasonCancelViewModelingOutputs { return self }

    let reportReasonCancelViewViewModel: OWReportReasonCancelViewViewModeling

    init(reportReasonCancelViewViewModel: OWReportReasonCancelViewViewModeling) {
        self.reportReasonCancelViewViewModel = reportReasonCancelViewViewModel
    }
}
