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

class OWReportReasonCoordinator: OWBaseCoordinator<OWReportReasonCoordinatorResult> {
    fileprivate struct Metrics {
        static let fadeDuration: CGFloat = 0.3
        static let delayTapForOpenAdditionalInfo = 100 // Time in ms
    }

    fileprivate let reportData: OWReportReasonsRequiredData
    fileprivate let router: OWRoutering?
    fileprivate let actionsCallbacks: OWViewActionsCallbacks?
    fileprivate lazy var viewActionsService: OWViewActionsServicing = {
        return OWViewActionsService(viewActionsCallbacks: actionsCallbacks, viewSourceType: .reportReason)
    }()

    fileprivate let reportReasonPopped = PublishSubject<Void>()
    fileprivate var isUserSubmitted: Bool = false

    let presentationalMode: OWPresentationalModeCompact
    var reportReasonView: UIView?

    init(reportData: OWReportReasonsRequiredData,
         router: OWRoutering? = nil,
         actionsCallbacks: OWViewActionsCallbacks?,
         presentationalMode: OWPresentationalModeCompact = .none) {
        self.reportData = reportData
        self.router = router
        self.actionsCallbacks = actionsCallbacks
        self.presentationalMode = presentationalMode
    }

    override func start(deepLinkOptions: OWDeepLinkOptions? = nil) -> Observable<OWReportReasonCoordinatorResult> {
        guard let router = router else { return .empty() }
        let reportReasonVM: OWReportReasonViewModeling = OWReportReasonViewModel(reportData: reportData,
                                                                                 viewableMode: .partOfFlow,
                                                                                 presentMode: self.presentationalMode)
        let reportReasonVC = OWReportReasonVC(viewModel: reportReasonVM)

        if router.isEmpty() {
            router.start()
            router.setRoot(reportReasonVC, animated: false, dismissCompletion: reportReasonPopped)
        } else {
            router.push(reportReasonVC,
                        pushStyle: .present,
                        animated: true,
                        popCompletion: reportReasonPopped)
        }

        let reportReasonViewViewModel = reportReasonVM.outputs.reportReasonViewViewModel
        self.setupObservers(forViewModel: reportReasonViewViewModel)

        let reportReasonPoppedObservable = reportReasonPopped
            .filter { [weak self] _ -> Bool in
                guard let self = self else { return false }
                return !self.isUserSubmitted
            }
            .map { OWReportReasonCoordinatorResult.popped }
            .asObservable()

        let reportReasonSubmittedObservable = reportReasonPopped
            .filter { [weak self] _ -> Bool in
                guard let self = self else { return false }
                return self.isUserSubmitted
            }
            .flatMapLatest { [weak reportReasonViewViewModel] _ -> Observable<OWCommentId> in
                guard let vm = reportReasonViewViewModel else { return Observable.empty() }
                return vm.outputs.reportReasonSubmittedSuccessfully
            }
            .map { OWReportReasonCoordinatorResult.submitedReport(commentId: $0) }
            .asObservable()

        let reportReasonLoadedToScreenObservable = reportReasonVM.outputs.loadedToScreen
            .map { OWReportReasonCoordinatorResult.loadedToScreen }
            .asObservable()

        // Open Guidelines
        let learnMoreObservable = reportReasonVM.outputs.reportReasonViewViewModel
            .outputs.learnMoreTapped
            .unwrap()
            .flatMap { [weak self] url -> Observable<OWWebTabCoordinatorResult> in
                guard let self = self else { return .empty() }
                guard let router = self.router else { return .empty() }
                let options = OWWebTabOptions(url: url,
                                                 title: "")
                let safariCoordinator = OWWebTabCoordinator(router: router,
                                                               options: options,
                                                               actionsCallbacks: self.actionsCallbacks)
                return self.coordinate(to: safariCoordinator, deepLinkOptions: .none)
            }
            .flatMap { _ -> Observable<OWReportReasonCoordinatorResult> in
                return Observable.never()
            }

        return Observable.merge(reportReasonPoppedObservable, reportReasonSubmittedObservable, reportReasonLoadedToScreenObservable, learnMoreObservable)
    }

    override func showableComponent() -> Observable<OWShowable> {
        let reportReasonViewVM: OWReportReasonViewViewModeling = OWReportReasonViewViewModel(reportData: reportData,
                                                                                             viewableMode: .independent,
                                                                                             presentationalMode: .none,
                                                                                             servicesProvider: OWSharedServicesProvider.shared)
        setupObservers(forViewModel: reportReasonViewVM)

        let reportReasonView = OWReportReasonView(viewModel: reportReasonViewVM)
        self.reportReasonView = reportReasonView
        return .just(reportReasonView)
    }
}

