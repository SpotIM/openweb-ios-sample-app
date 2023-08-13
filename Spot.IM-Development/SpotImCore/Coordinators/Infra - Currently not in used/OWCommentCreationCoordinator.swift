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
    case commentCreated(comment: OWComment)
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
    fileprivate lazy var viewActionsService: OWViewActionsServicing = {
        return OWViewActionsService(viewActionsCallbacks: actionsCallbacks, viewSourceType: .commentCreation)
    }()
    fileprivate lazy var customizationsService: OWCustomizationsServicing = {
        return OWCustomizationsService(viewSourceType: .commentCreation)
    }()

    init(router: OWRoutering! = nil, commentCreationData: OWCommentCreationRequiredData, actionsCallbacks: OWViewActionsCallbacks?) {
        self.router = router
        self.commentCreationData = commentCreationData
        self.actionsCallbacks = actionsCallbacks
    }

    override func start(deepLinkOptions: OWDeepLinkOptions? = nil) -> Observable<OWCommentCreationCoordinatorResult> {
        let commentCreationVM: OWCommentCreationViewModeling = OWCommentCreationViewModel(commentCreationData: commentCreationData, viewableMode: .partOfFlow)
        let commentCreationVC = OWCommentCreationVC(viewModel: commentCreationVM)

        let commentCreationPopped = PublishSubject<Void>()

        let pushStyle: OWScreenPushStyle = {
            switch commentCreationVM.outputs.commentCreationViewVM.outputs.commentCreationStyle {
            case .regular, .light:
                return .present
            case .floatingKeyboard:
                return .presentOverFullScreen
            }
        }()

        router.push(commentCreationVC,
                    pushStyle: pushStyle,
                    animated: true,
                    popCompletion: commentCreationPopped)

        setupObservers(forViewModel: commentCreationVM)
        setupViewActionsCallbacks(forViewModel: commentCreationVM)

        let commentCreatedObservable = commentCreationVM.outputs.commentCreationViewVM.outputs.commentCreationSubmitted
            .filter { _ in
                if case .floatingKeyboard = commentCreationVM.outputs.commentCreationViewVM.outputs.commentCreationStyle {
                    return false
                }
                return true
            }
            .map { OWCommentCreationCoordinatorResult.commentCreated(comment: $0) }
            .asObservable()

        let commentCreatedByFloatingKeyboardStyleObservable = commentCreationVM.outputs.commentCreationViewVM.outputs.commentCreationSubmitted
            .filter { _ in
                if case .floatingKeyboard = commentCreationVM.outputs.commentCreationViewVM.outputs.commentCreationStyle {
                    return true
                }
                return false
            }
            .map { OWCommentCreationCoordinatorResult.commentCreated(comment: $0) }
            .asObservable()

        let poppedFromBackButtonObservable = commentCreationPopped
            .map { OWCommentCreationCoordinatorResult.popped }
            .asObservable()

        let commentCreationViewVM = commentCreationVM.outputs.commentCreationViewVM
        let closeButtonPopped = commentCreationViewVM.outputs.closeButtonTapped

        let poppedFromCloseButtonObservable = closeButtonPopped
            .map { OWCommentCreationCoordinatorResult.popped }
            .asObservable()

        let commentCreationLoadedToScreenObservable = commentCreationVM.outputs.loadedToScreen
            .map { OWCommentCreationCoordinatorResult.loadedToScreen }
            .asObservable()

        let resultsWithPopAnimation = Observable.merge(poppedFromCloseButtonObservable, commentCreatedObservable)
            .observe(on: MainScheduler.instance)
            .do(onNext: { [weak self] _ in
                self?.router.pop(popStyle: .dismiss, animated: false)
            })

                return Observable.merge(resultsWithPopAnimation.take(1),
                                        commentCreationLoadedToScreenObservable.take(1),
                                        poppedFromBackButtonObservable.take(1),
                                        commentCreatedByFloatingKeyboardStyleObservable.take(1))
    }

    override func showableComponent() -> Observable<OWShowable> {
        // TODO: Complete when we would like to support comment creation as a view
        let commentCreationViewVM: OWCommentCreationViewViewModeling = OWCommentCreationViewViewModel(commentCreationData: commentCreationData,
                                                                                                viewableMode: .independent)
        let commentCreationView = OWCommentCreationView(viewModel: commentCreationViewVM)
        setupObservers(forViewModel: commentCreationViewVM)
        setupViewActionsCallbacks(forViewModel: commentCreationViewVM)
        return .just(commentCreationView)
    }
}

fileprivate extension OWCommentCreationCoordinator {
    func setupObservers(forViewModel viewModel: OWCommentCreationViewModeling) {
        viewModel.outputs.commentCreationViewVM.outputs.closeButtonTapped
            .subscribe { [weak self] _ in
                guard let self = self else { return }
                let popStyle: OWScreenPopStyle = {
                    switch viewModel.outputs.commentCreationViewVM.outputs.commentCreationStyle {
                    case .regular, .light:
                        return .dismiss
                    case .floatingKeyboard:
                        return .dismissOverFullScreen
                    }
                }()
                self.router.pop(popStyle: popStyle, animated: true)
            }
            .disposed(by: disposeBag)
    }

    func setupViewActionsCallbacks(forViewModel viewModel: OWCommentCreationViewModeling) {
        guard actionsCallbacks != nil else { return } // Make sure actions callbacks are available/provided
    }

    func setupObservers(forViewModel viewModel: OWCommentCreationViewViewModeling) {
        // TODO: Setting up general observers which affect app flow however not entirely inside the SDK
    }

    func setupViewActionsCallbacks(forViewModel viewModel: OWCommentCreationViewViewModeling) {
        guard actionsCallbacks != nil else { return } // Make sure actions callbacks are available/provided
    }
}
