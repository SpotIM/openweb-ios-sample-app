//
//  OWCancelViewVM.swift
//  OpenWebSDK
//
//  Created by Refael Sommer on 24/04/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation
import RxSwift

protocol OWCancelViewViewModelingInputs {
    var closeTap: PublishSubject<Void> { get }
    var cancelTap: PublishSubject<Void> { get }
}

protocol OWCancelViewViewModelingOutputs {
    var titleViewVM: OWTitleSubtitleIconViewModeling { get }
    var continueButtonText: String { get }
    var cancelButtonText: String { get }
    var closeTapped: Observable<Void> { get }
    var cancelTapped: Observable<Void> { get }
    var trashIconName: String { get }
}

protocol OWCancelViewViewModeling {
    var inputs: OWCancelViewViewModelingInputs { get }
    var outputs: OWCancelViewViewModelingOutputs { get }
}

class OWCancelViewViewModel: OWCancelViewViewModelingInputs, OWCancelViewViewModelingOutputs, OWCancelViewViewModeling {

    private struct Metrics {
        static let trashIcon = "ReportReasonTrashIcon"
        static let titleIconName = "ReportReasonCancelIcon"
        static let titleViewPrefixIdentifier = "cancel"
    }

    var inputs: OWCancelViewViewModelingInputs { return self }
    var outputs: OWCancelViewViewModelingOutputs { return self }

    private let disposeBag = DisposeBag()
    private let type: OWCancelScreenType

    init(type: OWCancelScreenType) {
        self.type = type
    }

    var titleViewVM: OWTitleSubtitleIconViewModeling {
        return OWTitleSubtitleIconViewModel(iconName: titleIconName,
                                            title: title,
                                            subtitle: subtitle,
                                            accessibilityPrefixId: Metrics.titleViewPrefixIdentifier)
    }

    var title: String {
        switch type {
        case .reportReason:
            return OWLocalize.string("ReportReasonCancelTitle")
        case .commenterAppeal:
            return OWLocalize.string("CancelAppeal")
        }
    }

    var subtitle: String {
        switch type {
        case .reportReason:
            return OWLocalize.string("ReportReasonCancelSubtitle")
        case .commenterAppeal:
            return OWLocalize.string("CommmenterAppealCancelSubtitle")
        }
    }

    var titleIconName: String {
        return Metrics.titleIconName
    }

    var trashIconName: String {
        return Metrics.trashIcon
    }

    var continueButtonText: String {
        switch type {
        case .reportReason:
            return OWLocalize.string("ReportReasonCancelContinueButton")
        case .commenterAppeal:
            return OWLocalize.string("CommenterAppealCancelContinueButton")
        }
    }

    var cancelButtonText: String {
        switch type {
        case .reportReason:
            return OWLocalize.string("ReportReasonCancelCancelButton")
        case .commenterAppeal:
            return OWLocalize.string("CancelAppeal")
        }
    }

    var closeTap = PublishSubject<Void>()
    var closeTapped: Observable<Void> {
        return closeTap.asObservable()
    }

    var cancelTap = PublishSubject<Void>()
    var cancelTapped: Observable<Void> {
        return cancelTap.asObservable()
    }
}
