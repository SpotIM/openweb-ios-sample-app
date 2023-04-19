//
//  OWReportReasonVM.swift
//  SpotImCore
//
//  Created by Refael Sommer on 17/04/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

#if NEW_API

public protocol OWReportReasonViewModelingInputs {
}

public protocol OWReportReasonViewModelingOutputs {
    var reportReasonViewViewModel: OWReportReasonViewViewModeling { get }
}

public protocol OWReportReasonViewModeling {
    var inputs: OWReportReasonViewModelingInputs { get }
    var outputs: OWReportReasonViewModelingOutputs { get }
}

public class OWReportReasonViewModel: OWReportReasonViewModeling, OWReportReasonViewModelingInputs, OWReportReasonViewModelingOutputs {
    public var inputs: OWReportReasonViewModelingInputs { return self }
    public var outputs: OWReportReasonViewModelingOutputs { return self }

    lazy public var reportReasonViewViewModel: OWReportReasonViewViewModeling = {
        return OWReportReasonViewViewModel()
    }()

    public init () {
        setupObservers()
    }
}

fileprivate extension OWReportReasonViewModel {
    func setupObservers() {
    }
}

#endif
