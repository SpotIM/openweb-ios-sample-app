//
//  OWConversationCoordinator.swift
//  SpotImCore
//
//  Created by Alon Haiut on 05/07/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

enum OWConversationCoordinatorResult: OWCoordinatorResultProtocol {
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

class OWConversationCoordinator: OWBaseCoordinator<OWConversationCoordinatorResult> {

    // Router is being used only for `Flows` mode. Intentionally defined as force unwrap for easy access.
    // Trying to use that in `Standalone Views` mode will cause a crash immediately.
    fileprivate let router: OWRoutering!
    fileprivate let conversationData: OWConversationRequiredData
    fileprivate let actionsCallbacks: OWViewActionsCallbacks?
    fileprivate lazy var viewActionsService: OWViewActionsServicing = {
        return OWViewActionsService(viewActionsCallbacks: actionsCallbacks, viewSourceType: .conversation)
    }()

    init(router: OWRoutering! = nil, conversationData: OWConversationRequiredData, actionsCallbacks: OWViewActionsCallbacks?) {
        self.router = router
        self.conversationData = conversationData
        self.actionsCallbacks = actionsCallbacks
    }

    override func start(deepLinkOptions: OWDeepLinkOptions? = nil) -> Observable<OWConversationCoordinatorResult> {

        let conversationVM: OWConversationViewModeling = OWConversationViewModel(conversationData: conversationData,
                                                                                 viewableMode: .partOfFlow)
        let conversationVC = OWConversationVC(viewModel: conversationVM)
        let conversationPopped = PublishSubject<Void>()

        setupObservers(forViewModel: conversationVM)
        setupViewActionsCallbacks(forViewModel: conversationVM)

        let deepLinkToCommentCreation = BehaviorSubject<OWCommentCreationRequiredData?>(value: nil)
        let deepLinkToCommentThread = BehaviorSubject<OWCommentThreadRequiredData?>(value: nil)

        var animated = true

        // Support deep links which related to conversation
        if let deepLink = deepLinkOptions {
            switch deepLink {
            case .commentCreation(let commentCreationData):
                animated = false
                deepLinkToCommentCreation.onNext(commentCreationData)
            case .commentThread(let commentThreadData):
                animated = false
                deepLinkToCommentThread.onNext(commentThreadData)
            case .highlightComment(let commentId):
                conversationVM.inputs.highlightComment.onNext(commentId)
            default:
                break
            }
        }

        // Conversation is the initial view in the router so here we start the router
        router.start()

        if router.isEmpty() {
            router.setRoot(conversationVC, animated: false, dismissCompletion: conversationPopped)
        } else {
            router.push(conversationVC,
                        pushStyle: .regular,
                        animated: animated,
                        popCompletion: conversationPopped)
        }

        // CTA tapped from conversation screen
        let ctaCommentCreationTapped = conversationVM.outputs.ctaCommentCreationTapped
            .map { [weak self] _ -> OWCommentCreationRequiredData? in
                // Here we are generating `OWCommentCreationRequiredData` and new fields in this struct will have default values
                guard let self = self else { return nil }
                return OWCommentCreationRequiredData(article: self.conversationData.article, commentCreationType: .comment)
            }
            .unwrap()

        // Coordinate to comment creation
        let coordinateCommentCreationObservable = Observable.merge(ctaCommentCreationTapped,
                                                         deepLinkToCommentCreation.unwrap().asObservable())
            .flatMap { [weak self] commentCreationData -> Observable<OWCommentCreationCoordinatorResult> in
                guard let self = self else { return .empty() }
                let commentCreationCoordinator = OWCommentCreationCoordinator(router: self.router,
                                                                              commentCreationData: commentCreationData,
                                                                              actionsCallbacks: self.actionsCallbacks)
                return self.coordinate(to: commentCreationCoordinator)
            }
            .do(onNext: { result in
                switch result {
                case .commentCreated(_):
                    // TODO: We will probably would like to push this comment to the table view with a nice highlight animation
                    break
                case .loadedToScreen:
                    break
                    // Nothing
                case .popped:
                    break
                }
            })
            .flatMap { _ -> Observable<OWConversationCoordinatorResult> in
                return Observable.never()
            }

        // Coordinate to comment thread
        let coordinateCommentThreadObservable = deepLinkToCommentThread.unwrap().asObservable()
            .flatMap { [weak self] commentThreadData -> Observable<OWCommentThreadCoordinatorResult> in
                guard let self = self else { return .empty() }
                let commentThreadCoordinator = OWCommentThreadCoordinator(router: self.router,
                                                                              commentThreadData: commentThreadData,
                                                                              actionsCallbacks: self.actionsCallbacks)
                return self.coordinate(to: commentThreadCoordinator)
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
            .flatMap { _ -> Observable<OWConversationCoordinatorResult> in
                return Observable.never()
            }

        let indipendentConversationClosedObservable = conversationVM
            .outputs.conversationViewVM
            .outputs.conversationTitleHeaderViewModel
            .outputs.closeConversation

        let partOfFlowPresentedConversationClosedObservable = conversationVM.outputs.closeConversation

        let conversationPoppedObservable = Observable.merge(conversationPopped,
                                                            indipendentConversationClosedObservable,
                                                            partOfFlowPresentedConversationClosedObservable)
            .debug("RIVI: conversationPoppedObservable")
            .map { OWConversationCoordinatorResult.popped }
            .asObservable()

        let conversationLoadedObservable = conversationVM.outputs.loadedToScreen
            .map { OWConversationCoordinatorResult.loadedToScreen }
            .asObservable()

        return Observable.merge(
            conversationPoppedObservable,
            coordinateCommentCreationObservable,
            coordinateCommentThreadObservable,
            conversationLoadedObservable
        )
    }

    override func showableComponent() -> Observable<OWShowable> {
        // TODO: Complete when we would like to support the conversation as a view
        let conversationViewVM: OWConversationViewViewModeling = OWConversationViewViewModel(conversationData: conversationData,
                                                                                             viewableMode: .independent)

        let conversationView = OWConversationView(viewModel: conversationViewVM)
        setupObservers(forViewModel: conversationViewVM)
        setupViewActionsCallbacks(forViewModel: conversationViewVM)
        return .just(conversationView)
    }
}

fileprivate extension OWConversationCoordinator {
    func setupObservers(forViewModel viewModel: OWConversationViewModeling) {
        // Coordinate to safari tab
        viewModel
            .outputs.conversationViewVM
            .outputs.communityGuidelinesCellViewModel
            .outputs.communityGuidelinesViewModel
            .outputs.urlClickedOutput
            .flatMap { [weak self] url -> Observable<OWSafariTabCoordinatorResult> in
                guard let self = self else { return .empty() }
                    let safariCoordinator = OWSafariTabCoordinator(router: self.router,
                                                                   url: url,
                                                                   actionsCallbacks: self.actionsCallbacks)
                return self.coordinate(to: safariCoordinator, deepLinkOptions: .none)
            }
            .subscribe()
            .disposed(by: disposeBag)
    }

    func setupViewActionsCallbacks(forViewModel viewModel: OWConversationViewModeling) {
        guard actionsCallbacks != nil else { return } // Make sure actions callbacks are available/provided
    }

    func setupObservers(forViewModel viewModel: OWConversationViewViewModeling) {
        // TODO: Setting up general observers which affect app flow however not entirely inside the SDK
    }

    func setupViewActionsCallbacks(forViewModel viewModel: OWConversationViewViewModeling) {
        guard actionsCallbacks != nil else { return } // Make sure actions callbacks are available/provided

        let contentPressed = viewModel.outputs
            .conversationTitleHeaderViewModel
            .outputs.closeConversation
            .map { OWViewActionCallbackType.contentPressed }

        Observable.merge(contentPressed)
            .subscribe { [weak self] viewActionType in
                self?.viewActionsService.append(viewAction: viewActionType)
            }
            .disposed(by: disposeBag)
    }
}
