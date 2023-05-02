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

    fileprivate let router: OWRoutering
    fileprivate let actionsCallbacks: OWViewActionsCallbacks?
    let presentationalMode: OWPresentationalModeCompact

    init(router: OWRoutering, actionsCallbacks: OWViewActionsCallbacks?, presentationalMode: OWPresentationalModeCompact) {
        self.router = router
        self.actionsCallbacks = actionsCallbacks
        self.presentationalMode = presentationalMode
    }

    override func start(deepLinkOptions: OWDeepLinkOptions? = nil) -> Observable<OWReportReasonCoordinatorResult> {
        // TODO: complete the flow
        let reportReasonVM: OWReportReasonViewModeling = OWReportReasonViewModel(viewableMode: .partOfFlow, presentMode: self.presentationalMode)
        let reportReasonVC = OWReportReasonVC(viewModel: reportReasonVM)

        let reportReasonPopped = PublishSubject<Void>()

        router.start()

        if router.isEmpty() {
            router.setRoot(reportReasonVC, animated: false, dismissCompletion: reportReasonPopped)
        } else {
            router.push(reportReasonVC,
                        pushStyle: .regular,
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
            .debug("Alon start ended")
    }

    override func showableComponent() -> Observable<OWShowable> {
        // TODO: Complete when we would like to support comment creation as a view
        let reportReasonViewVM: OWReportReasonViewViewModeling = OWReportReasonViewViewModel(viewableMode: .independent,
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
        // Cancel Independent
        Observable.merge(viewModel.outputs.reportReasonViewViewModel.outputs.closeReportReasonTapped,
                         viewModel.outputs.reportReasonViewViewModel.outputs.cancelReportReasonTapped)
                        .filter { viewModel.outputs.viewableMode == .independent }
                        .subscribe(onNext: { [weak self] _ in
                            guard let self = self else { return }
                                print("Open Independent Cancel report view")
                        })
                        .disposed(by: disposeBag)

        // Cancel Flow
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
                .subscribe { _ in
                    reportReasonCancelVC.dismiss(animated: true)
                }
                .disposed(by: disposeBag)
        })
        .disposed(by: disposeBag)

        // Submit Flow
        viewModel.outputs
            .reportReasonViewViewModel.outputs.submitReportReasonTapped
            .subscribe { [weak self] _ in
                guard let self = self else { return }
                let reportReasonThanksViewVM = OWReportReasonThanksViewViewModel()
                let reportReasonThanksVC = OWReportReasonThanksVC(reportReasonThanksViewViewModel: reportReasonThanksViewVM)
                reportReasonThanksVC.modalPresentationStyle = .fullScreen
                self.router.present(reportReasonThanksVC, animated: true, dismissCompletion: nil)

                reportReasonThanksViewVM.closeReportReasonThanksTap
                    .subscribe { [weak self] _ in
                        guard let self = self else { return }
                        self.router.dismiss(animated: true, completion: nil)
                    }
                    .disposed(by: disposeBag)
            }
            .disposed(by: disposeBag)

        // Additional information
        viewModel.outputs.reportReasonViewViewModel.outputs
            .textViewVM.outputs.textViewTapped
            .subscribe { [weak self] (placeholderText, textViewText) in
                guard let self = self else { return }
                let additionalInfoViewVM = OWAdditionalInfoViewViewModel(viewableMode: viewModel.outputs.viewableMode,
                                                                         placeholderText: placeholderText,
                                                                         textViewText: textViewText)
                let additionalInfoViewVC = OWAdditionalInfoVC(additionalInfoViewViewModel: additionalInfoViewVM)
                self.router.push(additionalInfoViewVC, pushStyle: .regular, animated: true, popCompletion: nil)

                additionalInfoViewVM.outputs.cancelAdditionalInfoTapped
                    .take(1)
                    .subscribe { [weak self] _ in
                        guard let self = self else { return }
                        self.router.pop(animated: true)
                    }
                    .disposed(by: self.disposeBag)

                additionalInfoViewVM.outputs.submitAdditionalInfoTapped
                    .take(1)
                    .subscribe { [weak self] text in
                        guard let self = self else { return }
                        viewModel.outputs.reportReasonViewViewModel.outputs.textViewVM.inputs.textViewTextChange.onNext(text)
                        self.router.pop(animated: true)
                    }
                    .disposed(by: self.disposeBag)
            }
            .disposed(by: disposeBag)
    }
}
