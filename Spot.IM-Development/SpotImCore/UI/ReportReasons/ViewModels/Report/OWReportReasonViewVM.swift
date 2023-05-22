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
    var submitButtonText: String { get }
    var tableViewHeaderAttributedText: NSAttributedString { get }
    var tableViewHeaderTapText: String { get }
    var reportReasonCellViewModels: Observable<[OWReportReasonCellViewModeling]> { get }
    var shouldShowTitleView: Bool { get }
    var cancelReportReasonTapped: Observable<Void> { get }
    var closeReportReasonTapped: Observable<Void> { get }
    var submittedReportReasonObservable: Observable<EmptyDecodable> { get }
    var textViewVM: OWTextViewViewModeling { get }
    var selectedReason: Observable<OWReportReason> { get }
    var learnMoreTapped: Observable<URL?> { get }
    var viewableMode: OWViewableMode { get }
    var presentError: Observable<Void> { get }
    var submitInProgress: Observable<Bool> { get }
    var submitReportReasonTapped: Observable<Void> { get }
    var isSubmitEnabled: Observable<Bool> { get }
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
        static let errorAlertActionKey = "GotIt"
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
        return LocalizationManager.localizedString(key: Metrics.errorAlertSubmitTitleKey)
    }

    var errorAlertMessageText: String {
        return LocalizationManager.localizedString(key: Metrics.errorAlertSubmitMessageKey)
    }

    var errorAlertActionText: String {
        return LocalizationManager.localizedString(key: Metrics.errorAlertActionKey)
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

    var tableViewHeaderTapText: String {
        return LocalizationManager.localizedString(key: Metrics.tableViewHeaderTapKey)
    }

    var tableViewHeaderAttributedText: NSAttributedString {
        return LocalizationManager.localizedString(key: Metrics.tableViewHeaderKey)
            .attributedString
            .fontForText(OWFontBook.shared.font(style: .regular,
                                                size: Metrics.headerTextFontSize))
            .colorForText(OWColorPalette.shared.color(type: .brandColor, themeStyle: .light),
                          text: tableViewHeaderTapText)
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
                                              placeholderText: LocalizationManager.localizedString(key: Metrics.textViewPlaceholderKey),
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
            .map { config -> String? in
                guard let conversationConfig = config.conversation,
                      conversationConfig.communityGuidelinesEnabled == true else { return nil }
                return config.conversation?.communityGuidelinesTitle?.value
            }
            .unwrap()
            .map { communityGuidelines in
                return communityGuidelines.locateURLInText
            }
            .asObservable()
    }()

    // Observable for the RepertReason network API
    lazy var submittedReportReasonObservable = {
        return submitReportReasonTapped
            .debug("*** submittedReportReasonObservable")
            .flatMap { [weak self] _ -> Observable<OWReportReason> in
                guard let self = self else { return .empty() }
                return self.selectedReason.take(1)
            }
            .flatMap { [weak self] selectedReason -> Observable<(OWReportReason, String)> in
                guard let self = self else { return .empty() }
                return self.textViewVM.outputs.textViewText.take(1)
                    .map { return (selectedReason, $0) }
            }
            .flatMap { [weak self]  result -> Observable<EmptyDecodable> in
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
            }
            .materialize() // Required to keep the final subscriber even if errors arrived from the network
            .map { event -> EmptyDecodable? in
                switch event {
                case .next(let submit):
                    // TODO: Clear any RX variables which affect error state in the View layer (like _shouldShowError).
                    return submit
                case .error(_):
                    // TODO: handle error - update something like _shouldShowError RX variable which affect the UI state for showing error in the View layer
                    self.setSubmitInProgress.onNext(false)
                    self.errorSubmitting.onNext()
                    return nil
                default:
                    return nil
                }
            }
            .unwrap()
            .share()
    }()
}

fileprivate extension OWReportReasonViewViewModel {
    func setupObservers() {
        selectedReason
            .map {
                if $0.requiredAdditionalInfo == false {
                    return LocalizationManager.localizedString(key: Metrics.textViewPlaceholderKey)
                } else {
                    return LocalizationManager.localizedString(key: Metrics.textViewMandatoryPlaceholderKey)
                }
            }
            .bind(to: textViewVM.inputs.placeholderTextChange)
            .disposed(by: disposeBag)

        presentError
            .observe(on: MainScheduler.instance)
            .flatMap { [weak self] _ -> Observable<UIRxPresenterResponseType> in
                guard let self = self else { return .empty() }
                let action = UIRxPresenterAction.init(title: self.errorAlertActionText)
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
