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
    var submitAppealTap: PublishSubject<Void> { get }
}

protocol OWCommenterAppealViewViewModelingOutputs {
    var closeButtonPopped: Observable<Void> { get }
    var cancelAppeal: Observable<Void> { get }
    var textViewVM: OWTextViewViewModeling { get }
    var appealCellViewModels: Observable<[OWAppealCellViewModeling]> { get }
    var selectedReason: Observable<OWAppealReason> { get }
    var submitButtonText: Observable<String> { get }
    var submitInProgress: Observable<Bool> { get }
    var isSubmitEnabled: Observable<Bool> { get }
    var appealSubmittedSuccessfully: Observable<Void> { get }
    var viewableMode: OWViewableMode { get }
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
    fileprivate let commentId: OWCommentId
    fileprivate var articleUrl: String = ""
    fileprivate let presentationalMode: OWPresentationalModeCompact

    let textViewVM: OWTextViewViewModeling
    let viewableMode: OWViewableMode

    init(data: OWAppealRequiredData,
         viewableMode: OWViewableMode,
         presentationalMode: OWPresentationalModeCompact = .none,
         servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.servicesProvider = servicesProvider
        self.commentId = data.commentId
        self.viewableMode = viewableMode
        self.presentationalMode = presentationalMode
        disposeBag = DisposeBag()
        let textViewData = OWTextViewData(textViewMaxCharecters: Metrics.defaultTextViewMaxCharecters,
                                          placeholderText: "",
                                          charectersLimitEnabled: false,
                                          showCharectersLimit: false,
                                          isEditable: false)
        self.textViewVM = OWTextViewViewModel(textViewData: textViewData)
        self._appealOptions.onNext(data.reasons)
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

    fileprivate let _appealOptions = BehaviorSubject<[OWAppealReason]>(value: [])
    lazy var appealOptions: Observable<[OWAppealReason]> = {
        _appealOptions
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
    lazy var selectedReason: Observable<OWAppealReason> = {
        reasonIndexSelect
            .skip(1)
            .unwrap()
            .flatMap { [weak self] index -> Observable<OWAppealReason> in
                guard let self = self else { return .empty() }
                return self.appealOptions
                    .map { $0[index] }
            }
            .share(replay: 1)
    }()

    fileprivate var _submitInProgress = BehaviorSubject<Bool>(value: false)
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
        return Observable.combineLatest(selectedReason, textViewVM.outputs.textViewText, submitInProgress)
            .map { reason, text, submitInProgress -> Bool in
                guard !submitInProgress else { return false }
                guard reason.requiredAdditionalInfo else { return true }

                return text.count > 0
            }
            .asObservable()
    }

    var submitAppealTap = PublishSubject<Void>()

    fileprivate let _appealSubmittedSuccessfully = BehaviorSubject<Void?>(value: nil)
    var appealSubmittedSuccessfully: Observable<Void> {
        return _appealSubmittedSuccessfully
            .unwrap()
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

        submitAppealTap
            .withLatestFrom(selectedReason) { _, reason in
                return reason.type
            }
            .do(onNext: { [weak self] reason in
                guard let self = self else { return }
                self.sendEvent(for: .appealSubmitted(commnetId: self.commentId, appealReason: reason.rawValue))
            })
            .withLatestFrom(textViewVM.outputs.textViewText) { reason, message in
                return (reason, message)
            }
            .flatMapLatest { [weak self] reason, message -> Observable<Event<OWNetworkEmpty>> in
                guard let self = self else { return .empty() }
                self._submitInProgress.onNext(true)
                return self.servicesProvider.netwokAPI()
                    .appeal
                    .submitAppeal(commentId: self.commentId, reason: reason, message: message)
                    .response
                    .materialize()
            }
            .map { [weak self] event -> Bool in
                self?._submitInProgress.onNext(false)

                switch event {
                case .next, .completed:
                    return true
                case .error:
                    return false
                }
            }
            .subscribe(onNext: { [weak self] success in
                guard let self = self else { return }

                self.isError.onNext(!success)
                if success {
                    self._appealSubmittedSuccessfully.onNext(())
                    self.servicesProvider.commentStatusUpdaterService().update(status: .appealed, for: self.commentId)
                }
            })
            .disposed(by: disposeBag)

        servicesProvider
            .activeArticleService()
            .articleExtraData
            .subscribe(onNext: { [weak self] article in
                self?.articleUrl = article.url.absoluteString
            })
            .disposed(by: disposeBag)

        closeButtonPopped
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.sendEvent(for: .appealDialogExit(commentId: self.commentId))
            })
            .disposed(by: disposeBag)
    }

    func event(for eventType: OWAnalyticEventType) -> OWAnalyticEvent {
        return servicesProvider
            .analyticsEventCreatorService()
            .analyticsEvent(
                for: eventType,
                articleUrl: articleUrl,
                layoutStyle: OWLayoutStyle(from: self.presentationalMode),
                component: .clarityDetails)
    }

    func sendEvent(for eventType: OWAnalyticEventType) {
        let event = event(for: eventType)
        servicesProvider
            .analyticsService()
            .sendAnalyticEvents(events: [event])
    }
}
