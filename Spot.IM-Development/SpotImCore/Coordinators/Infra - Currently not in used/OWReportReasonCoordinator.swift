//
//  OWReportReasonCoordinator.swift
//  SpotImCore
//
//  Created by Refael Sommer on 20/04/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

enum OWReportReasonCoordinatorResult: OWCoordinatorResultProtocol {
    case loadedToScreen
    case popped
    case submitedReport(commentId: OWCommentId)

    var loadedToScreen: Bool {
        switch self {
        case .loadedToScreen:
            return true
        default:
            return false
        }
    }
}

protocol OWReportReasonCoordinatorModelingOutputs {
    var reportReasonSubmitted: Observable<OWCommentId> { get }
}

protocol OWReportReasonCoordinatorModeling {
    var outputs: OWReportReasonCoordinatorModelingOutputs { get }
}

class OWReportReasonCoordinator: OWBaseCoordinator<OWReportReasonCoordinatorResult>, OWReportReasonCoordinatorModeling, OWReportReasonCoordinatorModelingOutputs {
    fileprivate struct Metrics {
        static let fadeDuration: CGFloat = 0.3
        static let delayTapForOpenAdditionalInfo = 100 // Time in ms
    }

    var outputs: OWReportReasonCoordinatorModelingOutputs { return self }

    fileprivate let commentId: OWCommentId
    fileprivate let parentId: OWCommentId
    fileprivate let router: OWRoutering?
    fileprivate let actionsCallbacks: OWViewActionsCallbacks?
    fileprivate lazy var viewActionsService: OWViewActionsServicing = {
        return OWViewActionsService(viewActionsCallbacks: actionsCallbacks, viewSourceType: .reportReason)
    }()
    fileprivate let reportReasonPopped = PublishSubject<Void>()
    let presentationalMode: OWPresentationalModeCompact
    var reportReasonView: UIView?

    fileprivate let reportReasonSubmittedChange = PublishSubject<OWCommentId>()
    lazy var reportReasonSubmitted: Observable<OWCommentId> = {
        reportReasonSubmittedChange
            .asObservable()
            .share()
    }()

    init(commentId: OWCommentId,
         parentId: OWCommentId,
         router: OWRoutering? = nil,
         actionsCallbacks: OWViewActionsCallbacks?,
         presentationalMode: OWPresentationalModeCompact = .none) {
        self.commentId = commentId
        self.parentId = parentId
        self.router = router
        self.actionsCallbacks = actionsCallbacks
        self.presentationalMode = presentationalMode
    }

    override func start(deepLinkOptions: OWDeepLinkOptions? = nil) -> Observable<OWReportReasonCoordinatorResult> {
        guard let router = router else { return .empty() }
        let reportReasonVM: OWReportReasonViewModeling = OWReportReasonViewModel(commentId: commentId,
                                                                                 parentId: parentId,
                                                                                 viewableMode: .partOfFlow,
                                                                                 presentMode: self.presentationalMode)
        let reportReasonVC = OWReportReasonVC(viewModel: reportReasonVM)

        if router.isEmpty() {
            router.start()
            router.setRoot(reportReasonVC, animated: false, dismissCompletion: reportReasonPopped)
        } else {
            router.push(reportReasonVC,
                        pushStyle: .presentStyle,
                        animated: true,
                        popCompletion: reportReasonPopped)
        }

        setupObservers(forViewModel: reportReasonVM)
        setupViewActionsCallbacks(forViewModel: reportReasonVM.outputs.reportReasonViewViewModel)

        let reportReasonPoppedObservable = reportReasonPopped
            .map { OWReportReasonCoordinatorResult.popped }
            .asObservable()

        let reportReasonSubmittedObservable = reportReasonSubmittedChange
            .map { OWReportReasonCoordinatorResult.submitedReport(commentId: $0) }
            .asObservable()
            .share()

        let reportReasonLoadedToScreenObservable = reportReasonVM.outputs.loadedToScreen
            .map { OWReportReasonCoordinatorResult.loadedToScreen }
            .asObservable()

        return Observable.merge(reportReasonPoppedObservable, reportReasonLoadedToScreenObservable, reportReasonSubmittedObservable)
    }

