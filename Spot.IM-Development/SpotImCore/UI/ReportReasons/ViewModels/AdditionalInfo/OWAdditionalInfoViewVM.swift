//
//  OWAdditionalInfoVM.swift
//  SpotImCore
//
//  Created by Refael Sommer on 01/05/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWAdditionalInfoViewViewModelingInputs {
    var cancelAdditionalInfoTap: PublishSubject<Void> { get }
    var closeAdditionalInfoTap: PublishSubject<Void> { get }
    var submitAdditionalInfoTap: PublishSubject<Void> { get }
    var additionalInfoTextChange: PublishSubject<String> { get }
    var submitInProgress: PublishSubject<Bool> { get }
}

protocol OWAdditionalInfoViewViewModelingOutputs {
    var closeAdditionalInfoTapped: Observable<Void> { get }
    var closeReportReasonTapped: Observable<Void> { get }
    var cancelAdditionalInfoTapped: Observable<Void> { get }
    var submitAdditionalInfoTapped: Observable<Void> { get }
    var additionalInfoTextChanged: Observable<String> { get }
    var textViewVM: OWTextViewViewModeling { get }
    var cancelButtonText: String { get }
    var submitButtonText: String { get }
    var titleText: String { get }
    var shouldShowTitleView: Bool { get }
    var viewableMode: OWViewableMode { get }
    var submitInProgressChanged: Observable<Bool> { get }
    var isSubmitEnabled: Observable<Bool> { get }
}

protocol OWAdditionalInfoViewViewModeling {
    var inputs: OWAdditionalInfoViewViewModelingInputs { get }
    var outputs: OWAdditionalInfoViewViewModelingOutputs { get }
}

class OWAdditionalInfoViewViewModel: OWAdditionalInfoViewViewModelingInputs, OWAdditionalInfoViewViewModelingOutputs, OWAdditionalInfoViewViewModeling {

    fileprivate struct Metrics {
        static let titleKey = "AdditionalInfoTitle"
        static let cancelKey = "Cancel"
        static let submitKey = "Submit"
        static let textViewMaxCharecters = 280
    }

    fileprivate var disposeBag = DisposeBag()

    var inputs: OWAdditionalInfoViewViewModelingInputs { return self }
    var outputs: OWAdditionalInfoViewViewModelingOutputs { return self }

    var titleText: String {
        return LocalizationManager.localizedString(key: Metrics.titleKey)
    }

    var cancelButtonText: String {
        return LocalizationManager.localizedString(key: Metrics.cancelKey)
    }

    var submitButtonText: String {
        return LocalizationManager.localizedString(key: Metrics.submitKey)
    }

    var closeAdditionalInfoTap = PublishSubject<Void>()
    var closeAdditionalInfoTapped: Observable<Void> {
        return closeAdditionalInfoTap
            .asObservable()
    }

    var submitInProgress = PublishSubject<Bool>()
    var submitInProgressChanged: Observable<Bool> {
        return submitInProgress
            .asObservable()
    }

    var cancelAdditionalInfoTap = PublishSubject<Void>()
    var cancelAdditionalInfoTapped: Observable<Void> {
        return cancelAdditionalInfoTap
            .flatMap { [weak self] _ -> Observable<String> in
                guard let self = self else { return .empty() }
                return self.textViewVM.outputs.textViewText
                    .take(1)
            }
            .filter { !$0.isEmpty }
            .voidify()
            .asObservable()
    }

    var closeReportReasonTapped: Observable<Void> {
        return cancelAdditionalInfoTap
            .flatMap { [weak self] _ -> Observable<String> in
                guard let self = self else { return .empty() }
                return self.textViewVM.outputs.textViewText
                    .take(1)
            }
            .filter { $0.isEmpty }
            .voidify()
            .asObservable()
    }

    var submitAdditionalInfoTap = PublishSubject<Void>()
    var submitAdditionalInfoTapped: Observable<Void> {
        return submitAdditionalInfoTap.asObservable()
    }

    var additionalInfoTextChange = PublishSubject<String>()
    var additionalInfoTextChanged: Observable<String> {
        return additionalInfoTextChange.asObservable()
    }

    var shouldShowTitleView: Bool {
        return viewableMode == .independent
    }

    var isSubmitEnabledChange = BehaviorSubject<Bool>(value: false)
    var isSubmitEnabled: Observable<Bool> {
        return isSubmitEnabledChange
            .asObservable()
    }

    let textViewVM: OWTextViewViewModeling
    let viewableMode: OWViewableMode

    init(viewableMode: OWViewableMode,
         placeholderText: String,
         textViewText: String,
         textViewMaxCharecters: Int = Metrics.textViewMaxCharecters,
         isTextRequired: Observable<Bool>,
         submitInProgress: Observable<Bool>) {
        self.viewableMode = viewableMode
        self.textViewVM = OWTextViewViewModel(textViewMaxCharecters: textViewMaxCharecters,
                                              placeholderText: placeholderText,
                                              textViewText: textViewText,
                                              isEditable: true)
        setupObservers(submitInProgress: submitInProgress, isTextRequired: isTextRequired)
    }
}

fileprivate extension OWAdditionalInfoViewViewModel {
    func setupObservers(submitInProgress: Observable<Bool>, isTextRequired: Observable<Bool>) {
        submitInProgress
            .bind(to: self.inputs.submitInProgress)
            .disposed(by: disposeBag)

        isTextRequired
            .flatMap { [weak self] isTextRequired -> Observable<Bool> in
                guard let self = self else { return .empty() }
                return self.textViewVM.outputs.textViewText.map {
                    isTextRequired && !$0.isEmpty || !isTextRequired
                }
            }
            .bind(to: isSubmitEnabledChange)
            .disposed(by: disposeBag)
    }
}
