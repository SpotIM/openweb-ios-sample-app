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
    var title: String { get }
    var viewableMode: OWViewableMode { get }
}

protocol OWReportReasonViewModeling {
    var inputs: OWReportReasonViewModelingInputs { get }
    var outputs: OWReportReasonViewModelingOutputs { get }
}

class OWReportReasonViewModel: OWReportReasonViewModeling, OWReportReasonViewModelingInputs, OWReportReasonViewModelingOutputs {
    fileprivate struct Metrics {
        static let titleKey = "ReportReasonTitle"
    }

    var inputs: OWReportReasonViewModelingInputs { return self }
    var outputs: OWReportReasonViewModelingOutputs { return self }

    var viewDidLoad = PublishSubject<Void>()
    var loadedToScreen: Observable<Void> {
        return viewDidLoad.asObservable()
    }

    let viewableMode: OWViewableMode
    let presentationalMode: OWPresentationalModeCompact

    lazy var reportReasonViewViewModel: OWReportReasonViewViewModeling = {
        return OWReportReasonViewViewModel(viewableMode: viewableMode, presentationalMode: presentationalMode)
    }()

    var title: String {
        return LocalizationManager.localizedString(key: Metrics.titleKey)
    }

    init (viewableMode: OWViewableMode, presentMode: OWPresentationalModeCompact) {
        self.viewableMode = viewableMode
        self.presentationalMode = presentMode
    }
}

#endif
