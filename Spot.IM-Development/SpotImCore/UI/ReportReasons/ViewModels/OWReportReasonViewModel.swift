//
//  OWReportReasonViewModel.swift
//  SpotImCore
//
//  Created by Refael Sommer on 16/04/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWReportReasonViewModelingInputs {
}

protocol OWReportReasonViewModelingOutputs {
    var reportReasonCellViewModels: Observable<[OWReportReasonCellViewModeling]> { get }
}

protocol OWReportReasonViewModeling {
    var inputs: OWReportReasonViewModelingInputs { get }
    var outputs: OWReportReasonViewModelingOutputs { get }
}

class OWReportReasonViewModel: OWReportReasonViewModelingInputs, OWReportReasonViewModelingOutputs, OWReportReasonViewModeling {
    var inputs: OWReportReasonViewModelingInputs { return self }
    var outputs: OWReportReasonViewModelingOutputs { return self }

    var reportReasonCellViewModels = Observable<[OWReportReasonCellViewModeling]>.create { observer in
        if let reportReasonConfig = SPConfigsDataSource.appConfig?.shared?.reportReasonsOptions {
            let reportReasonViewModels = reportReasonConfig.reasons.map { OWReportReasonCellViewModel(reason: $0) }
            observer.onNext(reportReasonViewModels)
        }
        return Disposables.create()
    }
}