fileprivate extension OWReportReasonCoordinator {
    // swiftlint:disable function_body_length
    func setupObservers(forViewModel viewModel: OWReportReasonViewViewModeling) {
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

        // Submit - Open Submitted Screen - Flow
        let closeReportReasonSubmittedTapped = viewModel.outputs.submittedReportReasonObservable
            .filter { viewModel.outputs.viewableMode == .partOfFlow }
            .observe(on: MainScheduler.instance)
            .flatMap { [weak self] _ -> Observable<Void> in
                guard let self = self else { return .empty() }
                guard let router = self.router else { return .empty() }
                let reportReasonSubmittedViewVM = OWSubmittedViewViewModel()
                let reportReasonSubmittedVC = OWSubmittedVC(submittedViewViewModel: reportReasonSubmittedViewVM)
                switch self.presentationalMode {
                case .present(let style):
                    reportReasonSubmittedVC.modalPresentationStyle = style.toOSModalPresentationStyle
                default:
                    reportReasonSubmittedVC.modalPresentationStyle = .fullScreen
                }
                router.present(reportReasonSubmittedVC, animated: true, dismissCompletion: nil)
                return reportReasonSubmittedViewVM.outputs.closeSubmittedTapped
            }
            .do(onNext: { [weak self] in
                guard let self = self else { return }
                self.isUserSubmitted = true
            })

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
            .filter { _ in
                viewModel.outputs.viewableMode == .independent
            }
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

          // Open cancel observable - General
          let cancelReportReasonTapped = Observable.merge(viewModel.outputs.cancelReportReasonTapped,
                                                          cancelAdditionalInfoTapped)
              .map { _ -> OWCancelViewViewModel in
                  return OWCancelViewViewModel(type: .reportReason)
              }
              .share()

          // Cancel tapped in cancel view - General
          let cancelReportCancelTapped = cancelReportReasonTapped
              .flatMap { reportReasonCancelViewVM -> Observable<Void> in
                  return reportReasonCancelViewVM.outputs.cancelTapped
              }

          // Close ReportReason observable - General
          let closeReportReasonObservable = Observable.merge(viewModel.outputs.closeReportReasonTapped,
                                                 additionalInfoCloseReportReasonTapped,
                                                 cancelReportCancelTapped,
                                                 closeReportReasonSubmittedTapped)
              .map { _ -> OWCancelViewViewModel in
                  return OWCancelViewViewModel(type: .reportReason)
              }
              .share()

        // Continue tapped in cancel view - Flow
        cancelReportReasonTapped
            .filter { _ in
                viewModel.outputs.viewableMode == .partOfFlow
            }
            .flatMap { reportReasonCancelViewVM -> Observable<Void> in
                return reportReasonCancelViewVM.outputs.closeTapped
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
                guard let self = self else { return }

                guard let controllerToPopTo = router.navigationController?.viewControllers.first(where: {
                    $0.isKind(of: OWReportReasonVC.self)
                }) else { return }

                // Pop AdditionaInfo screen or any other screens after ReportReasonVC
                router.pop(toViewController: controllerToPopTo, animated: false)

                let hasOnlyOneViewController = router.numberOfActiveViewControllers == 1
                if hasOnlyOneViewController {
                    router.dismiss(animated: true, completion: self.reportReasonPopped)
                } else {
                    router.pop(popStyle: .dismiss, animated: true)
                }
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
                let ReportReasonCancelVM = OWCancelViewModel(cancelViewViewModel: reportReasonViewModel)
                let reportReasonCancelVC = OWCancelVC(cancelViewModel: ReportReasonCancelVM)
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

        // Submit - Open Submitted Screen - Independent
        let closeSubmittedViewTapped = viewModel.outputs.submittedReportReasonObservable
            .voidify()
            .filter { viewModel.outputs.viewableMode == .independent }
            .observe(on: MainScheduler.instance)
            .flatMap { [weak self] _ -> Observable<Void> in
                guard let self = self else { return .empty() }
                let reportReasonSubmittedViewVM = OWSubmittedViewViewModel()
                let reportReasonSubmittedView = OWSubmittedView(viewModel: reportReasonSubmittedViewVM)

                reportReasonSubmittedView.alpha = 0
                self.reportReasonView?.addSubview(reportReasonSubmittedView)
                UIView.animate(withDuration: Metrics.fadeDuration) {
                    reportReasonSubmittedView.alpha = 1
                }
                reportReasonSubmittedView.OWSnp.makeConstraints { make in
                    make.edges.equalToSuperview()
                }
                return reportReasonSubmittedViewVM.outputs.closeSubmittedTapped
            }

        // Open cancel view - Independent
        let cancelViewObservable = cancelReportReasonTapped
            .filter { _ in
                viewModel.outputs.viewableMode == .independent
            }
            .map { [weak self] reportReasonCancelViewVM -> OWCancelView? in
                guard let self = self else { return nil }
                let reportReasonCancelView = OWCancelView(viewModel: reportReasonCancelViewVM)
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
            .unwrap()
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
                return reportReasonCancelViewVM.outputs.closeTapped.take(1)
            }
            .flatMap { _ -> Observable<OWCancelView> in
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

        // Close Report reason from Submitted Screen
        let closeSubmittedCallbackObservable =  closeSubmittedViewTapped
            .map { OWViewActionCallbackType.closeReportReason }

        // Close Report Reason
        let closeReportReasonCallbackObservable = closeReportReasonObservable
            .filter { _ in
                viewModel.outputs.viewableMode == .independent
            }
            .voidify()
            .map { OWViewActionCallbackType.closeReportReason }

        // Open Guidelines
        let learnMoreCallbackObservable = viewModel.outputs.learnMoreTapped
            .unwrap()
            .map {  OWViewActionCallbackType.communityGuidelinesPressed(url: $0) }

        // Setup view actions callbacks - Independent mode only
        Observable.merge(closeSubmittedCallbackObservable, closeReportReasonCallbackObservable, learnMoreCallbackObservable)
            .filter { _ in
                viewModel.outputs.viewableMode == .independent
            }
            .subscribe(onNext: { [weak self] viewAction in
                guard let self = self else { return }
                self.viewActionsService.append(viewAction: viewAction)
            })
            .disposed(by: disposeBag)
    }
}
