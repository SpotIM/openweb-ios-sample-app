//
//  OWCommentCreationCoordinator.swift
//  OpenWebSDK
//
//  Created by Alon Shprung on 17/08/2022.
//  Copyright © 2022 OpenWeb. All rights reserved.
//

import Foundation
import RxSwift

enum OWCommentCreationCoordinatorResult: OWCoordinatorResultProtocol {
    case popped
    case commentCreated(comment: OWComment)
    case userLoggedInWhileWritingReplyToComment(id: OWCommentId)
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
    private let router: OWRoutering!
    private let commentCreationData: OWCommentCreationRequiredData
    private let viewActionsCallbacks: OWViewActionsCallbacks?
    private lazy var viewActionsService: OWViewActionsServicing = {
        return OWViewActionsService(viewActionsCallbacks: viewActionsCallbacks, viewSourceType: .commentCreation)
    }()
    private lazy var customizationsService: OWCustomizationsServicing = {
        return OWCustomizationsService(viewSourceType: .commentCreation)
    }()

    init(router: OWRoutering! = nil, commentCreationData: OWCommentCreationRequiredData, viewActionsCallbacks: OWViewActionsCallbacks?) {
        self.router = router
        self.commentCreationData = commentCreationData
        self.viewActionsCallbacks = viewActionsCallbacks
    }

    override func start(coordinatorData: OWCoordinatorData? = nil) -> Observable<OWCommentCreationCoordinatorResult> {
        let commentCreationVM: OWCommentCreationViewModeling = OWCommentCreationViewModel(commentCreationData: commentCreationData, viewableMode: .partOfFlow)
        let commentCreationVC = OWCommentCreationVC(viewModel: commentCreationVM)

        let pushStyle: OWScreenPushStyle = {
            switch commentCreationVM.outputs.commentCreationViewVM.outputs.commentCreationStyle {
            case .regular, .light:
                return .present
            case .floatingKeyboard:
                return .addAsChild
            }
        }()

        let animated = {
            guard let coordinatorData else { return true }
            switch coordinatorData.deepLink {
            case .commentCreation(let commentCreationData):
                guard coordinatorData.source == .preConversation,
                      case .present = commentCreationData.presentationalStyle else { return true }
                // If comment creation was called from PreConversation
                // And the presentation style is present, then we do not
                // animate the comment creation since the animation of present
                // is done by the conversation presenting under it
                // this fixes a UI bug that in some cases looked like a
                // double present.
                return false
            default:
                break
            }
            return true
        }()

        router.push(commentCreationVC,
                    pushStyle: pushStyle,
                    animated: animated,
                    popCompletion: nil) // We do not send a back button pop completion here since comment creation is never pushed with a back button

        setupObservers(forViewModel: commentCreationVM)
        setupViewActionsCallbacks(forViewModel: commentCreationVM.outputs.commentCreationViewVM)

        let commentCreatedObservable = commentCreationVM.outputs.commentCreationViewVM.outputs.commentCreationSubmitted
            .map { OWCommentCreationCoordinatorResult.commentCreated(comment: $0) }
            .asObservable()

        let userLoggedInObservable = commentCreationVM.outputs.commentCreationViewVM.outputs.userJustLoggedIn
            .map { [weak self] _ -> OWCommentCreationRequiredData? in
                guard let self else { return nil }
                return self.commentCreationData
            }
            .unwrap()
            .map { commentCreationData -> OWCommentId? in
                if case .replyToComment(let comment) = commentCreationData.commentCreationType {
                    return comment.id
                } else {
                    return nil
                }
            }
            .unwrap()
            .map { OWCommentCreationCoordinatorResult.userLoggedInWhileWritingReplyToComment(id: $0) }
            .asObservable()

        let commentCreationViewVM = commentCreationVM.outputs.commentCreationViewVM
        let closeButtonPopped = commentCreationViewVM.outputs.closeButtonTapped

        let poppedFromCloseButtonObservable = closeButtonPopped
            .map { OWCommentCreationCoordinatorResult.popped }
            .asObservable()

        let commentCreationLoadedToScreenObservable = commentCreationVM.outputs.loadedToScreen
            .map { OWCommentCreationCoordinatorResult.loadedToScreen }
            .asObservable()

        let resultsWithPopAnimation = Observable.merge(poppedFromCloseButtonObservable, commentCreatedObservable, userLoggedInObservable)
            .observe(on: MainScheduler.instance)
            .do(onNext: { [weak self] _ in
                guard let self else { return }
                let popStyle: OWScreenPopStyle = {
                    switch commentCreationViewVM.outputs.commentCreationStyle {
                    case .regular, .light:
                        return .dismiss
                    case .floatingKeyboard:
                        return .removeChild
                    }
                }()
                self.router.pop(popStyle: popStyle, animated: true)
            })

        return Observable.merge(resultsWithPopAnimation.take(1),
                                commentCreationLoadedToScreenObservable.take(1))

    }

