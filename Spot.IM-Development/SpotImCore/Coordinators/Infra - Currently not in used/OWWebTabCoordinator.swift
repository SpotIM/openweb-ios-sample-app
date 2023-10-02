//
//  OWWebTabCoordinator.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 09/11/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

enum OWWebTabCoordinatorResult: OWCoordinatorResultProtocol {
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

class OWWebTabCoordinator: OWBaseCoordinator<OWWebTabCoordinatorResult> {

    fileprivate let router: OWRoutering
    fileprivate let options: OWWebTabOptions
    fileprivate let actionsCallbacks: OWViewActionsCallbacks?
    fileprivate var viewableMode: OWViewableMode!
    fileprivate lazy var viewActionsService: OWViewActionsServicing = {
        return OWViewActionsService(viewActionsCallbacks: actionsCallbacks, viewSourceType: .commentThread)
    }()

    init(router: OWRoutering, options: OWWebTabOptions, actionsCallbacks: OWViewActionsCallbacks?) {
        self.router = router
        self.options = options
        self.actionsCallbacks = actionsCallbacks // TODO: handle actions callbacks?
    }

    override func start(deepLinkOptions: OWDeepLinkOptions? = nil) -> Observable<OWWebTabCoordinatorResult> {
        viewableMode = .partOfFlow
        let webTabVM = OWWebTabViewModel(options: options,
                                            viewableMode: .partOfFlow)
        let webTabVC = OWWebTabVC(viewModel: webTabVM)

        let webTabVCPopped = PublishSubject<Void>()

        router.push(webTabVC,
                    pushStyle: .regular,
                    animated: true,
                    popCompletion: webTabVCPopped)

        let webVCPoppedObservable = webTabVCPopped
            .map { OWWebTabCoordinatorResult.popped }
            .asObservable()

        let webVCLoadedToScreenObservable = webTabVM.outputs.screenLoaded
            .map { OWWebTabCoordinatorResult.loadedToScreen }
            .asObservable()

        return Observable.merge(webVCPoppedObservable, webVCLoadedToScreenObservable)
    }

    override func showableComponent() -> Observable<OWShowable> {
        viewableMode = .independent
        let webTabViewVM: OWWebTabViewViewModeling = OWWebTabViewViewModel(options: options,
                                                                                    viewableMode: viewableMode)
        let webTabView = OWWebTabView(viewModel: webTabViewVM)
        setupViewActionsCallbacks(forViewModel: webTabViewVM)
        return .just(webTabView)
    }
}

fileprivate extension OWWebTabCoordinator {
    func setupViewActionsCallbacks(forViewModel viewModel: OWWebTabViewViewModeling) {

    }
}
