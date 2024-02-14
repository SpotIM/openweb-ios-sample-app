//
//  OWReportReasonCancelViewVM.swift
//  SpotImCore
//
//  Created by Refael Sommer on 24/04/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation
import RxSwift

protocol OWReportReasonCancelViewViewModelingInputs {
    var closeReportReasonCancelTap: PublishSubject<Void> { get }
    var cancelReportReasonCancelTap: PublishSubject<Void> { get }
}

protocol OWReportReasonCancelViewViewModelingOutputs {
    var titleViewVM: OWTitleSubtitleIconViewModeling { get }
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
        static let trashIcon = "ReportReasonTrashIcon"
        static let titleIconName = "ReportReasonCancelIcon"
        static let titleViewPrefixIdentifier = "report_reason_cancel"
    }

    var inputs: OWReportReasonCancelViewViewModelingInputs { return self }
    var outputs: OWReportReasonCancelViewViewModelingOutputs { return self }

    fileprivate let disposeBag = DisposeBag()

    var titleViewVM: OWTitleSubtitleIconViewModeling {
        return OWTitleSubtitleIconViewModel(iconName: titleIconName,
                                            title: title,
                                            subtitle: subtitle,
                                            accessibilityPrefixId: Metrics.titleViewPrefixIdentifier)
    }

    var title: String {
        return OWLocalizationManager.shared.localizedString(key: "ReportReasonCancelTitle")
    }

    var subtitle: String {
        return OWLocalizationManager.shared.localizedString(key: "ReportReasonCancelSubtitle")
    }

    var titleIconName: String {
        return Metrics.titleIconName
    }

    var trashIconName: String {
        return Metrics.trashIcon
    }

    var continueButtonText: String {
        return OWLocalizationManager.shared.localizedString(key: "ReportReasonCancelContinueButton")
    }

    var cancelButtonText: String {
        return OWLocalizationManager.shared.localizedString(key: "ReportReasonCancelCancelButton")
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
