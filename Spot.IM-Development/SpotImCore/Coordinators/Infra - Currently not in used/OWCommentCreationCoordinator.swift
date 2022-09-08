//
//  OWCommentCreationCoordinator.swift
//  SpotImCore
//
//  Created by Alon Shprung on 17/08/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

enum OWCommentCreationCoordinatorResult {
    case startLoginFlow
    case commentCreated(comment: SPComment)
}

class OWCommentCreationCoordinator: OWBaseCoordinator<OWCommentCreationCoordinatorResult> {
    
    override func start(deepLinkOptions: OWDeepLinkOptions? = nil) -> Observable<OWCommentCreationCoordinatorResult> {
        // TODO: complete the flow
//        let commentCreationVM: OWCommentCreationViewModeling = OWCommentCreationViewModel()
//        let commentCreationVC = OWCommentCreationVC(viewModel: commentCreationVM)
        return .empty()
    }
    
    override func showableComponent() -> Observable<OWShowable> {
        let commentCreationViewVM: OWCommentCreationViewViewModeling = OWCommentCreationViewViewModel()
        let commentCreationView = OWCommentCreationView(viewModel: commentCreationViewVM)
        return .just(commentCreationView)
    }
}
