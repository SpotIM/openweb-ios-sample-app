//
//  OWCancelViewVM.swift
//  SpotImCore
//
//  Created by Refael Sommer on 24/04/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
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

    fileprivate struct Metrics {
        static let trashIcon = "ReportReasonTrashIcon"
        static let titleIconName = "ReportReasonCancelIcon"
        static let titleViewPrefixIdentifier = "cancel"
    }

    var inputs: OWCancelViewViewModelingInputs { return self }
    var outputs: OWCancelViewViewModelingOutputs { return self }

    fileprivate let disposeBag = DisposeBag()
    fileprivate let type: OWCancelScreenType

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
            return OWLocalizationManager.shared.localizedString(key: "ReportReasonCancelTitle")
        case .commenterAppeal:
            return "Cancel Appeal" // TODO: translations
        }
    }

    var subtitle: String {
        switch type {
        case .reportReason:
            return OWLocalizationManager.shared.localizedString(key: "ReportReasonCancelSubtitle")
        case .commenterAppeal:
            return "Are you sure you want to cancel your appeal and delete the reason you provided?" // TODO: translations
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
            return OWLocalizationManager.shared.localizedString(key: "ReportReasonCancelContinueButton")
        case .commenterAppeal:
            return "Continue appealing" // TODO: translations
        }
    }

    var cancelButtonText: String {
        switch type {
        case .reportReason:
            return OWLocalizationManager.shared.localizedString(key: "ReportReasonCancelCancelButton")
        case .commenterAppeal:
            return "Cancel Appeal" // TODO: translations
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
