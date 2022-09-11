//
//  OWPreConversationCoordinator.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 07/09/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

enum OWPreConversationCoordinatorResult {
    case openCommentCreation(postId: OWPostId)
    case openFullConversation(postId: OWPostId)
}

class OWPreConversationCoordinator: OWBaseCoordinator<OWPreConversationCoordinatorResult> {
    
    fileprivate let router: OWRoutering
    fileprivate let preConversationData: OWPreConversationRequiredData
    fileprivate let actionsCallbacks: OWViewActionsCallbacks?

    init(router: OWRoutering, preConversationData: OWPreConversationRequiredData, actionsCallbacks: OWViewActionsCallbacks?) {
        self.router = router
        self.preConversationData = preConversationData
        self.actionsCallbacks = actionsCallbacks
    }
    
    override func start(deepLinkOptions: OWDeepLinkOptions? = nil) -> Observable<OWPreConversationCoordinatorResult> {
        // TODO: complete the flow
//        let conversationVM: OWConversationViewModeling = OWConversationViewModel()
//        let conversationVC = OWConversationVC(viewModel: conversationVM)
        return .empty()
    }
    
    override func showableComponent() -> Observable<OWShowable> {
//        let preConversationViewVM: OWPreConversationViewViewModeling = OWPreConversationViewViewModel(imageProvider: <#SPImageProvider#>, settings: <#OWPreConversationSettings#>)
//        let preConversationView = OWPreConversationView(viewModel: preConversationViewVM, adsProvider: )
//        return .just(preConversationView)
        return .empty()
    }
}
