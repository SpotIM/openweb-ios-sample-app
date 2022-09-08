//
//  OWConversationCoordinator.swift
//  SpotImCore
//
//  Created by Alon Haiut on 05/07/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

enum OWConversationCoordinatorResult {
    case popped
}

class OWConversationCoordinator: OWBaseCoordinator<OWConversationCoordinatorResult> {
    
    fileprivate let router: OWRoutering
    fileprivate let conversationData: OWConversationRequiredData
    fileprivate let actionsCallbacks: OWViewActionsCallbacks?

    init(router: OWRoutering, conversationData: OWConversationRequiredData, actionsCallbacks: OWViewActionsCallbacks?) {
        self.router = router
        self.conversationData = conversationData
        self.actionsCallbacks = actionsCallbacks
    }
    
    override func start(deepLinkOptions: OWDeepLinkOptions? = nil) -> Observable<OWConversationCoordinatorResult> {
        
        let conversationVM: OWConversationViewModeling = OWConversationViewModel(conversationData: conversationData)
        let conversationVC = OWConversationVC(viewModel: conversationVM)
        let conversationPopped = PublishSubject<Void>()
        
        setupObservers(forViewModel: conversationVM)
        setupViewActionsCallbacks(forViewModel: conversationVM)
        
        let deepLinkToCommentCreation = BehaviorSubject<OWCommentCreationRequiredData?>(value: nil)
        
        var animated = true
        
        // Support deep links which related to conversation
        if let deepLink = deepLinkOptions {
            switch deepLink {
            case .commentCreation(let commentCreationData):
                animated = false
                deepLinkToCommentCreation.onNext(commentCreationData)
            case .highlightComment(let commentId):
                conversationVM.inputs.highlightComment.onNext(commentId)
            default:
                break
            }
        }
        
        if router.isEmpty() {
            router.setRoot(conversationVC, animated: false)
        } else {
            router.push(conversationVC,
                        animated: animated,
                        popCompletion: conversationPopped)
        }
        
        // CTA tapped from conversation screen
        let ctaCommentCreationTapped = conversationVM.outputs.ctaCommentCreationTapped
            .map { [weak self] _ -> OWCommentCreationRequiredData? in
                // Here we are generating `OWCommentCreationRequiredData` and new fields in this struct will have default values
                guard let self = self else { return nil }
                return OWCommentCreationRequiredData(article: self.conversationData.article)
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
                case .popped:
                    break
                }
            })
            .flatMap { _ -> Observable<OWConversationCoordinatorResult> in
                return Observable.never()
            }
        
        let conversationPoppedObservable = conversationPopped
            .map { OWConversationCoordinatorResult.popped }
            .asObservable()
        
        return Observable.merge(conversationPoppedObservable, coordinateCommentCreationObservable)
    }
    
    override func showableComponent() -> Observable<OWShowable> {
        // TODO: Complete when we would like to support the conversation as a view
        let conversationViewVM: OWConversationViewViewModeling = OWConversationViewViewModel(conversationData: conversationData)
        let conversationView = OWConversationView(viewModel: conversationViewVM)
        return .just(conversationView)
    }
}

fileprivate extension OWConversationCoordinator {
    func setupObservers(forViewModel viewModel: OWConversationViewModeling) {
        // Setting up general observers which affect app flow however not entirely inside the SDK
        
        viewModel.outputs.userInitiatedAuthenticationFlow
            .subscribe(onNext: { _ in
                // TODO: Complete a callback to trigger auth flow at publisher side
                // Complete by implementing OWUIAuthentication layer
                // `let authenticationUI: OWUIAuthentication = manager.ui.authentication` according to the new API
            })
            .disposed(by: disposeBag)
    }
    
    func setupViewActionsCallbacks(forViewModel viewModel: OWConversationViewModeling) {
        // TODO: complete binding VM to actions callbacks
    }
}
