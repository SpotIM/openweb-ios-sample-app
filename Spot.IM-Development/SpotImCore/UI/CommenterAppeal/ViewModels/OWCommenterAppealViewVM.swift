//
//  OWCommenterAppealViewVM.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 01/11/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift
import UIKit

protocol OWCommenterAppealViewViewModelingInputs {
    var closeOrCancelClick: PublishSubject<Void> { get }
    var reasonIndexSelect: BehaviorSubject<Int?> { get }
    var textViewTextChange: PublishSubject<String> { get }
}

protocol OWCommenterAppealViewViewModelingOutputs {
    var closeButtonPopped: Observable<Void> { get }
    var cancelAppeal: Observable<Void> { get }
    var textViewVM: OWTextViewViewModeling { get }
    var appealCellViewModels: Observable<[OWAppealCellViewModeling]> { get }
    var selectedReason: Observable<OWReportReason> { get }
    var submitButtonText: Observable<String> { get }
    var submitInProgress: Observable<Bool> { get }
    var isSubmitEnabled: Observable<Bool> { get }
}

protocol OWCommenterAppealViewViewModeling {
    var inputs: OWCommenterAppealViewViewModelingInputs { get }
    var outputs: OWCommenterAppealViewViewModelingOutputs { get }
}

class OWCommenterAppealViewVM: OWCommenterAppealViewViewModeling,
                               OWCommenterAppealViewViewModelingInputs,
                               OWCommenterAppealViewViewModelingOutputs {
    fileprivate struct Metrics {
        static let defaultTextViewMaxCharecters = 280
    }

    var inputs: OWCommenterAppealViewViewModelingInputs { return self }
    var outputs: OWCommenterAppealViewViewModelingOutputs { return self }

    fileprivate var disposeBag: DisposeBag
    fileprivate let servicesProvider: OWSharedServicesProviding

    let textViewVM: OWTextViewViewModeling

    init(servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.servicesProvider = servicesProvider
        disposeBag = DisposeBag()
        let textViewData = OWTextViewData(textViewMaxCharecters: Metrics.defaultTextViewMaxCharecters,
                                          placeholderText: "",
                                          charectersLimitEnabled: false,
                                          isEditable: false)
        self.textViewVM = OWTextViewViewModel(textViewData: textViewData)
        setupObservers()
    }

    var closeOrCancelClick = PublishSubject<Void>()
    fileprivate var isDismissEnable: Observable<Bool> {
        // Dismiss only if no text was added
        return textViewVM.outputs.textViewText
            .map { $0.isEmpty }
            .startWith(true)
    }
    var cancelAppeal: Observable<Void> {
        return closeOrCancelClick
            .withLatestFrom(isDismissEnable) { _, enable in
                return enable
            }
            .filter { !$0 }
            .voidify()
    }
    var closeButtonPopped: Observable<Void> {
        return closeOrCancelClick
            .withLatestFrom(isDismissEnable) { _, enable in
                return enable
            }
            .filter { $0 }
            .voidify()
    }

    // TODO: where do we get it from?
    lazy var appealOptions: Observable<[OWReportReason]> = {
        self.servicesProvider.spotConfigurationService()
            .config(spotId: OWManager.manager.spotId)
            .map { $0.shared?.reportReasonsOptions?.reportReasons }
            .unwrap()
            .asObservable()
            .share(replay: 1)
    }()

    lazy var appealCellViewModels: Observable<[OWAppealCellViewModeling]> = {
        appealOptions
            .map { reasons in
                var viewModels: [OWAppealCellViewModeling] = []
                for reason in reasons {
                    viewModels.append(OWAppealCellViewModel(reason: reason))
                }
                return viewModels
            }
            .asObservable()
    }()

    var textViewTextChange = PublishSubject<String>()

    var reasonIndexSelect = BehaviorSubject<Int?>(value: nil)
    lazy var selectedReason: Observable<OWReportReason> = {
        reasonIndexSelect
            .skip(1)
            .unwrap()
            .flatMap { [weak self] index -> Observable<OWReportReason> in
                guard let self = self else { return .empty() }
                return self.appealOptions
                    .map { $0[index] }
            }
            .share(replay: 1)
    }()

    fileprivate var _submitInProgress = PublishSubject<Bool>()
    var submitInProgress: Observable<Bool> {
        return _submitInProgress
            .asObservable()
    }

    fileprivate var isError = BehaviorSubject<Bool>(value: false)
    var submitButtonText: Observable<String> {
        return isError
            .map { error in
                return OWLocalizationManager.shared.localizedString(key: error ? "TryAgain" : "Appeal")
            }
    }

    fileprivate var _isSubmitEnabled = PublishSubject<Bool>()
    var isSubmitEnabled: Observable<Bool> {
        return Observable.combineLatest(selectedReason, textViewVM.outputs.textViewText)
            .map { reason, text -> Bool in
                guard reason.requiredAdditionalInfo else { return true }
                return text.count > 0
            }
            .asObservable()
    }
}

fileprivate extension OWCommenterAppealViewVM {
    func setupObservers() {
        selectedReason
            .map {
                if $0.requiredAdditionalInfo == false {
                    return OWLocalizationManager.shared.localizedString(key: "ReportReasonTextViewPlaceholder")
                } else {
                    return OWLocalizationManager.shared.localizedString(key: "ReportReasonTextViewMandatoryPlaceholder")
                }
            }
            .bind(to: textViewVM.inputs.placeholderTextChange)
            .disposed(by: disposeBag)

        textViewTextChange
            .bind(to: textViewVM.inputs.textExternalChange)
            .disposed(by: disposeBag)

        selectedReason
            .filter { $0.requiredAdditionalInfo == true }
            .voidify()
            .bind(to: textViewVM.inputs.textViewTap)
            .disposed(by: disposeBag)
    }
}
