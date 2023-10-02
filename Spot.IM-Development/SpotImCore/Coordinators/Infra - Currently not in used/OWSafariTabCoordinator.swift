//
//  OWSafariTabCoordinator.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 09/11/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift
import SafariServices

enum OWSafariTabCoordinatorResult: OWCoordinatorResultProtocol {
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

class OWSafariTabCoordinator: OWBaseCoordinator<OWSafariTabCoordinatorResult> {

    fileprivate let router: OWRoutering
    fileprivate let options: OWSafariTabOptions
    fileprivate let actionsCallbacks: OWViewActionsCallbacks?
    fileprivate var viewableMode: OWViewableMode!
    fileprivate lazy var viewActionsService: OWViewActionsServicing = {
        return OWViewActionsService(viewActionsCallbacks: actionsCallbacks, viewSourceType: .commentThread)
    }()

    init(router: OWRoutering, options: OWSafariTabOptions, actionsCallbacks: OWViewActionsCallbacks?) {
        self.router = router
        self.options = options
        self.actionsCallbacks = actionsCallbacks // TODO: handle actions callbacks?
    }

    override func start(deepLinkOptions: OWDeepLinkOptions? = nil) -> Observable<OWSafariTabCoordinatorResult> {
        viewableMode = .partOfFlow
        let safariVM = OWSafariTabViewModel(options: options,
                                            viewableMode: .partOfFlow)
        let safariVC = OWSafariTabVC(viewModel: safariVM)

        let safariVCPopped = PublishSubject<Void>()

        router.push(safariVC,
                    pushStyle: .regular,
                    animated: true,
                    popCompletion: safariVCPopped)

        let safariVCPoppedObservable = safariVCPopped
            .map { OWSafariTabCoordinatorResult.popped }
            .asObservable()

        let safariVCLoadedToScreenObservable = safariVM.outputs.screenLoaded
            .map { OWSafariTabCoordinatorResult.loadedToScreen }
            .asObservable()

        return Observable.merge(safariVCPoppedObservable, safariVCLoadedToScreenObservable)
    }

    override func showableComponent() -> Observable<OWShowable> {
        viewableMode = .independent
        let safariTabViewVM: OWSafariTabViewViewModeling = OWSafariTabViewViewModel(options: options,
                                                                                    viewableMode: viewableMode)
        let safariTabView = OWSafariTabView(viewModel: safariTabViewVM)
        setupViewActionsCallbacks(forViewModel: safariTabViewVM)
        return .just(safariTabView)
    }
}

fileprivate extension OWSafariTabCoordinator {
    func setupViewActionsCallbacks(forViewModel viewModel: OWSafariTabViewViewModeling) {

    }
}
