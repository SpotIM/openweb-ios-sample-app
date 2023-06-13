//
//  OWReportReasonVM.swift
//  SpotImCore
//
//  Created by Refael Sommer on 16/04/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWReportReasonViewViewModelingInputs {
    var errorSubmitting: PublishSubject<Void> { get }
    var learnMoreTap: PublishSubject<Void> { get }
    var cancelReportReasonTap: PublishSubject<Void> { get }
    var submitReportReasonTap: PublishSubject<Void> { get }
    var textViewTextChange: PublishSubject<String> { get }
    var reasonIndexSelect: BehaviorSubject<Int?> { get }
    var isSubmitEnabledChange: PublishSubject<Bool> { get }
}

protocol OWReportReasonViewViewModelingOutputs {
    var errorAlertActionText: String { get }
    var titleText: String { get }
    var cancelButtonText: String { get }
    var submitButtonText: Observable<String> { get }
    var tableViewHeaderAttributedText: Observable<NSAttributedString> { get }
    var tableViewHeaderTapText: String { get }
    var reportReasonCellViewModels: Observable<[OWReportReasonCellViewModeling]> { get }
    var shouldShowTitleView: Bool { get }
    var cancelReportReasonTapped: Observable<Void> { get }
    var closeReportReasonTapped: Observable<Void> { get }
    var submittedReportReasonObservable: Observable<Void> { get }
    var textViewVM: OWTextViewViewModeling { get }
    var selectedReason: Observable<OWReportReason> { get }
    var learnMoreTapped: Observable<URL?> { get }
    var viewableMode: OWViewableMode { get }
    var presentError: Observable<Void> { get }
    var submitInProgress: Observable<Bool> { get }
    var shouldShowLearnMore: Observable<Bool> { get }
    var submitReportReasonTapped: Observable<Void> { get }
    var isSubmitEnabled: Observable<Bool> { get }
    var reportReasonsCharectersLimitEnabled: Observable<Bool> { get }
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
        static let tryAgainKey = "TryAgain"
        static let errorAlertActionKey = "Got it"
        static let errorAlertSubmitTitleKey = "ReportSubmissionFailedTitle"
        static let errorAlertSubmitMessageKey = "ReportSubmissionFailedMessage"
        static let tableViewHeaderKey = "ReportReasonHelpUsTitle"
        static let tableViewHeaderTapKey = "ReportReasonHelpUsClickText"
        static let textViewMaxCharecters = 280
        static let headerTextFontSize: CGFloat = 15
    }

    var errorSubmitting = PublishSubject<Void>()
    var presentError: Observable<Void> {
        return errorSubmitting
                .asObservable()
    }

    var errorAlertTitleText: String {

        return OWLocalizationManager.shared.localizedString(key: Metrics.errorAlertSubmitTitleKey)
    }

    var errorAlertMessageText: String {
        return OWLocalizationManager.shared.localizedString(key: Metrics.errorAlertSubmitMessageKey)
    }

    var errorAlertActionText: String {
        return OWLocalizationManager.shared.localizedString(key: Metrics.errorAlertActionKey)
    }

    var titleText: String {
        return OWLocalizationManager.shared.localizedString(key: Metrics.titleKey)
    }

    var cancelButtonText: String {
        return OWLocalizationManager.shared.localizedString(key: Metrics.cancelKey)
    }

    var changeSubmitButtonText = BehaviorSubject<Bool>(value: false)
    var submitButtonText: Observable<String> {
        return changeSubmitButtonText
            .map { changeText in
                return OWLocalizationManager.shared.localizedString(key: changeText ? Metrics.tryAgainKey : Metrics.submitKey)
            }
    }

    var tableViewHeaderTapText: String {
        return OWLocalizationManager.shared.localizedString(key: Metrics.tableViewHeaderTapKey)
    }

    var tableViewHeaderAttributedText: Observable<NSAttributedString> {
        shouldShowLearnMore
            .map { [weak self] shouldShowLearnMore in
                guard let self = self else { return nil }
                return OWLocalizationManager.shared.localizedString(key: Metrics.tableViewHeaderKey)
                    .replacingOccurrences(of: tableViewHeaderTapText, with: shouldShowLearnMore ? tableViewHeaderTapText : "")
                    .attributedString
                    .fontForText(OWFontBook.shared.font(style: .regular,
                                                        size: Metrics.headerTextFontSize))
                    .colorForText(OWColorPalette.shared.color(type: .brandColor, themeStyle: .light),
                                  text: shouldShowLearnMore ? tableViewHeaderTapText : "")
            }
            .unwrap()
    }

    var inputs: OWReportReasonViewViewModelingInputs { return self }
    var outputs: OWReportReasonViewViewModelingOutputs { return self }

    let viewableMode: OWViewableMode

    fileprivate let disposeBag = DisposeBag()
    fileprivate let servicesProvider: OWSharedServicesProviding
    fileprivate let presentationalMode: OWPresentationalModeCompact
    fileprivate let commentId: OWCommentId

    var setSubmitInProgress = PublishSubject<Bool>()
    var submitInProgress: Observable<Bool> {
        return setSubmitInProgress
            .asObservable()
    }

    var shouldShowLearnMoreChanged = BehaviorSubject<Bool>(value: false)
    var shouldShowLearnMore: Observable<Bool> {
        return shouldShowLearnMoreChanged
            .asObservable()
    }

    var learnMoreTap = PublishSubject<Void>()
    var learnMoreTapped: Observable<URL?> {
        return learnMoreTap
            .withLatestFrom(communityGuidelinesUrl)
            .asObservable()
    }

    var cancelReportReasonTap = PublishSubject<Void>()
    var cancelReportReasonTapped: Observable<Void> {
        return cancelReportReasonTap
                .flatMap { [weak self] _ -> Observable<String> in
                    guard let self = self else { return .empty() }
                    return self.textViewVM.outputs.textViewText
                        .take(1)
                }
                .filter { !$0.isEmpty }
                .voidify()
    }

    var closeReportReasonTapped: Observable<Void> {
        return cancelReportReasonTap
                .flatMap { [weak self] _ -> Observable<String> in
                    guard let self = self else { return .empty() }
                    return self.textViewVM.outputs.textViewText
                        .take(1)
                }
                .filter { $0.isEmpty }
                .voidify()
                .asObservable()
    }

    var submitReportReasonTap = PublishSubject<Void>()
    var submitReportReasonTapped: Observable<Void> {
        return submitReportReasonTap
            .asObservable()
    }

    var isSubmitEnabledChange = PublishSubject<Bool>()
    var isSubmitEnabled: Observable<Bool> {
        return isSubmitEnabledChange
            .asObservable()
    }

    var textViewTextChange = PublishSubject<String>()

    var reasonIndexSelect = BehaviorSubject<Int?>(value: nil)

    let textViewVM: OWTextViewViewModeling

    init(commentId: OWCommentId,
         viewableMode: OWViewableMode,
         presentationalMode: OWPresentationalModeCompact,
         servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.commentId = commentId
        self.viewableMode = viewableMode
        self.presentationalMode = presentationalMode
        self.servicesProvider = servicesProvider
        self.textViewVM = OWTextViewViewModel(textViewMaxCharecters: Metrics.textViewMaxCharecters,
                                              placeholderText: OWLocalizationManager.shared.localizedString(key: Metrics.textViewPlaceholderKey),
                                              charectersLimitEnabled: false,
                                              isEditable: false)
        setupObservers()
    }

    var shouldShowTitleView: Bool {
        return viewableMode == .independent
    }

    lazy var reportReasonOptions: Observable<[OWReportReason]> = {
        self.servicesProvider.spotConfigurationService()
            .config(spotId: OWManager.manager.spotId)
            .map { $0.shared?.reportReasonsOptions?.reasonsList }
            .unwrap()
            .asObservable()
            .share(replay: 1)
    }()

    lazy var reportReasonCellViewModels: Observable<[OWReportReasonCellViewModeling]> = {
        reportReasonOptions
            .map { reasons in
                var viewModels: [OWReportReasonCellViewModeling] = []
                for reason in reasons {
                    viewModels.append(OWReportReasonCellViewModel(reason: reason))
                }
                return viewModels
            }
            .asObservable()
    }()

    lazy var selectedReason: Observable<OWReportReason> = {
        reasonIndexSelect
            .skip(1)
            .unwrap()
            .flatMap { [weak self] index -> Observable<OWReportReason> in
                guard let self = self else { return .empty() }
                return reportReasonOptions
                    .map { $0[index] }
            }
            .share(replay: 1)
    }()

    fileprivate lazy var communityGuidelinesUrl: Observable<URL?> = {
        let configurationService = OWSharedServicesProvider.shared.spotConfigurationService()
        return configurationService.config(spotId: OWManager.manager.spotId)
            .take(1)
            .map { [weak self] config -> String? in
                guard let self = self else { return nil }
                guard let conversationConfig = config.conversation,
                          conversationConfig.communityGuidelinesEnabled == true else {
                        self.shouldShowLearnMoreChanged.onNext(false)
                        return nil
                }
                self.shouldShowLearnMoreChanged.onNext(true)
                return config.conversation?.communityGuidelinesTitle?.value
            }
            .unwrap()
            .map { communityGuidelines in
                return communityGuidelines.locateURLInText
            }
            .asObservable()
    }()

    lazy var reportReasonsCharectersLimitEnabled: Observable<Bool> = {
        let configurationService = OWSharedServicesProvider.shared.spotConfigurationService()
        return configurationService.config(spotId: OWManager.manager.spotId)
            .map { [weak self] config -> Bool? in
                guard let self = self else { return false }
                return config.mobileSdk.shouldShowReportReasonsCounter
            }
            .unwrap()
            .take(1)
            .asObservable()
    }()

    lazy var reportReasonsCounterMaxLength: Observable<Int> = {
        let configurationService = OWSharedServicesProvider.shared.spotConfigurationService()
        return configurationService.config(spotId: OWManager.manager.spotId)
            .map { [weak self] config -> Int? in
                guard let self = self else { return Metrics.textViewMaxCharecters }
                return config.mobileSdk.reportReasonsCounterMaxLength
            }
            .unwrap()
            .take(1)
            .asObservable()
    }()

    // Observable for the RepertReason network API
    lazy var submittedReportReasonObservable: Observable<Void> = {
        return submitReportReasonTapped
            .flatMapLatest { [weak self] _ -> Observable<OWReportReason> in
                guard let self = self else { return .empty() }
                return self.selectedReason.take(1)
            }
            .flatMapLatest { [weak self] selectedReason -> Observable<(OWReportReason, String)> in
                guard let self = self else { return .empty() }
                return self.textViewVM.outputs.textViewText.take(1)
                    .map { return (selectedReason, $0) }
            }
            .flatMapLatest { [weak self]  result -> Observable<Event<EmptyDecodable>> in
                guard let self = self else { return .empty() }
                let selectedReason = result.0
                let userDescription = result.1
                self.setSubmitInProgress.onNext(true)
                return self.servicesProvider
                    .netwokAPI()
                    .reportReason
                    .report(commentId: self.commentId,
                            reasonMain: selectedReason.reportType.rawValue, reasonSub: "",
                            userDescription: userDescription)
                    .response
                    .materialize()
            }
            .map { event -> EmptyDecodable? in
                switch event {
                case .next(let submit):
                    // TODO: Clear any RX variables which affect error state in the View layer (like _shouldShowError).
                    return submit
                case .error(_):
                    // TODO: handle error - update something like _shouldShowError RX variable which affect the UI state for showing error in the View layer
                    self.setSubmitInProgress.onNext(false)
                    self.errorSubmitting.onNext()
                    self.changeSubmitButtonText.onNext(true)
                    return nil
                default:
                    return nil
                }
            }
            .unwrap()
            .voidify()
            .share()
    }()
}

