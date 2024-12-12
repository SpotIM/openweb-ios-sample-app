//
//  OWSubmittedViewVM.swift
//  OpenWebSDK
//
//  Created by Refael Sommer on 24/04/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
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

    private struct Metrics {
        static let titleIconName = "ReportReasonSubmittedIcon"
        static let titleViewPrefixIdentifier = "submitted"
    }

    var inputs: OWSubmittedViewViewModelingInputs { return self }
    var outputs: OWSubmittedViewViewModelingOutputs { return self }

    private let disposeBag = DisposeBag()
    private let type: OWSubmittedViewType
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
        return OWLocalize.string("ReportReasonSubmittedTitle")
    }

    var subtitle: String {
        switch type {
        case .reportReason:
            return OWLocalize.string("ReportReasonSubmittedSubtitle")
        case .commenterAppeal:
            return OWLocalize.string("AppealSubmittedSubtitle")
        }
    }

    var titleIconName: String {
        return Metrics.titleIconName
    }

    var confirmButtonText: String {
        return OWLocalize.string("GotIt")
    }

    var closeSubmittedTap = PublishSubject<Void>()
    var closeSubmittedTapped: Observable<Void> {
        return closeSubmittedTap.asObservable()
    }
}
