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
    var closeReportReasonTap: PublishSubject<Void> { get }
    var cancelReportReasonTap: PublishSubject<Void> { get }
    var submitReportReasonTap: PublishSubject<Void> { get }
    var reasonIndexSelect: BehaviorSubject<Int?> { get }
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
    var closeReportReasonTapped: Observable<Void> { get }
    var cancelReportReasonTapped: Observable<Void> { get }
    var submittedReportReasonObservable: Observable<EmptyDecodable> { get }
    var textViewVM: OWTextViewViewModeling { get }
    var selectedReason: Observable<OWReportReason?> { get }
    var learnMoreTapped: Observable<URL?> { get }
    var viewableMode: OWViewableMode { get }
    var presentError: Observable<UIAlertController> { get }
    var callbackErrorSubmitting: Observable<OWError> { get }
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
    var presentError: Observable<UIAlertController> {
        return errorSubmitting
            .map { [weak self] in
                let title = LocalizationManager.localizedString(key: Metrics.errorAlertSubmitTitleKey)
                let message = LocalizationManager.localizedString(key: Metrics.errorAlertSubmitMessageKey)
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: self?.errorAlertActionText, style: .default, handler: nil))
                return alert
            }
            .asObservable()
    }

    var callbackErrorSubmitting: Observable<OWError> {
        return errorSubmitting
            .map {
                let title = LocalizationManager.localizedString(key: Metrics.errorAlertSubmitTitleKey)
                let message = LocalizationManager.localizedString(key: Metrics.errorAlertSubmitMessageKey)
                let error: OWError = .reportReasonSubmitError(title: title, description: message)
                return error
            }
            .asObservable()
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

    var learnMoreTap = PublishSubject<Void>()
    var learnMoreTapped: Observable<URL?> {
        return learnMoreTap
            .withLatestFrom(communityGuidelinesUrl)
            .asObservable()
    }

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
        return submitReportReasonTap
                .asObservable()
    }

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
    lazy var submittedReportReasonObservable = submitReportReasonTapped
        .withLatestFrom(selectedReason)
        .withLatestFrom(textViewVM.outputs.textViewText) { [weak self] selectedReason, userDescription -> Observable<EmptyDecodable> in
            guard let self = self,
                  let selectedReason = selectedReason
            else { return .empty() }
            return self.servicesProvider
                .netwokAPI()
                .reportReason
                .report(commentId: self.commentId,
                        reasonMain: selectedReason.reportType.rawValue,
                        reasonSub: "",
                        userDescription: userDescription)
                .response
        }
        .flatMap { observable -> Observable<EmptyDecodable> in
            return observable
        }
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

        submittedReportReasonObservable
            .subscribe { [weak self] response in
                if response.error != nil {
                    self?.errorSubmitting.onNext()
                }
            }
            .disposed(by: disposeBag)
    }
}
