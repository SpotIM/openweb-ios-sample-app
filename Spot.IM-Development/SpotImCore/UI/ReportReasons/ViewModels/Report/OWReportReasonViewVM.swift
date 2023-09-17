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
    var changeReportOffset: PublishSubject<CGPoint> { get }
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
    var titleViewVM: OWTitleViewViewModeling { get }
    var selectedReason: Observable<OWReportReason> { get }
    var learnMoreTapped: Observable<URL?> { get }
    var viewableMode: OWViewableMode { get }
    var presentError: Observable<Void> { get }
    var submitInProgress: Observable<Bool> { get }
    var shouldShowLearnMore: Observable<Bool> { get }
    var submitReportReasonTapped: Observable<Void> { get }
    var isSubmitEnabled: Observable<Bool> { get }
    var reportReasonsCharectersLimitEnabled: Observable<Bool> { get }
    var reportReasonSubmittedSuccessfully: Observable<OWCommentId> { get }
    var reportOffset: Observable<CGPoint> { get }
}

protocol OWReportReasonViewViewModeling: AnyObject {
    var inputs: OWReportReasonViewViewModelingInputs { get }
    var outputs: OWReportReasonViewViewModelingOutputs { get }
}

class OWReportReasonViewViewModel: OWReportReasonViewViewModelingInputs, OWReportReasonViewViewModelingOutputs, OWReportReasonViewViewModeling {

    fileprivate struct Metrics {
        static let defaultTextViewMaxCharecters = 280
    }

    fileprivate var postId: OWPostId {
        return OWManager.manager.postId ?? ""
    }

    var errorSubmitting = PublishSubject<Void>()
    var presentError: Observable<Void> {
        return errorSubmitting
                .asObservable()
    }

    var errorAlertTitleText: String {

        return OWLocalizationManager.shared.localizedString(key: "ReportSubmissionFailedTitle")
    }

    var errorAlertMessageText: String {
        return OWLocalizationManager.shared.localizedString(key: "ReportSubmissionFailedMessage")
    }

    var errorAlertActionText: String {
        return OWLocalizationManager.shared.localizedString(key: "Got it")
    }

    var titleText: String {
        return OWLocalizationManager.shared.localizedString(key: "ReportReasonTitle")
    }

    var cancelButtonText: String {
        return OWLocalizationManager.shared.localizedString(key: "Cancel")
    }

    var changeSubmitButtonText = BehaviorSubject<Bool>(value: false)
    var submitButtonText: Observable<String> {
        return changeSubmitButtonText
            .map { changeText in
                return OWLocalizationManager.shared.localizedString(key: changeText ? "TryAgain" : "Submit")
            }
    }

    var tableViewHeaderTapText: String {
        return OWLocalizationManager.shared.localizedString(key: "ReportReasonHelpUsClickText")
    }

    var tableViewHeaderAttributedText: Observable<NSAttributedString> {
        shouldShowLearnMore
            .map { [weak self] shouldShowLearnMore in
                guard let self = self else { return nil }
                return OWLocalizationManager.shared.localizedString(key: "ReportReasonHelpUsTitle")
                    .replacingOccurrences(of: self.tableViewHeaderTapText, with: shouldShowLearnMore ? self.tableViewHeaderTapText : "")
                    .attributedString
                    .font(OWFontBook.shared.font(typography: .bodyText))
                    .color(OWColorPalette.shared.color(type: .brandColor, themeStyle: .light),
                                  forText: shouldShowLearnMore ? self.tableViewHeaderTapText : "")
            }
            .unwrap()
    }

    fileprivate let _reportReasonSubmittedSuccessfully = BehaviorSubject<OWCommentId?>(value: nil)
    var reportReasonSubmittedSuccessfully: Observable<OWCommentId> {
        return _reportReasonSubmittedSuccessfully
            .unwrap()
            .asObservable()
    }

    var inputs: OWReportReasonViewViewModelingInputs { return self }
    var outputs: OWReportReasonViewViewModelingOutputs { return self }

    let viewableMode: OWViewableMode

    fileprivate let disposeBag = DisposeBag()
    fileprivate let servicesProvider: OWSharedServicesProviding
    fileprivate let presentationalMode: OWPresentationalModeCompact
    fileprivate let commentId: OWCommentId
    fileprivate let parentId: OWCommentId

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
    let titleViewVM: OWTitleViewViewModeling = OWTitleViewViewModel()

