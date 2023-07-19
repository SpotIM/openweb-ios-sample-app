//
//  OWReportReasonSubmittedViewVM.swift
//  SpotImCore
//
//  Created by Refael Sommer on 24/04/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWReportReasonSubmittedViewViewModelingInputs {
    var closeReportReasonSubmittedTap: PublishSubject<Void> { get }
}

protocol OWReportReasonSubmittedViewViewModelingOutputs {
    var closeReportReasonSubmittedTapped: Observable<Void> { get }
    var confirmButtonText: String { get }
    var titleViewVM: OWTitleSubtitleIconViewModeling { get }
}

protocol OWReportReasonSubmittedViewViewModeling {
    var inputs: OWReportReasonSubmittedViewViewModelingInputs { get }
    var outputs: OWReportReasonSubmittedViewViewModelingOutputs { get }
}

class OWReportReasonSubmittedViewViewModel: OWReportReasonSubmittedViewViewModelingInputs, OWReportReasonSubmittedViewViewModelingOutputs, OWReportReasonSubmittedViewViewModeling {

    fileprivate struct Metrics {
        static let titleIconName = "ReportReasonSubmittedIcon"
        static let titleViewPrefixIdentifier = "report_reason_submitted"
    }

    var inputs: OWReportReasonSubmittedViewViewModelingInputs { return self }
    var outputs: OWReportReasonSubmittedViewViewModelingOutputs { return self }

    fileprivate let disposeBag = DisposeBag()

    var titleViewVM: OWTitleSubtitleIconViewModeling {
        return OWTitleSubtitleIconViewModel(iconName: titleIconName,
                                            title: title,
                                            subtitle: subtitle,
                                            accessibilityPrefixId: Metrics.titleViewPrefixIdentifier)
    }

    var title: String {
        return OWLocalizationManager.shared.localizedString(key: "ReportReasonSubmittedTitle")
    }

    var subtitle: String {
        return OWLocalizationManager.shared.localizedString(key: "ReportReasonSubmittedSubtitle")
    }

    var titleIconName: String {
        return Metrics.titleIconName
    }

    var confirmButtonText: String {
        return OWLocalizationManager.shared.localizedString(key: "Got it")
    }

    var closeReportReasonSubmittedTap = PublishSubject<Void>()
    var closeReportReasonSubmittedTapped: Observable<Void> {
        return closeReportReasonSubmittedTap.asObservable()
    }
}
