//
//  OWReportReasonCoordinator.swift
//  SpotImCore
//
//  Created by Refael Sommer on 20/04/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

#if NEW_API

enum OWReportReasonCoordinatorResult: OWCoordinatorResultProtocol {
    case loadedToScreen
    case popped
    case submitedReport(report: OWReportReason)

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

    fileprivate let commentId: OWCommentId
    fileprivate let router: OWRoutering
    fileprivate let actionsCallbacks: OWViewActionsCallbacks?
    fileprivate let reportReasonPopped = PublishSubject<Void>()
    let presentationalMode: OWPresentationalModeCompact

    init(commentId: OWCommentId, router: OWRoutering, actionsCallbacks: OWViewActionsCallbacks?, presentationalMode: OWPresentationalModeCompact) {
        self.commentId = commentId
        self.router = router
        self.actionsCallbacks = actionsCallbacks
        self.presentationalMode = presentationalMode
    }

    override func start(deepLinkOptions: OWDeepLinkOptions? = nil) -> Observable<OWReportReasonCoordinatorResult> {
        // TODO: complete the flow
        let reportReasonVM: OWReportReasonViewModeling = OWReportReasonViewModel(commentId: commentId,
                                                                                 viewableMode: .partOfFlow,
                                                                                 presentMode: self.presentationalMode)
        let reportReasonVC = OWReportReasonVC(viewModel: reportReasonVM)

        router.start()

        if router.isEmpty() {
            router.setRoot(reportReasonVC, animated: false, dismissCompletion: reportReasonPopped)
        } else {
            router.push(reportReasonVC,
                        pushStyle: .presentStyle,
                        animated: true,
                        popCompletion: reportReasonPopped)
        }

        setupObservers(forViewModel: reportReasonVM)
        setupViewActionsCallbacks(forViewModel: reportReasonVM)

        let reportReasonPoppedObservable = reportReasonPopped
            .map { OWReportReasonCoordinatorResult.popped }
            .asObservable()

        let reportReasonLoadedToScreenObservable = reportReasonVM.outputs.loadedToScreen
            .map { OWReportReasonCoordinatorResult.loadedToScreen }
            .asObservable()

        return Observable.merge(reportReasonPoppedObservable, reportReasonLoadedToScreenObservable)
    }

    override func showableComponent() -> Observable<OWShowable> {
        // TODO: Complete when we would like to support comment creation as a view
        let reportReasonViewVM: OWReportReasonViewViewModeling = OWReportReasonViewViewModel(commentId: commentId,
                                                                                             viewableMode: .independent,
                                                                                             presentationalMode: .none,
                                                                                             servicesProvider: OWSharedServicesProvider.shared)
        let reportReasonView = OWReportReasonView(viewModel: reportReasonViewVM)
        return .just(reportReasonView)
    }
}

