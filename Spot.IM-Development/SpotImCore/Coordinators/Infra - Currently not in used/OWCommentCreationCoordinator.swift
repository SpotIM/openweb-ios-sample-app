//
//  OWCommentCreationCoordinator.swift
//  SpotImCore
//
//  Created by Alon Shprung on 17/08/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

enum OWCommentCreationCoordinatorResult: OWCoordinatorResultProtocol {
    case popped
    case commentCreated(comment: SPComment)
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

class OWCommentCreationCoordinator: OWBaseCoordinator<OWCommentCreationCoordinatorResult> {

    // Router is being used only for `Flows` mode. Intentionally defined as force unwrap for easy access.
    // Trying to use that in `Standalone Views` mode will cause a crash immediately.
    fileprivate let router: OWRoutering!
    fileprivate let commentCreationData: OWCommentCreationRequiredData
    fileprivate let actionsCallbacks: OWViewActionsCallbacks?

    init(router: OWRoutering! = nil, commentCreationData: OWCommentCreationRequiredData, actionsCallbacks: OWViewActionsCallbacks?) {
        self.router = router
        self.commentCreationData = commentCreationData
        self.actionsCallbacks = actionsCallbacks
    }

    override func start(deepLinkOptions: OWDeepLinkOptions? = nil) -> Observable<OWCommentCreationCoordinatorResult> {
        // TODO: complete the flow
        let commentCreationVM: OWCommentCreationViewModeling = OWCommentCreationViewModel(commentCreationData: commentCreationData)
        let commentCreationVC = OWCommentCreationVC(viewModel: commentCreationVM)

        let commentCreationPopped = PublishSubject<Void>()

        router.push(commentCreationVC,
                    pushStyle: .presentStyle,
                    animated: true,
                    popCompletion: commentCreationPopped)

        setupObservers(forViewModel: commentCreationVM)
        setupViewActionsCallbacks(forViewModel: commentCreationVM)

        let commentCreatedObservable = commentCreationVM.outputs.commentCreated
            .map { OWCommentCreationCoordinatorResult.commentCreated(comment: $0) }
            .asObservable()

        let commentCreationPoppedObservable = commentCreationPopped
            .map { OWCommentCreationCoordinatorResult.popped }
            .asObservable()

        let commentCreationLoadedToScreenObservable = commentCreationVM.outputs.loadedToScreen
            .map { OWCommentCreationCoordinatorResult.loadedToScreen }
            .asObservable()

        return Observable.merge(commentCreationPoppedObservable, commentCreatedObservable, commentCreationLoadedToScreenObservable)
    }

    override func showableComponent() -> Observable<OWShowable> {
        // TODO: Complete when we would like to support comment creation as a view
        let commentCreationViewVM: OWCommentCreationViewViewModeling = OWCommentCreationViewViewModel(commentCreationData: commentCreationData)
        let commentCreationView = OWCommentCreationView(viewModel: commentCreationViewVM)
        return .just(commentCreationView)
    }
}

fileprivate extension OWCommentCreationCoordinator {
    func setupObservers(forViewModel viewModel: OWCommentCreationViewModeling) {
        // Setting up general observers which affect app flow however not entirely inside the SDK

        viewModel.outputs.userInitiatedAuthenticationFlow
            .subscribe(onNext: { _ in
                // TODO: Complete a callback to trigger auth flow at publisher side
                // Complete by implementing OWUIAuthentication layer
                // `let authenticationUI: OWUIAuthentication = manager.ui.authentication` according to the new API
            })
            .disposed(by: disposeBag)
    }

    func setupViewActionsCallbacks(forViewModel viewModel: OWCommentCreationViewModeling) {
        // TODO: complete binding VM to actions callbacks
    }
}