    override func showableComponent() -> Observable<OWShowable> {
        let commentCreationViewVM: OWCommentCreationViewViewModeling = OWCommentCreationViewViewModel(commentCreationData: commentCreationData,
                                                                                                viewableMode: .independent)
        let commentCreationView = OWCommentCreationView(viewModel: commentCreationViewVM)
        setupObservers(forViewModel: commentCreationViewVM)
        setupViewActionsCallbacks(forViewModel: commentCreationViewVM)
        return .just(commentCreationView)
    }
}

private extension OWCommentCreationCoordinator {
    func setupObservers(forViewModel viewModel: OWCommentCreationViewModeling) {
        setupObservers(forViewModel: viewModel.outputs.commentCreationViewVM)
    }

    func setupObservers(forViewModel viewModel: OWCommentCreationViewViewModeling) {
        // TODO: Setting up general observers which affect app flow however not entirely inside the SDK
        setupCustomizationElements(forViewModel: viewModel)
    }

    func setupViewActionsCallbacks(forViewModel viewModel: OWCommentCreationViewViewModeling) {
        guard viewActionsCallbacks != nil else { return } // Make sure actions callbacks are available/provided

        let userLoggedInWhileReplyingToComment = viewModel.outputs.userJustLoggedIn
            .map { [weak self] in
                self?.commentCreationData
            }
            .unwrap()
            .map { commentCreationData -> OWCommentId? in
                if case .replyToComment(let comment) = commentCreationData.commentCreationType {
                    return comment.id
                } else {
                    return nil
                }
            }
            .unwrap()
            .voidify()

        let closeCommentCreationObservable = Observable.merge(viewModel.outputs.closeButtonTapped, userLoggedInWhileReplyingToComment)
            .voidify()
            .map { [weak self] in
                self?.commentCreationData.settings.commentCreationSettings.style
            }
            .unwrap()
            .map { style in
                switch style {
                case .floatingKeyboard:
                    return OWViewActionCallbackType.floatingCommentCreationDismissed
                default:
                    return OWViewActionCallbackType.closeCommentCreation
                }
            }

        let commentCreatedObservable = viewModel.outputs.commentCreationSubmitted
            .voidify()
            .map { OWViewActionCallbackType.commentSubmitted }

        Observable.merge(closeCommentCreationObservable, commentCreatedObservable)
            .filter { _ in
                viewModel.outputs.viewableMode == .independent
            }
            .subscribe(onNext: { [weak self] viewAction in
                guard let self else { return }
                self.viewActionsService.append(viewAction: viewAction)
            })
            .disposed(by: disposeBag)
    }

    func setupCustomizationElements(forViewModel viewModel: OWCommentCreationViewViewModeling) {
        // Set customized pre conversation summary header
        let submitCustomizeButton = viewModel.outputs.customizeSubmitButtonUI
            .map { OWCustomizableElement.commentCreationSubmit(element: .button(button: $0)) }

        let customizationElementsObservables = Observable.merge(submitCustomizeButton)

        customizationElementsObservables
            .subscribe { [weak self] element in
                self?.customizationsService.trigger(customizableElement: element)
            }
            .disposed(by: disposeBag)

    }
}
