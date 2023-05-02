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
    var cancelReportReasonTap: PublishSubject<Void> { get }
    var submitReportReasonTap: PublishSubject<Void> { get }
    var reasonIndexSelect: BehaviorSubject<Int?> { get }
}

protocol OWReportReasonViewViewModelingOutputs {
    var titleText: String { get }
    var cancelButtonText: String { get }
    var submitButtonText: String { get }
    var tableViewHeaderText: String { get }
    var reportReasonCellViewModels: Observable<[OWReportReasonCellViewModeling]> { get }
    var shouldShowTitleView: Bool { get }
    var closeReportReasonTapped: Observable<Void> { get }
    var cancelReportReasonTapped: Observable<Void> { get }
    var submitReportReasonTapped: Observable<Void> { get }
    var textViewVM: OWTextViewViewModeling { get }
    var selectedReason: Observable<OWReportReason?> { get }
}

protocol OWReportReasonViewViewModeling {
    var inputs: OWReportReasonViewViewModelingInputs { get }
    var outputs: OWReportReasonViewViewModelingOutputs { get }
}

class OWReportReasonViewViewModel: OWReportReasonViewViewModelingInputs, OWReportReasonViewViewModelingOutputs, OWReportReasonViewViewModeling {
    fileprivate struct Metrics {
        static let titleKey = "ReportReasonTitle"
        static let textViewPlaceholderKey = "ReportReasonTextViewPlaceholder"
        static let textViewMandatoryPlaceholderKey = "ReportReasonTextViewMandatoryPlaceholder"
        static let cancelKey = "Cancel"
        static let submitKey = "Submit"
        static let tableViewHeaderKey = "ReportReasonHelpUsTitle"
        static let textViewMaxCharecters = 280
    }

    var titleText: String {
        return LocalizationManager.localizedString(key: Metrics.titleKey)
    }

    var cancelButtonText: String {
        return LocalizationManager.localizedString(key: Metrics.cancelKey)
    }

    var submitButtonText: String {
        return LocalizationManager.localizedString(key: Metrics.submitKey)
    }

    var tableViewHeaderText: String {
        return LocalizationManager.localizedString(key: Metrics.tableViewHeaderKey)
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

    var cancelReportReasonTap = PublishSubject<Void>()
    var cancelReportReasonTapped: Observable<Void> {
        return cancelReportReasonTap.asObservable()
    }

    var submitReportReasonTap = PublishSubject<Void>()
    var submitReportReasonTapped: Observable<Void> {
        return submitReportReasonTap.asObservable()
    }

    var reasonIndexSelect = BehaviorSubject<Int?>(value: nil)

    let textViewVM: OWTextViewViewModeling

    init(viewableMode: OWViewableMode, presentationalMode: OWPresentationalModeCompact, servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.viewableMode = viewableMode
        self.presentationalMode = presentationalMode
        self.servicesProvider = servicesProvider
        self.textViewVM = OWTextViewViewModel(textViewMaxCharecters: Metrics.textViewMaxCharecters,
                                              placeholderText: LocalizationManager.localizedString(key: Metrics.textViewPlaceholderKey),
                                              isEditable: false)
        setupObservers()
    }

    var shouldShowTitleView: Bool {
        return viewableMode == .independent
    }

    lazy var reportReasons: Observable<[OWReportReason]> =
        self.servicesProvider.spotConfigurationService()
            .config(spotId: OWManager.manager.spotId)
            .map { $0.shared?.reportReasonsOptions?.reasonsList }
            .unwrap()
            .asObservable()

    lazy var reportReasonCellViewModels: Observable<[OWReportReasonCellViewModeling]> =
        reportReasons
            .map { reasons in
                var viewModels: [OWReportReasonCellViewModeling] = []
                for reason in reasons {
                    viewModels.append(OWReportReasonCellViewModel(reason: reason))
                }
                return viewModels
            }
            .asObservable()

    lazy var selectedReason: Observable<OWReportReason?> =
        Observable.combineLatest(reportReasons, reasonIndexSelect)
            .map { (reasons, selectedIndex) in
                guard let index = selectedIndex else { return nil }
                return reasons[index]
            }
            .asObservable()
}

fileprivate extension OWReportReasonViewViewModel {
    func setupObservers() {
        selectedReason
            .map {
                if $0 == nil || $0?.requiredAdditionalInfo == false {
                    return LocalizationManager.localizedString(key: Metrics.textViewPlaceholderKey)
                } else {
                    return LocalizationManager.localizedString(key: Metrics.textViewMandatoryPlaceholderKey)
                }
            }
            .bind(to: textViewVM.inputs.placeholderTextChange)
            .disposed(by: disposeBag)
    }
}

#endif
