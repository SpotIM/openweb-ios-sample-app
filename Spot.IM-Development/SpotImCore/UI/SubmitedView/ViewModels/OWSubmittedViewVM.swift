//
//  OWSubmittedViewVM.swift
//  SpotImCore
//
//  Created by Refael Sommer on 24/04/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWSubmittedViewViewModelingInputs {
    var closeSubmittedTap: PublishSubject<Void> { get }
}

protocol OWSubmittedViewViewModelingOutputs {
    var closeSubmittedTapped: Observable<Void> { get }
    var confirmButtonText: String { get }
    var titleViewVM: OWTitleSubtitleIconViewModeling { get }
}

protocol OWSubmittedViewViewModeling {
    var inputs: OWSubmittedViewViewModelingInputs { get }
    var outputs: OWSubmittedViewViewModelingOutputs { get }
}

class OWSubmittedViewViewModel: OWSubmittedViewViewModelingInputs, OWSubmittedViewViewModelingOutputs, OWSubmittedViewViewModeling {

    fileprivate struct Metrics {
        static let titleIconName = "ReportReasonSubmittedIcon"
        static let titleViewPrefixIdentifier = "submitted"
    }

    var inputs: OWSubmittedViewViewModelingInputs { return self }
    var outputs: OWSubmittedViewViewModelingOutputs { return self }

    fileprivate let disposeBag = DisposeBag()
    fileprivate let type: OWSubmittedViewType
    init(type: OWSubmittedViewType) {
        self.type = type
    }

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
        switch type {
        case .reportReason:
            return OWLocalizationManager.shared.localizedString(key: "ReportReasonSubmittedSubtitle")
        case .commenterAppeal:
            return "We've received your appeal and our moderation team will review your comment as soon as possible. We will notify you about the decision." // TODO: translations
        }
    }

    var titleIconName: String {
        return Metrics.titleIconName
    }

    var confirmButtonText: String {
        return OWLocalizationManager.shared.localizedString(key: "GotIt")
    }

    var closeSubmittedTap = PublishSubject<Void>()
    var closeSubmittedTapped: Observable<Void> {
        return closeSubmittedTap.asObservable()
    }
}
