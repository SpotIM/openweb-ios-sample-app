//
//  OWCommentThreadCoordinator.swift
//  SpotImCore
//
//  Created by Alon Shprung on 27/02/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

enum OWCommentThreadCoordinatorResult: OWCoordinatorResultProtocol {
    case popped
    case loadedToScreen

    var loadedToScreen: Bool {
        switch self {
        case .loadedToScreen:
            return true
        default:
            return false
        }
    }
}

class OWCommentThreadCoordinator: OWBaseCoordinator<OWCommentThreadCoordinatorResult> {
    fileprivate let router: OWRoutering
    fileprivate let actionsCallbacks: OWViewActionsCallbacks?

    init(router: OWRoutering, actionsCallbacks: OWViewActionsCallbacks?) {
        self.router = router
        self.actionsCallbacks = actionsCallbacks
    }

    override func start(deepLinkOptions: OWDeepLinkOptions? = nil) -> Observable<OWCommentThreadCoordinatorResult> {
        let commentThreadVM: OWCommentThreadViewModeling = OWCommentThreadViewModel()
        let commentThreadVC = OWCommentThreadVC(viewModel: commentThreadVM)

        let commentThreadPopped = PublishSubject<Void>()

        router.push(commentThreadVC,
                    pushStyle: .presentStyle,
                    animated: true,
                    popCompletion: commentThreadPopped)

        setupObservers(forViewModel: commentThreadVM)
        setupViewActionsCallbacks(forViewModel: commentThreadVM)

        let commentThreadPoppedObservable = commentThreadPopped
            .map { OWCommentThreadCoordinatorResult.popped }
            .asObservable()

        let commentThreadLoadedToScreenObservable = commentThreadVM.outputs.loadedToScreen
            .map { OWCommentThreadCoordinatorResult.loadedToScreen }
            .asObservable()

        return Observable.merge(commentThreadPoppedObservable, commentThreadLoadedToScreenObservable)
    }

    override func showableComponent() -> Observable<OWShowable> {
        let commentThreadViewVM: OWCommentThreadViewViewModeling = OWCommentThreadViewViewModel()
        let commentThreadView = OWCommentThreadView(viewModel: commentThreadViewVM)
        return .just(commentThreadView)
    }
}

fileprivate extension OWCommentThreadCoordinator {
    func setupObservers(forViewModel viewModel: OWCommentThreadViewModeling) {
        // Setting up general observers which affect app flow however not entirely inside the SDK
    }

    func setupViewActionsCallbacks(forViewModel viewModel: OWCommentThreadViewModeling) {
        // TODO: complete binding VM to actions callbacks
    }
}