    init(reportData: OWReportReasonsRequiredData,
         viewableMode: OWViewableMode,
         presentationalMode: OWPresentationalModeCompact,
         servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.commentId = reportData.commentId
        self.parentId = reportData.parentId
        self.viewableMode = viewableMode
        self.presentationalMode = presentationalMode
        self.servicesProvider = servicesProvider
        let textViewData = OWTextViewData(textViewMaxCharecters: Metrics.defaultTextViewMaxCharecters,
                                          placeholderText: OWLocalizationManager.shared.localizedString(key: "ReportReasonTextViewPlaceholder"),
                                          charectersLimitEnabled: false,
                                          isEditable: false)
        self.textViewVM = OWTextViewViewModel(textViewData: textViewData)
        setupObservers()
    }

    var shouldShowTitleView: Bool {
        return viewableMode == .independent
    }

    lazy var reportReasonOptions: Observable<[OWReportReason]> = {
        self.servicesProvider.spotConfigurationService()
            .config(spotId: OWManager.manager.spotId)
            .map { $0.shared?.reportReasonsOptions?.reportReasons }
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
                return self.reportReasonOptions
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
                guard let self = self else { return Metrics.defaultTextViewMaxCharecters }
                return config.mobileSdk.reportReasonsCounterMaxLength
            }
            .unwrap()
            .take(1)
            .asObservable()
    }()

    // Observable for the RepertReason network API
    lazy var submittedReportReasonObservable: Observable<Void> = {
        return submitReportReasonTapped
            .flatMapLatest { [weak self] _ -> Observable<Void> in
                // 1. Triggering authentication UI if needed
                guard let self = self else { return .empty() }
                return self.servicesProvider.authenticationManager().ifNeededTriggerAuthenticationUI(for: .reportingComment)
                    .voidify()
            }
            .flatMapLatest { [weak self] _ -> Observable<Void> in
                // 2. Waiting for authentication required for reporting
                guard let self = self else { return .empty() }
                return self.servicesProvider.authenticationManager().waitForAuthentication(for: .reportingComment)
                    .voidify()
            }
            .flatMapLatest { [weak self] _ -> Observable<OWReportReason> in
                guard let self = self else { return .empty() }
                return self.selectedReason.take(1)
            }
            .flatMapLatest { [weak self] selectedReason -> Observable<(OWReportReason, String)> in
                guard let self = self else { return .empty() }
                return self.textViewVM.outputs.textViewText.take(1)
                    .map { return (selectedReason, $0) }
            }
            .flatMapLatest { [weak self] result -> Observable<Event<EmptyDecodable>> in
                guard let self = self else { return .empty() }
                let selectedReason = result.0
                let userDescription = result.1
                self.setSubmitInProgress.onNext(true)
                return self.servicesProvider
                    .netwokAPI()
                    .reportReason
                    .report(commentId: self.commentId,
                            parentId: self.parentId,
                            reasonMain: selectedReason.type.rawValue, reasonSub: "",
                            userDescription: userDescription)
                    .response
                    .materialize()
            }
            .map { [weak self] event -> EmptyDecodable? in
                guard let self = self else { return nil }
                switch event {
                case .next(let submit):
                    let reportService = self.servicesProvider.reportedCommentsService()
                    reportService.updateCommentReportedSuccessfully(commentId: self.commentId, postId: self.postId)
                    self._reportReasonSubmittedSuccessfully.onNext(self.commentId)
                    return submit
                case .error(_):
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

    var changeReportOffset = PublishSubject<CGPoint>()
    var reportOffset: Observable<CGPoint> {
        return changeReportOffset
            .asObservable()
    }
}

fileprivate extension OWReportReasonViewViewModel {
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
                let action = OWRxPresenterAction(title: self.errorAlertActionText, type: OWCommentOptionsMenu.reportComment)
                return self.servicesProvider.presenterService().showAlert(title: self.errorAlertTitleText,
                                                                   message: self.errorAlertMessageText,
                                                                   actions: [action],
                                                                   viewableMode: self.viewableMode)
            }
            .subscribe()
            .disposed(by: disposeBag)

        textViewTextChange
            .bind(to: textViewVM.inputs.textExternalChange)
            .disposed(by: disposeBag)

        Observable.combineLatest(selectedReason, textViewVM.outputs.textViewText)
            .map { reportReason, text -> Bool in
                return !reportReason.requiredAdditionalInfo || text.count > 0
            }
            .bind(to: isSubmitEnabledChange)
            .disposed(by: disposeBag)
    }
}
