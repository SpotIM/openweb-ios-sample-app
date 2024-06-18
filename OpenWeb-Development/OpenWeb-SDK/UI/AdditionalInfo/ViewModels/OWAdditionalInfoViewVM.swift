//
//  OWAdditionalInfoVM.swift
//  OpenWebSDK
//
//  Created by Refael Sommer on 01/05/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation
import RxSwift

protocol OWAdditionalInfoViewViewModelingInputs {
    var cancelAdditionalInfoTap: PublishSubject<Void> { get }
    var closeAdditionalInfoTap: PublishSubject<Void> { get }
    var submitAdditionalInfoTap: PublishSubject<Void> { get }
    var additionalInfoTextChange: PublishSubject<String> { get }
    var submitInProgress: PublishSubject<Bool> { get }
    var submitButtonTextChanged: BehaviorSubject<String> { get }
}

protocol OWAdditionalInfoViewViewModelingOutputs {
    var closeAdditionalInfoTapped: Observable<Void> { get }
    var closeReportReasonTapped: Observable<Void> { get }
    var cancelAdditionalInfoTapped: Observable<Void> { get }
    var submitAdditionalInfoTapped: Observable<Void> { get }
    var additionalInfoTextChanged: Observable<String> { get }
    var textViewVM: OWTextViewViewModeling { get }
    var titleViewVM: OWTitleViewViewModeling { get }
    var cancelButtonText: String { get }
    var submitButtonText: Observable<String> { get }
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
        static let defaultTextViewMaxCharecters = 280
    }

    fileprivate var disposeBag = DisposeBag()

    var inputs: OWAdditionalInfoViewViewModelingInputs { return self }
    var outputs: OWAdditionalInfoViewViewModelingOutputs { return self }

    var titleText: String {
        return OWLocalizationManager.shared.localizedString(key: "AdditionalInfoTitle")
    }

    var cancelButtonText: String {
        return OWLocalizationManager.shared.localizedString(key: "Cancel")
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

    var submitButtonTextChanged = BehaviorSubject<String>(value: "")
    var submitButtonText: Observable<String> {
        return submitButtonTextChanged
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
    let titleViewVM: OWTitleViewViewModeling = OWTitleViewViewModel()
    let viewableMode: OWViewableMode

    init(viewableMode: OWViewableMode,
         placeholderText: String,
         textViewText: String,
         textViewMaxCharecters: Int = Metrics.defaultTextViewMaxCharecters,
         charectersLimitEnabled: Bool,
         showCharectersLimit: Bool,
         isTextRequired: Observable<Bool>,
         minimumTextLength: Observable<Int>,
         submitInProgress: Observable<Bool>,
         submitText: Observable<String>) {
        self.viewableMode = viewableMode
        let textViewData = OWTextViewData(textViewMaxCharecters: textViewMaxCharecters,
                                          placeholderText: placeholderText,
                                          textViewText: textViewText,
                                          charectersLimitEnabled: charectersLimitEnabled,
                                          showCharectersLimit: showCharectersLimit,
                                          isEditable: true)
        self.textViewVM = OWTextViewViewModel(textViewData: textViewData)
        setupObservers(minimumTextLength: minimumTextLength, isTextRequired: isTextRequired, submitInProgress: submitInProgress, submitText: submitText)
    }
}

fileprivate extension OWAdditionalInfoViewViewModel {
    func setupObservers(minimumTextLength: Observable<Int>, isTextRequired: Observable<Bool>, submitInProgress: Observable<Bool>, submitText: Observable<String>) {
        submitInProgress
            .bind(to: self.inputs.submitInProgress)
            .disposed(by: disposeBag)

        isTextRequired
            .withLatestFrom(minimumTextLength) { ($0, $1) }
            .flatMap { [weak self] isTextRequired, minimumTextLength -> Observable<Bool> in
                guard let self = self else { return .empty() }
                var minimumTextLength = minimumTextLength
                minimumTextLength = minimumTextLength > 0 ? minimumTextLength : 1
                return self.textViewVM.outputs.textViewText.map {
                    isTextRequired && $0.count >= minimumTextLength || !isTextRequired
                }
            }
            .bind(to: isSubmitEnabledChange)
            .disposed(by: disposeBag)

        submitText
            .bind(to: self.inputs.submitButtonTextChanged)
            .disposed(by: disposeBag)
    }
}
