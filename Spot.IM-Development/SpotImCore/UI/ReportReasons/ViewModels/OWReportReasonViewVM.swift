//
//  OWReportReasonVM.swift
//  SpotImCore
//
//  Created by Refael Sommer on 16/04/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

#if NEW_API

protocol OWReportReasonViewViewModelingInputs {
    var closeReportReasonTap: PublishSubject<Void> { get }
}

protocol OWReportReasonViewViewModelingOutputs {
    var title: String { get }
    var reportReasonCellViewModels: Observable<[OWReportReasonCellViewModeling]> { get }
    var shouldShowTitleView: Bool { get }
    var closeReportReasonTapped: Observable<Void> { get }
}

protocol OWReportReasonViewViewModeling {
    var inputs: OWReportReasonViewViewModelingInputs { get }
    var outputs: OWReportReasonViewViewModelingOutputs { get }
}

class OWReportReasonViewViewModel: OWReportReasonViewViewModelingInputs, OWReportReasonViewViewModelingOutputs, OWReportReasonViewViewModeling {

    fileprivate struct Metrics {
        static let titleKey = "ReportReasonTitle"
        static let textViewPlaceholderKey = "ReportReasonTextViewPlaceholder"
    }

    var title: String {
        return LocalizationManager.localizedString(key: Metrics.titleKey)
    }

    var textViewPlaceholder: String {
        return LocalizationManager.localizedString(key: Metrics.textViewPlaceholderKey)
    }

    var inputs: OWReportReasonViewViewModelingInputs { return self }
    var outputs: OWReportReasonViewViewModelingOutputs { return self }

    fileprivate let disposeBag = DisposeBag()
    fileprivate let servicesProvider: OWSharedServicesProviding
    fileprivate let viewableMode: OWViewableMode
    fileprivate let presentationalMode: OWPresentationalModeCompact

    var closeReportReasonTap = PublishSubject<Void>()
    var closeReportReasonTapped: Observable<Void> {
        return closeReportReasonTap.asObservable()
    }

    init(viewableMode: OWViewableMode, presentationalMode: OWPresentationalModeCompact, servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.viewableMode = viewableMode
        self.presentationalMode = presentationalMode
        self.servicesProvider = servicesProvider
    }

    var shouldShowTitleView: Bool {
        return viewableMode == .independent
    }

    lazy var reportReasonCellViewModels: Observable<[OWReportReasonCellViewModeling]> =
        self.servicesProvider.spotConfigurationService()
            .config(spotId: OWManager.manager.spotId)
            .map { $0.shared?.reportReasonsOptions?.reasonsList }
            .unwrap()
            .map { reasons in
                var viewModels: [OWReportReasonCellViewModeling] = []
                for reason in reasons {
                    viewModels.append(OWReportReasonCellViewModel(reason: reason))
                }
                return viewModels
            }
            .asObservable()
}

#endif