fileprivate extension OWReportReasonCoordinator {
    func setupObservers(forViewModel viewModel: OWReportReasonViewModeling) {
        // Setting up general observers which affect app flow however not entirely inside the SDK
    }

    func setupViewActionsCallbacks(forViewModel viewModel: OWReportReasonViewModeling) {
        // Open Cancel Independent
        Observable.merge(viewModel.outputs.reportReasonViewViewModel.outputs.closeReportReasonTapped,
                         viewModel.outputs.reportReasonViewViewModel.outputs.cancelReportReasonTapped)
                        .filter { viewModel.outputs.viewableMode == .independent }
                        .subscribe(onNext: { [weak self] _ in
                            guard let self = self else { return }
                                print("Open Independent Cancel report view")
                        })
                        .disposed(by: disposeBag)

        // Open Cancel - Flow
        Observable.merge(viewModel.outputs.reportReasonViewViewModel.outputs.closeReportReasonTapped,
                         viewModel.outputs.reportReasonViewViewModel.outputs.cancelReportReasonTapped)
        .filter { viewModel.outputs.viewableMode == .partOfFlow }
        .subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            let reportReasonCancelViewVM = OWReportReasonCancelViewViewModel()
            let reportReasonCancelVC = OWReportReasonCancelVC(reportReasonCancelViewViewModel: reportReasonCancelViewVM)
            reportReasonCancelVC.modalPresentationStyle = .fullScreen
            self.router.present(reportReasonCancelVC, animated: true, dismissCompletion: nil)

            reportReasonCancelViewVM.closeReportReasonCancelTap
                .subscribe(onNext: { _ in
                    reportReasonCancelVC.dismiss(animated: true)
                })
                .disposed(by: self.disposeBag)

            reportReasonCancelViewVM.cancelReportReasonCancelTap
                .subscribe(onNext: { _ in
                    // TODO close the whole Flow
                    reportReasonCancelVC.dismiss(animated: true)
                })
                .disposed(by: self.disposeBag)
        })
        .disposed(by: disposeBag)

        // Submit and Open Thanks Screen - Flow
        viewModel.outputs
            .reportReasonViewViewModel.outputs.submittedReportReasonObservable
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                let reportReasonThanksViewVM = OWReportReasonThanksViewViewModel()
                let reportReasonThanksVC = OWReportReasonThanksVC(reportReasonThanksViewViewModel: reportReasonThanksViewVM)
                reportReasonThanksVC.modalPresentationStyle = .fullScreen
                self.router.present(reportReasonThanksVC, animated: true, dismissCompletion: nil)

                reportReasonThanksViewVM.closeReportReasonThanksTap
                    .subscribe(onNext: { [weak self] _ in
                        guard let self = self else { return }
                        self.router.dismiss(animated: true, completion: nil)
                    })
                    .disposed(by: self.disposeBag)
            })
            .disposed(by: disposeBag)

        // Open Additional information - Flow
        let reportTextViewVM = viewModel.outputs.reportReasonViewViewModel.outputs
            .textViewVM
        reportTextViewVM.outputs.textViewTapped
            .flatMap { _ -> Observable<(String, String)> in
                return Observable.combineLatest(reportTextViewVM.outputs.placeholderText,
                                                reportTextViewVM.outputs.textViewText)
                .take(1)
            }
            .subscribe(onNext: { [weak self] placeholderText, textViewText in
                guard let self = self else { return }
                let additionalInfoViewVM = OWAdditionalInfoViewViewModel(viewableMode: viewModel.outputs.viewableMode,
                                                                         placeholderText: placeholderText,
                                                                         textViewText: textViewText)
                let additionalInfoViewVC = OWAdditionalInfoVC(additionalInfoViewViewModel: additionalInfoViewVM)
                self.router.push(additionalInfoViewVC, pushStyle: .regular, animated: true, popCompletion: nil)

                additionalInfoViewVM.outputs.cancelAdditionalInfoTapped
                    .debug("Refael cancelAdditionalInfoTapped ***")
                    .take(1)
                    .subscribe(onNext: { [weak self] _ in
                        guard let self = self else { return }
                        self.router.pop(animated: true)
                    })
                    .disposed(by: self.disposeBag)

                additionalInfoViewVM.outputs.submitAdditionalInfoTapped
                    .debug("Refael submitAdditionalInfoTapped ***")
                    .withLatestFrom(additionalInfoViewVM.outputs.textViewVM.outputs.textViewText)
                    .take(1)
                    .subscribe(onNext: { [weak self] textViewText in
                        guard let self = self else { return }
                        reportTextViewVM.inputs.textViewTextChange.onNext(textViewText)
                        self.router.pop(animated: true)
                    })
                    .disposed(by: self.disposeBag)
            })
            .disposed(by: disposeBag)

        // Open Guidelines - Flow
        viewModel.outputs.reportReasonViewViewModel.outputs.learnMoreTapped
            .unwrap()
            .filter { _ in // TODO: change to viewable mode
                return viewModel.outputs.viewableMode == .partOfFlow
            }
            .flatMap { [weak self] url -> Observable<OWSafariTabCoordinatorResult> in
                guard let self = self else { return .empty() }
                let safariCoordinator = OWSafariTabCoordinator(router: self.router,
                                                               url: url,
                                                               actionsCallbacks: self.actionsCallbacks)
                return self.coordinate(to: safariCoordinator, deepLinkOptions: .none)
            }
            .subscribe()
            .disposed(by: disposeBag)
    }
}

#endif
