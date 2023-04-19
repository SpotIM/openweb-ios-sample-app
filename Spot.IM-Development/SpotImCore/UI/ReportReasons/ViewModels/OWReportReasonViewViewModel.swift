//
//  OWReportReasonVM.swift
//  SpotImCore
//
//  Created by Refael Sommer on 16/04/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

#if NEW_API

public protocol OWReportReasonViewViewModelingInputs {
}

public protocol OWReportReasonViewViewModelingOutputs {
    var reportReasonCellViewModels: Observable<[OWReportReasonCellViewModeling]> { get }
}

public protocol OWReportReasonViewViewModeling {
    var inputs: OWReportReasonViewViewModelingInputs { get }
    var outputs: OWReportReasonViewViewModelingOutputs { get }
}

class OWReportReasonViewViewModel: OWReportReasonViewViewModelingInputs, OWReportReasonViewViewModelingOutputs, OWReportReasonViewViewModeling {
    fileprivate struct Metrics {
    }

    var inputs: OWReportReasonViewViewModelingInputs { return self }
    var outputs: OWReportReasonViewViewModelingOutputs { return self }

    fileprivate let servicesProvider: OWSharedServicesProviding

    init(servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.servicesProvider = servicesProvider
    }

    lazy var reportReasonCellViewModels: Observable<[OWReportReasonCellViewModeling]> =
        self.servicesProvider.spotConfigurationService()
            .config(spotId: OWManager.manager.spotId)
            .map { $0.shared?.reportReasonsOptions?.reasonsList }
            .unwrap()
            .map { reasons in
                var viewModels: [OWReportReasonCellViewModeling] = []
                for reason in reasons {
                    viewModels.append(OWReportReasonCellViewModel(reason: reason))
                }
                return viewModels
            }
            .asObservable()
}

#endif
