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
