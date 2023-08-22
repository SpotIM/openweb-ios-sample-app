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

//    fileprivate let reportData: OWReportReasonsRequiredData // TODO: type?
    fileprivate let router: OWRoutering?
    fileprivate let actionsCallbacks: OWViewActionsCallbacks?
    fileprivate lazy var viewActionsService: OWViewActionsServicing = {
        return OWViewActionsService(viewActionsCallbacks: actionsCallbacks, viewSourceType: .reportReason)
    }()
    fileprivate let ClarityDetailsPopped = PublishSubject<Void>()
    let presentationalMode: OWPresentationalModeCompact
//    var clarityDetailsView: UIView?

    init(// reportData: OWReportReasonsRequiredData, // TODO: type
         router: OWRoutering? = nil,
         actionsCallbacks: OWViewActionsCallbacks?,
         presentationalMode: OWPresentationalModeCompact = .none) {
//        self.reportData = reportData
        self.router = router
        self.actionsCallbacks = actionsCallbacks
        self.presentationalMode = presentationalMode
    }

    override func start(deepLinkOptions: OWDeepLinkOptions? = nil) -> Observable<OWClarityDetailsCoordinatorResult> {
        guard let router = router else { return .empty() }
        let clarityDetailsVM: OWClarityDetailsViewModeling = OWClarityDetailsVM(viewableMode: .partOfFlow)
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

        let clarityDetailsPoppedObservable = ClarityDetailsPopped
            .map { OWClarityDetailsCoordinatorResult.popped }
            .asObservable()

        // TODO: is it needed?
//        let reportReasonLoadedToScreenObservable = reportReasonVM.outputs.loadedToScreen
//            .map { OWReportReasonCoordinatorResult.loadedToScreen }
//            .asObservable()

        return Observable.merge(clarityDetailsPoppedObservable)
    }

    override func showableComponent() -> Observable<OWShowable> {
        let clarityDetailsViewVM: OWClarityDetailsViewViewModeling = OWClarityDetailsViewVM()
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
    }
}
