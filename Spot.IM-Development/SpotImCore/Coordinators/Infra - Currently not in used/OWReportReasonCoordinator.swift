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
        viewModel.outputs
            .reportReasonViewViewModel.outputs.closeReportReasonTapped
            .filter { viewModel.outputs.viewableMode == .independent }
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                    print("Open Cancel report view")
            })
            .disposed(by: disposeBag)

        viewModel.outputs
            .reportReasonViewViewModel.outputs.closeReportReasonTapped
            .filter { viewModel.outputs.viewableMode == .partOfFlow }
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                    // Open Cancel report screen
                print("Open Cancel report screen")
                self.router.navigationController?.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
    }
}