fileprivate extension OWReportReasonViewViewModel {
    func setupObservers() {
        selectedReason
            .map {
                if $0.requiredAdditionalInfo == false {
                    return OWLocalizationManager.shared.localizedString(key: Metrics.textViewPlaceholderKey)
                } else {
                    return OWLocalizationManager.shared.localizedString(key: Metrics.textViewMandatoryPlaceholderKey)
                }
            }
            .bind(to: textViewVM.inputs.placeholderTextChange)
            .disposed(by: disposeBag)

        reportReasonsCounterMaxLength
            .subscribe(onNext: { [weak self] limit in
                guard let self = self else { return }
                self.textViewVM.inputs.textViewMaxCharectersChange.onNext(limit)
            })
            .disposed(by: disposeBag)

        reportReasonsCharectersLimitEnabled
            .subscribe(onNext: { [weak self] show in
                guard let self = self else { return }
                self.textViewVM.inputs.charectarsLimitEnabledChange.onNext(show)
            })
            .disposed(by: disposeBag)

        selectedReason
            .filter { $0.requiredAdditionalInfo == true }
            .voidify()
            .bind(to: textViewVM.inputs.textViewTap)
            .disposed(by: disposeBag)

        presentError
            .observe(on: MainScheduler.instance)
            .flatMap { [weak self] _ -> Observable<OWRxPresenterResponseType> in
                guard let self = self else { return .empty() }
                let action = OWRxPresenterAction(title: self.errorAlertActionText, type: OWCommentOptionsMenu.cancel)
                return self.servicesProvider.presenterService().showAlert(title: self.errorAlertTitleText,
                                                                   message: self.errorAlertMessageText,
                                                                   actions: [action],
                                                                   viewableMode: self.viewableMode)
            }
            .subscribe()
            .disposed(by: disposeBag)

        textViewTextChange
            .bind(to: textViewVM.inputs.textViewTextChange)
            .disposed(by: disposeBag)

        Observable.combineLatest(selectedReason, textViewVM.outputs.textViewTextCount)
            .map { reportReason, textCount -> Bool in
                return !reportReason.requiredAdditionalInfo || textCount > 0
            }
            .bind(to: isSubmitEnabledChange)
            .disposed(by: disposeBag)
    }
}
