//
//  OWReportReasonCancelViewVM.swift
//  SpotImCore
//
//  Created by Refael Sommer on 24/04/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWReportReasonCancelViewViewModelingInputs {
    var closeReportReasonCancelTap: PublishSubject<Void> { get }
    var cancelReportReasonCancelTap: PublishSubject<Void> { get }
}

protocol OWReportReasonCancelViewViewModelingOutputs {
    var title: String { get }
    var subtitle: String { get }
    var titleIconName: String { get }
    var continueButtonText: String { get }
    var cancelButtonText: String { get }
    var closeReportReasonCancelTapped: Observable<Void> { get }
    var cancelReportReasonCancelTapped: Observable<Void> { get }
    var trashIconName: String { get }
}

protocol OWReportReasonCancelViewViewModeling {
    var inputs: OWReportReasonCancelViewViewModelingInputs { get }
    var outputs: OWReportReasonCancelViewViewModelingOutputs { get }
}

class OWReportReasonCancelViewViewModel: OWReportReasonCancelViewViewModelingInputs, OWReportReasonCancelViewViewModelingOutputs, OWReportReasonCancelViewViewModeling {

    fileprivate struct Metrics {
        static let titleKey = "ReportReasonCancelTitle"
        static let subtitleKey = "ReportReasonCancelSubtitle"
        static let titleIconName = "ReportReasonCancelIcon"
        static let continueButtonKey = "ReportReasonCancelContinueButton"
        static let cancelButtonKey = "ReportReasonCancelCancelButton"
        static let trashIcon = "ReportReasonTrashIcon"
    }

    var inputs: OWReportReasonCancelViewViewModelingInputs { return self }
    var outputs: OWReportReasonCancelViewViewModelingOutputs { return self }

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

    var trashIconName: String {
        return Metrics.trashIcon
    }

    var continueButtonText: String {
        return OWLocalizationManager.shared.localizedString(key: Metrics.continueButtonKey)
    }

    var cancelButtonText: String {
        return OWLocalizationManager.shared.localizedString(key: Metrics.cancelButtonKey)
    }

    var closeReportReasonCancelTap = PublishSubject<Void>()
    var closeReportReasonCancelTapped: Observable<Void> {
        return closeReportReasonCancelTap.asObservable()
    }

    var cancelReportReasonCancelTap = PublishSubject<Void>()
    var cancelReportReasonCancelTapped: Observable<Void> {
        return cancelReportReasonCancelTap.asObservable()
    }
}
