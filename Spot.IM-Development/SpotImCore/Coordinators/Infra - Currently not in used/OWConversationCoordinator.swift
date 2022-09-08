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
        // TODO: complete the flow
//        let conversationVM: OWConversationViewModeling = OWConversationViewModel()
//        let conversationVC = OWConversationVC(viewModel: conversationVM)
        return .empty()
    }
    
    override func showableComponent() -> Observable<OWShowable> {
        let conversationViewVM: OWConversationViewViewModeling = OWConversationViewViewModel()
        let conversationView = OWConversationView(viewModel: conversationViewVM)
        return .just(conversationView)
    }
}
