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

    fileprivate let type: OWClarityDetailsType
    fileprivate let router: OWRoutering?
    fileprivate let actionsCallbacks: OWViewActionsCallbacks?
    fileprivate lazy var viewActionsService: OWViewActionsServicing = {
        return OWViewActionsService(viewActionsCallbacks: actionsCallbacks, viewSourceType: .reportReason)
    }()
    fileprivate let ClarityDetailsPopped = PublishSubject<Void>()
    let presentationalMode: OWPresentationalModeCompact
//    var clarityDetailsView: UIView?

    init(type: OWClarityDetailsType,
         router: OWRoutering? = nil,
         actionsCallbacks: OWViewActionsCallbacks?,
         presentationalMode: OWPresentationalModeCompact = .none) {
        self.type = type
        self.router = router
        self.actionsCallbacks = actionsCallbacks
        self.presentationalMode = presentationalMode
    }

    override func start(deepLinkOptions: OWDeepLinkOptions? = nil) -> Observable<OWClarityDetailsCoordinatorResult> {
        guard let router = router else { return .empty() }
        let clarityDetailsVM: OWClarityDetailsViewModeling = OWClarityDetailsVM(type: type, viewableMode: .partOfFlow)
//        , presentMode: self.presentationalMode TODO: is it needed?
        let clarityDetailsVC = OWClarityDetailsVC(viewModel: clarityDetailsVM)

        if router.isEmpty() {
            router.start()
            router.setRoot(clarityDetailsVC, animated: false, dismissCompletion: ClarityDetailsPopped)
        } else {
            router.push(clarityDetailsVC,
                        pushStyle: .presentStyle,
                        animated: true,
                        popCompletion: ClarityDetailsPopped)
        }

        setupViewActionsCallbacks(forViewModel: clarityDetailsVM.outputs.clarityDetailsViewViewModel)

        let dismissObservable = clarityDetailsVM.outputs.clarityDetailsViewViewModel
            .outputs.dismissView
            .map { OWClarityDetailsCoordinatorResult.popped }
            .asObservable()

//        let commentCreationLoadedToScreenObservable = commentCreationVM.outputs.loadedToScreen
//            .map { OWCommentCreationCoordinatorResult.loadedToScreen }
//            .asObservable()

        let resultsWithPopAnimation = dismissObservable
            .observe(on: MainScheduler.instance)
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.router?.pop(popStyle: .dismissStyle, animated: false)
            })

        return Observable.merge(resultsWithPopAnimation, dismissObservable)
    }

    override func showableComponent() -> Observable<OWShowable> {
        let clarityDetailsViewVM: OWClarityDetailsViewViewModeling = OWClarityDetailsViewVM(type: type)
        setupViewActionsCallbacks(forViewModel: clarityDetailsViewVM)

        let clarityDetailsView = OWClarityDetailsView(viewModel: clarityDetailsViewVM)
//        self.clarityDetailsView = clarityDetailsView
        return .just(clarityDetailsView)
    }
}

fileprivate extension OWClarityDetailsCoordinator {
    func setupViewActionsCallbacks(forViewModel viewModel: OWClarityDetailsViewViewModeling) {
        // MARK: General (Used for both Flow and Independent)
        // TODO: cancel, exit, communityGuidelines
        guard actionsCallbacks != nil else { return } // Make sure actions callbacks are available/provided

        let dismissView = viewModel.outputs.dismissView
            .map { OWViewActionCallbackType.closeReportReason }

        Observable.merge(dismissView)
            .subscribe(onNext: { [weak self] viewActionType in
                self?.viewActionsService.append(viewAction: viewActionType)
            })
            .disposed(by: disposeBag)

    }
}
