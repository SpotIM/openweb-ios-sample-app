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

protocol OWReportReasonViewModelingInputs {
    var viewDidLoad: PublishSubject<Void> { get }
}

protocol OWReportReasonViewModelingOutputs {
    var reportReasonViewViewModel: OWReportReasonViewViewModeling { get }
    var loadedToScreen: Observable<Void> { get }
}

protocol OWReportReasonViewModeling {
    var inputs: OWReportReasonViewModelingInputs { get }
    var outputs: OWReportReasonViewModelingOutputs { get }
}

class OWReportReasonViewModel: OWReportReasonViewModeling, OWReportReasonViewModelingInputs, OWReportReasonViewModelingOutputs {
    var inputs: OWReportReasonViewModelingInputs { return self }
    var outputs: OWReportReasonViewModelingOutputs { return self }

    var viewDidLoad = PublishSubject<Void>()
    var loadedToScreen: Observable<Void> {
        return viewDidLoad.asObservable()
    }

    lazy var reportReasonViewViewModel: OWReportReasonViewViewModeling = {
        return OWReportReasonViewViewModel()
    }()

    init () {
        setupObservers()
    }
}

fileprivate extension OWReportReasonViewModel {
    func setupObservers() {
    }
}

#endif
