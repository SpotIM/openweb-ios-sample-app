//
//  OWClarityDetailsCoordinator.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 22/08/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
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

    fileprivate let requiredData: OWClarityDetailsRequireData
    fileprivate let router: OWRoutering?
    fileprivate let actionsCallbacks: OWViewActionsCallbacks?
    fileprivate lazy var viewActionsService: OWViewActionsServicing = {
        return OWViewActionsService(viewActionsCallbacks: actionsCallbacks, viewSourceType: .clarityDetails)
    }()

    init(requiredData: OWClarityDetailsRequireData,
         router: OWRoutering? = nil,
         actionsCallbacks: OWViewActionsCallbacks?) {
        self.requiredData = requiredData
        self.router = router
        self.actionsCallbacks = actionsCallbacks
    }

    override func start(deepLinkOptions: OWDeepLinkOptions? = nil) -> Observable<OWClarityDetailsCoordinatorResult> {
        guard let router = router else { return .empty() }
        let clarityDetailsVM: OWClarityDetailsViewModeling = OWClarityDetailsVM(requiredData: requiredData, viewableMode: .partOfFlow)
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
                                                               actionsCallbacks: self.actionsCallbacks)
                return self.coordinate(to: safariCoordinator, deepLinkOptions: .none)
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

        return Observable.merge(resultsWithPopAnimation, loadedToScreenObservable, coordinateToSafariObservable, resultWithoutPopAnimation)
    }

    override func showableComponent() -> Observable<OWShowable> {
        let clarityDetailsViewVM: OWClarityDetailsViewViewModeling = OWClarityDetailsViewVM(requiredData: requiredData)
        setupViewActionsCallbacks(forViewModel: clarityDetailsViewVM)

        let clarityDetailsView = OWClarityDetailsView(viewModel: clarityDetailsViewVM)
        return .just(clarityDetailsView)
    }
}

fileprivate extension OWClarityDetailsCoordinator {
    func setupViewActionsCallbacks(forViewModel viewModel: OWClarityDetailsViewViewModeling) {
        // MARK: General (Used for both Flow and Independent)
        guard actionsCallbacks != nil else { return } // Make sure actions callbacks are available/provided

        let dismissView = viewModel.outputs.dismissView
            .map { OWViewActionCallbackType.closeClarityDetails }
        let closeButtonClick = viewModel.outputs.closeButtonPopped
            .map { OWViewActionCallbackType.closeClarityDetails }

        let openCommunityGuidelines = viewModel.outputs.communityGuidelinesClickObservable
            .map { OWViewActionCallbackType.communityGuidelinesPressed(url: $0) }

        Observable.merge(
            dismissView,
            closeButtonClick,
            openCommunityGuidelines
        )
        .subscribe(onNext: { [weak self] viewActionType in
            self?.viewActionsService.append(viewAction: viewActionType)
        })
        .disposed(by: disposeBag)
    }
}
