//
//  OWReportReasonThanksViewVM.swift
//  SpotImCore
//
//  Created by Refael Sommer on 24/04/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWReportReasonThanksViewViewModelingInputs {
    var closeReportReasonThanksTap: PublishSubject<Void> { get }
}

protocol OWReportReasonThanksViewViewModelingOutputs {
    var title: String { get }
    var subtitle: String { get }
    var titleIconName: String { get }
    var continueButtonText: String { get }
    var closeReportReasonThanksTapped: Observable<Void> { get }
    var gotitButtonText: String { get }
}

protocol OWReportReasonThanksViewViewModeling {
    var inputs: OWReportReasonThanksViewViewModelingInputs { get }
    var outputs: OWReportReasonThanksViewViewModelingOutputs { get }
}

class OWReportReasonThanksViewViewModel: OWReportReasonThanksViewViewModelingInputs, OWReportReasonThanksViewViewModelingOutputs, OWReportReasonThanksViewViewModeling {

    fileprivate struct Metrics {
        static let titleKey = "ReportReasonThanksTitle"
        static let subtitleKey = "ReportReasonThanksSubtitle"
        static let titleIconName = "ReportReasonThanksIcon"
        static let continueButtonKey = "Got it"
        static let gotitKey = "Got it"
    }

    var inputs: OWReportReasonThanksViewViewModelingInputs { return self }
    var outputs: OWReportReasonThanksViewViewModelingOutputs { return self }

    fileprivate let disposeBag = DisposeBag()

    var title: String {
        return OWLocalizationManager.shared.localizedString(key: Metrics.titleKey)
    }

    var subtitle: String {
        return OWLocalizationManager.shared.localizedString(key: Metrics.subtitleKey)
    }

    var titleIconName: String {
        return Metrics.titleIconName
    }

    var continueButtonText: String {
        return OWLocalizationManager.shared.localizedString(key: Metrics.continueButtonKey)
    }

    var gotitButtonText: String {
        return OWLocalizationManager.shared.localizedString(key: Metrics.gotitKey)
    }

    var closeReportReasonThanksTap = PublishSubject<Void>()
    var closeReportReasonThanksTapped: Observable<Void> {
        return closeReportReasonThanksTap.asObservable()
    }
}