    override func showableComponent() -> Observable<OWShowable> {
        let reportReasonViewVM: OWReportReasonViewViewModeling = OWReportReasonViewViewModel(commentId: commentId,
                                                                                             parentId: parentId,
                                                                                             viewableMode: .independent,
                                                                                             presentationalMode: .none,
                                                                                             servicesProvider: OWSharedServicesProvider.shared)
        setupViewActionsCallbacks(forViewModel: reportReasonViewVM)

        let reportReasonView = OWReportReasonView(viewModel: reportReasonViewVM)
        self.reportReasonView = reportReasonView
        return .just(reportReasonView)
    }
}

fileprivate extension OWReportReasonCoordinator {
    func setupObservers(forViewModel viewModel: OWReportReasonViewModeling) {
        // Setting up general observers which affect app flow however not entirely inside the SDK
        viewModel.outputs
            .reportReasonViewViewModel.outputs.reportReasonsSubmittedCommentId
            .bind(to: reportReasonSubmittedChange)
            .disposed(by: disposeBag)
    }

    // swiftlint:disable function_body_length
    func setupViewActionsCallbacks(forViewModel viewModel: OWReportReasonViewViewModeling) {
    // swiftlint:enable function_body_length

        // MARK: General (Used for both Flow and Independent)

        // ReportReaon OWTextViewVM - General
        let reportTextViewVM = viewModel.outputs.textViewVM
        // Additional information observable - General
        let additionalInformationObservable = reportTextViewVM.outputs.textViewTapped
            .flatMap { _ -> Observable<String> in
                return reportTextViewVM.outputs.placeholderText
                    .take(1)
            }
            .flatMap({ placeholderText -> Observable<(String, String)> in
                return reportTextViewVM.outputs.textViewText
                    .map { (placeholderText, $0) }
                    .take(1)
            })
            .flatMap({ placeholderText, textViewText -> Observable<(String, String, Bool)> in
                return viewModel.outputs.reportReasonsCharectersLimitEnabled
                    .map { (placeholderText, textViewText, $0) }
                    .take(1)
            })
            .delay(.milliseconds(Metrics.delayTapForOpenAdditionalInfo), scheduler: MainScheduler.asyncInstance)
            .observe(on: MainScheduler.instance)
            .map { placeholderText, textViewText, shouldShowCounter -> OWAdditionalInfoViewViewModel in
                return OWAdditionalInfoViewViewModel(viewableMode: viewModel.outputs.viewableMode,
                                                     placeholderText: placeholderText,
                                                     textViewText: textViewText,
                                                     textViewMaxCharecters: viewModel.outputs.textViewVM.outputs.textViewMaxCharecters,
                                                     charectersLimitEnabled: shouldShowCounter,
                                                     isTextRequired: viewModel.outputs.selectedReason.map { $0.requiredAdditionalInfo },
                                                     submitInProgress: viewModel.outputs.submitInProgress,
                                                     submitText: viewModel.outputs.submitButtonText)
            }
            .share()

        // Additional information cancel - General
        let cancelAdditionalInfoTapped = additionalInformationObservable
            .flatMap { additionalInfoViewVM -> Observable<Void> in
                return additionalInfoViewVM.outputs.cancelAdditionalInfoTapped
            }

        // Additional information empty text close report reason - General
        let additionalInfoCloseReportReasonTapped = additionalInformationObservable
            .flatMap { additionalInfoViewVM -> Observable<Void> in
                return additionalInfoViewVM.outputs.closeReportReasonTapped
            }

        // Additional information text changed - General
        additionalInformationObservable
            .flatMap { additionalInformationViewVM -> Observable<String> in
                return additionalInformationViewVM.outputs.additionalInfoTextChanged
            }
            .bind(to: viewModel.inputs.textViewTextChange)
            .disposed(by: disposeBag)

        // Additional information submit - General
        additionalInformationObservable
            .flatMap { additionalInformationViewVM -> Observable<Void> in
                return additionalInformationViewVM.outputs.submitAdditionalInfoTapped
            }
            .bind(to: viewModel.inputs.submitReportReasonTap)
            .disposed(by: disposeBag)

        // Open cancel observable - General
        let cancelReportReasonTapped = Observable.merge(viewModel.outputs.cancelReportReasonTapped,
                                                        cancelAdditionalInfoTapped)
        .map { _ -> OWReportReasonCancelViewViewModel in
            return OWReportReasonCancelViewViewModel()
        }
        .share()

        // Cancel tapped in cancel view - General
        let cancelReportCancelTapped = cancelReportReasonTapped
            .flatMap { reportReasonCancelViewVM -> Observable<Void> in
                return reportReasonCancelViewVM.outputs.cancelReportReasonCancelTapped
            }

        // MARK: Flow Setup

        // Submit - Open Submitted Screen - Flow
        let closeReportReasonSubmittedTapped = viewModel.outputs.submittedReportReasonObservable
            .filter { viewModel.outputs.viewableMode == .partOfFlow }
            .observe(on: MainScheduler.instance)
            .flatMap { [weak self] _ -> Observable<Void> in
                guard let self = self else { return .empty() }
                guard let router = self.router else { return .empty() }
                let reportReasonSubmittedViewVM = OWReportReasonSubmittedViewViewModel()
                let reportReasonSubmittedVC = OWReportReasonSubmittedVC(reportReasonSubmittedViewViewModel: reportReasonSubmittedViewVM)
                switch self.presentationalMode {
                case .present(let style):
                    reportReasonSubmittedVC.modalPresentationStyle = style.toOSModalPresentationStyle
                default:
                    reportReasonSubmittedVC.modalPresentationStyle = .fullScreen
                }
                router.present(reportReasonSubmittedVC, animated: true, dismissCompletion: nil)
                return reportReasonSubmittedViewVM.outputs.closeReportReasonSubmittedTapped
            }

        // Close ReportReason observable - General
        let closeReportReasonObservable = Observable.merge(viewModel.outputs.closeReportReasonTapped,
                                               additionalInfoCloseReportReasonTapped,
                                               cancelReportCancelTapped,
                                               closeReportReasonSubmittedTapped)
        .map { _ -> OWReportReasonCancelViewViewModel in
            return OWReportReasonCancelViewViewModel()
        }
        .share()

        // Open Additional information - Flow
        additionalInformationObservable
            .filter { _ in
                viewModel.outputs.viewableMode == .partOfFlow
            }
            .subscribe(onNext: { [weak self] additionalInfoViewVM in
                guard let self = self else { return }
                guard let router = self.router else { return }
                let additionalInfoViewVC = OWAdditionalInfoVC(additionalInfoViewViewModel: additionalInfoViewVM)
                router.push(additionalInfoViewVC, pushStyle: .regular, animated: true, popCompletion: nil)
            })
            .disposed(by: disposeBag)

        // Open cancel view - Flow
        cancelReportReasonTapped
            .filter { _ in
                viewModel.outputs.viewableMode == .partOfFlow
            }
            .subscribe(onNext: { [weak self] reportReasonViewModel in
                guard let self = self else { return }
                guard let router = self.router else { return }
                let ReportReasonCancelVM = OWReportReasonCancelViewModel(reportReasonCancelViewViewModel: reportReasonViewModel)
                let reportReasonCancelVC = OWReportReasonCancelVC(reportReasonCancelViewModel: ReportReasonCancelVM)
                switch self.presentationalMode {
                case .present(style: .fullScreen):
                    reportReasonCancelVC.modalPresentationStyle = .fullScreen
                case .present(style: .pageSheet):
                    reportReasonCancelVC.modalPresentationStyle = .pageSheet
                default:
                    reportReasonCancelVC.modalPresentationStyle = .fullScreen
                }
                router.present(reportReasonCancelVC, animated: true, dismissCompletion: nil)
            })
            .disposed(by: disposeBag)

        // Continue tapped in cancel view - Flow
        cancelReportReasonTapped
            .filter { _ in
                viewModel.outputs.viewableMode == .partOfFlow
            }
            .flatMap { reportReasonCancelViewVM -> Observable<Void> in
                return reportReasonCancelViewVM.outputs.closeReportReasonCancelTapped
            }
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                guard let router = self.router else { return }
                router.navigationController?.visibleViewController?.dismiss(animated: true)
            })
            .disposed(by: disposeBag)

        // Close Report Reason - Flow
        closeReportReasonObservable
            .filter { _ in
                viewModel.outputs.viewableMode == .partOfFlow
            }
            // Step 1 - Dismiss OWReportReasonSubmittedVC or OWReportReasonCancelVC
            .flatMap { [weak self] _ -> Observable<OWRoutering> in
                guard let self = self,
                      let router = self.router else { return .empty() }
                let visableViewController = router.navigationController?.visibleViewController
                let isReportReasonVC = visableViewController?.isKind(of: OWReportReasonVC.self) ?? false

                // For dismissing OWReportReasonSubmittedVC and OWReportReasonCancelVC screens
                if !isReportReasonVC {
                    let hasMoreThanOneViewController = router.numberOfActiveViewControllers > 1
                    visableViewController?.dismiss(animated: hasMoreThanOneViewController)
                }
                return .just(router)
            }
            // Step 2 - Dismiss report reason screen if it is the only one in the router or Pop if router has previous VCs
            .subscribe(onNext: { [weak self] router in
                guard let self = self,
                      let controllerToPopTo = router.navigationController?.viewControllers.first(where: {
                    $0.isKind(of: OWReportReasonVC.self)
                }) else { return }

                // Pop AdditionaInfo screen or any other screens after ReportReasonVC
                router.pop(toViewController: controllerToPopTo, animated: false)

                let hasOnlyOneViewController = router.numberOfActiveViewControllers == 1
                if hasOnlyOneViewController {
                    router.dismiss(animated: true, completion: self.reportReasonPopped)
                } else {
                    router.pop(popStyle: .dismissStyle, animated: true)
                }
            })
            .disposed(by: disposeBag)

        // Open Guidelines - Flow
        viewModel.outputs.learnMoreTapped
            .unwrap()
            .filter { _ in
                return viewModel.outputs.viewableMode == .partOfFlow
            }
            .flatMap { [weak self] url -> Observable<OWSafariTabCoordinatorResult> in
                guard let self = self else { return .empty() }
                guard let router = self.router else { return .empty() }
                let safariCoordinator = OWSafariTabCoordinator(router: router,
                                                               url: url,
                                                               actionsCallbacks: self.actionsCallbacks)
                return self.coordinate(to: safariCoordinator, deepLinkOptions: .none)
            }
            .subscribe()
            .disposed(by: disposeBag)

        // MARK: Independent Setup

        // Submit - Open Submitted Screen - Independent
        let closeSubmittedViewTapped = viewModel.outputs.submittedReportReasonObservable
            .voidify()
            .filter { viewModel.outputs.viewableMode == .independent }
            .observe(on: MainScheduler.instance)
            .flatMap { [weak self] _ -> Observable<Void> in
                guard let self = self else { return .empty() }
                let reportReasonSubmittedViewVM = OWReportReasonSubmittedViewViewModel()
                let reportReasonSubmittedView = OWReportReasonSubmittedView(viewModel: reportReasonSubmittedViewVM)

                reportReasonSubmittedView.alpha = 0
                self.reportReasonView?.addSubview(reportReasonSubmittedView)
                UIView.animate(withDuration: Metrics.fadeDuration) {
                    reportReasonSubmittedView.alpha = 1
                }
                reportReasonSubmittedView.OWSnp.makeConstraints { make in
                    make.edges.equalToSuperview()
                }
                return reportReasonSubmittedViewVM.outputs.closeReportReasonSubmittedTapped
            }

        // Close Report reason from Submitted Screen - Independent
        closeSubmittedViewTapped
            .map { OWViewActionCallbackType.closeReportReason }
            .subscribe(onNext: { [weak self] viewActionType in
                guard let self = self else { return }
                self.viewActionsService.append(viewAction: viewActionType)
            })
            .disposed(by: disposeBag)

        // Open Additional information - Independent
        let additionalInformationViewObservable = additionalInformationObservable
            .filter { _ in
                viewModel.outputs.viewableMode == .independent
            }
            .map { [weak self] additionalInfoViewVM -> OWAdditionalInfoView? in
                guard let self = self else { return nil }
                let additionalInfoView = OWAdditionalInfoView(viewModel: additionalInfoViewVM)

                additionalInfoView.alpha = 0
                self.reportReasonView?.addSubview(additionalInfoView)
                UIView.animate(withDuration: Metrics.fadeDuration) {
                    additionalInfoView.alpha = 1
                }
                additionalInfoView.OWSnp.makeConstraints { make in
                    make.edges.equalToSuperview()
                }

                return additionalInfoView
            }
            .unwrap()
            .share()

        additionalInformationViewObservable
            .subscribe()
            .disposed(by: disposeBag)

        // Close Additional information tapped - Independent
        additionalInformationObservable
            .flatMap { additionalInfoViewVM -> Observable<Void> in
                return additionalInfoViewVM.outputs.closeAdditionalInfoTapped
            }
            .withLatestFrom(additionalInformationViewObservable)
            .subscribe(onNext: { additionalInformationView in
                UIView.animate(withDuration: Metrics.fadeDuration) {
                    additionalInformationView.alpha = 0
                } completion: { _ in
                    additionalInformationView.removeFromSuperview()
                }
            })
            .disposed(by: disposeBag)

        // Close Report Reason - Independent
        closeReportReasonObservable
            .filter { _ in
                viewModel.outputs.viewableMode == .independent
            }
            .voidify()
            .map { OWViewActionCallbackType.closeReportReason }
            .subscribe(onNext: { [weak self] viewActionType in
                guard let self = self else { return }
                self.viewActionsService.append(viewAction: viewActionType)
            })
            .disposed(by: disposeBag)

        // Open cancel view - Independent
        let cancelViewObservable = cancelReportReasonTapped
            .filter { _ in
                viewModel.outputs.viewableMode == .independent
            }
            .map { reportReasonCancelViewVM -> OWReportReasonCancelView in
                let reportReasonCancelView = OWReportReasonCancelView(viewModel: reportReasonCancelViewVM)
                reportReasonCancelView.alpha = 0
                self.reportReasonView?.addSubview(reportReasonCancelView)
                UIView.animate(withDuration: Metrics.fadeDuration) {
                    reportReasonCancelView.alpha = 1
                }
                reportReasonCancelView.OWSnp.makeConstraints { make in
                    make.edges.equalToSuperview()
                }

                return reportReasonCancelView
            }
            .share(replay: 1)

        // Subscribe to above - General
        cancelViewObservable
            .subscribe()
            .disposed(by: disposeBag)

        // Continue tapped in cancel view - Independent
        cancelReportReasonTapped
            .filter { _ in
                viewModel.outputs.viewableMode == .independent
            }
            .flatMap { reportReasonCancelViewVM -> Observable<Void> in
                return reportReasonCancelViewVM.outputs.closeReportReasonCancelTapped.take(1)
            }
            .flatMap { _ -> Observable<OWReportReasonCancelView> in
                return cancelViewObservable.take(1)
            }
            .subscribe(onNext: { reportReasonCancelView in
                UIView.animate(withDuration: Metrics.fadeDuration) {
                    reportReasonCancelView.alpha = 0
                } completion: { _ in
                    reportReasonCancelView.removeFromSuperview()
                }
            })
            .disposed(by: disposeBag)

        // Open Guidelines - Independent
        viewModel.outputs.learnMoreTapped
            .unwrap()
            .filter { _ in
                return viewModel.outputs.viewableMode == .independent
            }
            .subscribe(onNext: { [weak self] url in
                guard let self = self else { return }
                self.viewActionsService.append(viewAction: OWViewActionCallbackType.communityGuidelinesPressed(url: url))
            })
            .disposed(by: disposeBag)
    }
}
