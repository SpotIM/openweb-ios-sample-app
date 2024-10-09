//
//  OWClarityDetailsCoordinator.swift
//  OpenWebSDK
//
//  Created by  Nogah Melamed on 22/08/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation
import RxSwift

enum OWClarityDetailsCoordinatorResult: OWCoordinatorResultProtocol {
    case loadedToScreen
    case popped

    var loadedToScreen: Bool {
        switch self {
        case .loadedToScreen:
            return true
        default:
            return false
        }
    }
}

class OWClarityDetailsCoordinator: OWBaseCoordinator<OWClarityDetailsCoordinatorResult> {
    fileprivate struct Metrics {
        static let fadeDuration: CGFloat = 0.3
        static let delayTapForOpenAdditionalInfo = 100 // Time in ms
    }

    fileprivate let data: OWClarityDetailsRequireData
    fileprivate let router: OWRoutering?
    fileprivate let viewActionsCallbacks: OWViewActionsCallbacks?
    fileprivate lazy var viewActionsService: OWViewActionsServicing = {
        return OWViewActionsService(viewActionsCallbacks: viewActionsCallbacks, viewSourceType: .clarityDetails)
    }()

    let presentationalMode: OWPresentationalModeCompact

    init(data: OWClarityDetailsRequireData,
         router: OWRoutering? = nil,
         viewActionsCallbacks: OWViewActionsCallbacks?,
         presentationalMode: OWPresentationalModeCompact = .none) {
        self.data = data
        self.router = router
        self.viewActionsCallbacks = viewActionsCallbacks
        self.presentationalMode = presentationalMode
    }

    override func start(coordinatorData: OWCoordinatorData? = nil) -> Observable<OWClarityDetailsCoordinatorResult> {
        guard let router = router else { return .empty() }
        let clarityDetailsVM: OWClarityDetailsViewModeling = OWClarityDetailsVM(data: data, viewableMode: .partOfFlow)
        let clarityDetailsVC = OWClarityDetailsVC(viewModel: clarityDetailsVM)

        let clarityDetailsPopped = PublishSubject<Void>()
        router.push(clarityDetailsVC,
                    pushStyle: .present,
                    animated: true,
                    popCompletion: clarityDetailsPopped)

        setupViewActionsCallbacks(forViewModel: clarityDetailsVM.outputs.clarityDetailsViewViewModel)

        let dismissObservable = clarityDetailsVM.outputs.clarityDetailsViewViewModel
            .outputs.dismissView
            .asObservable()

        let poppedFromCloseButtonObservable = clarityDetailsVM.outputs.clarityDetailsViewViewModel
            .outputs.closeButtonPopped
            .asObservable()

        let loadedToScreenObservable = clarityDetailsVM.outputs.loadedToScreen
            .map { OWClarityDetailsCoordinatorResult.loadedToScreen }
            .asObservable()

        let resultsWithPopAnimation = Observable.merge(dismissObservable, poppedFromCloseButtonObservable)
            .map { OWClarityDetailsCoordinatorResult.popped }
            .observe(on: MainScheduler.instance)
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.router?.pop(popStyle: .dismiss, animated: false)
            })

        let resultWithoutPopAnimation = clarityDetailsPopped
                .asObservable()
                .map { OWClarityDetailsCoordinatorResult.popped }

        // Coordinate to safari tab
        let communityGuidelinesURLTapped = clarityDetailsVM
                .outputs
                .clarityDetailsViewViewModel
                .outputs
                .communityGuidelinesClickObservable

        let coordinateToSafariObservables = Observable.merge(
            communityGuidelinesURLTapped
        )

        let coordinateToSafariObservable = coordinateToSafariObservables
            .flatMap { [weak self] url -> Observable<OWWebTabCoordinatorResult> in
                guard let self = self,
                      let router = self.router
                else { return .empty() }
                let title = clarityDetailsVM.outputs.clarityDetailsViewViewModel
                    .outputs.navigationTitle
                let options = OWWebTabOptions(url: url,
                                                 title: title)
                let safariCoordinator = OWWebTabCoordinator(router: router,
                                                               options: options,
                                                               viewActionsCallbacks: self.viewActionsCallbacks)
                return self.coordinate(to: safariCoordinator, coordinatorData: nil)
            }
            .do(onNext: { result in
                switch result {
                case .loadedToScreen:
                    break
                    // Nothing
                case .popped:
                    break
                }
            })
            .flatMap { _ -> Observable<OWClarityDetailsCoordinatorResult> in
                return Observable.never()
            }

        // Coordinate to appeal
        let appealTapped = clarityDetailsVM
                .outputs
                .clarityDetailsViewViewModel
                .outputs
                .appealLabelViewModel
                .outputs
                .openAppeal

        let coordinateToAppealObservable = appealTapped
            .flatMap { [weak self] data -> Observable<OWCommenterAppealCoordinatorResult> in
                guard let self = self,
                      let router = self.router
                else { return .empty() }

                let appealCoordinator = OWCommenterAppealCoordinator(router: router,
                                                                     appealData: data,
                                                                     viewActionsCallbacks: self.viewActionsCallbacks)
                return self.coordinate(to: appealCoordinator, coordinatorData: nil)
            }
            .flatMap { [weak self] result -> Observable<OWClarityDetailsCoordinatorResult> in
                switch result {
                case .loadedToScreen:
                    return Observable.never()
                    // Nothing
                case .popped:
                    self?.router?.pop(popStyle: .dismiss, animated: false)
                    return Observable.just(OWClarityDetailsCoordinatorResult.popped)
                }
            }

        return Observable.merge(resultsWithPopAnimation, loadedToScreenObservable, coordinateToSafariObservable, resultWithoutPopAnimation, coordinateToAppealObservable)
    }

    override func showableComponent() -> Observable<OWShowable> {
        let clarityDetailsViewVM: OWClarityDetailsViewViewModeling = OWClarityDetailsViewVM(data: data)

        setupViewActionsCallbacks(forViewModel: clarityDetailsViewVM)

        let clarityDetailsView = OWClarityDetailsView(viewModel: clarityDetailsViewVM)
        return .just(clarityDetailsView)
    }
}

fileprivate extension OWClarityDetailsCoordinator {
    func setupViewActionsCallbacks(forViewModel viewModel: OWClarityDetailsViewViewModeling) {
        // MARK: General (Used for both Flow and Independent)
        guard viewActionsCallbacks != nil else { return } // Make sure actions callbacks are available/provided

        let dismissView = viewModel.outputs.dismissView
            .map { OWViewActionCallbackType.closeClarityDetails }
        let closeButtonClick = viewModel.outputs.closeButtonPopped
            .map { OWViewActionCallbackType.closeClarityDetails }

        let openCommunityGuidelines = viewModel.outputs.communityGuidelinesClickObservable
            .map { OWViewActionCallbackType.communityGuidelinesPressed(url: $0) }

        let openCommenterAppeal = viewModel.outputs.appealLabelViewModel
            .outputs.openAppeal
            .map { OWViewActionCallbackType.openCommenterAppeal(data: $0) }

        Observable.merge(
            dismissView,
            closeButtonClick,
            openCommunityGuidelines,
            openCommenterAppeal
        )
        .subscribe(onNext: { [weak self] viewActionType in
            self?.viewActionsService.append(viewAction: viewActionType)
        })
        .disposed(by: disposeBag)
    }
}
