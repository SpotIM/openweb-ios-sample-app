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
    case openCommentCreation(postId: OWPostId)
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
        
        // TODO: decide later on whether 'present' mode will be a custom animation in the NavigationController.
        // We might override some stuff there
        // Present mode will currently crash, this infra is only for push
        router.push(conversationVC,
                    animated: true,
                    popCompletion: conversationPopped)
        
        // Connect actionsCallbacks
        // TODO: Complete
        
        // TODO: coordinate to comment creation coordinator and authentication screen when needed
        
        return conversationPopped
            .map { OWConversationCoordinatorResult.popped }
            .asObservable()
    }
    
    override func showableComponent() -> Observable<OWShowable> {
        // TODO: Complete when we would like to support the conversation as a view
        let conversationViewVM: OWConversationViewViewModeling = OWConversationViewViewModel(conversationData: conversationData)
        let conversationView = OWConversationView(viewModel: conversationViewVM)
        return .just(conversationView)
    }
}
