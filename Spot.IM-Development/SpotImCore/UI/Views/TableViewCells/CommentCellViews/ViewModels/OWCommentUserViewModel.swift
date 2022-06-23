//
//  OWCommentUserViewModel.swift
//  SpotImCore
//
//  Created by Alon Shprung on 20/06/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import RxSwift
import RxCocoa
import UIKit

protocol OWCommentUserViewModelingInputs {
    func configure(with model: CommentViewModel)
}

protocol OWCommentUserViewModelingOutputs {
    var subscriberBadgeVM: OWUserSubscriberBadgeViewModeling { get }
    var avatarVM: OWAvatarViewModeling { get }
}

protocol OWCommentUserViewModeling {
    var inputs: OWCommentUserViewModelingInputs { get }
    var outputs: OWCommentUserViewModelingOutputs { get }
}

class OWCommentUserViewModel: OWCommentUserViewModeling,
                              OWCommentUserViewModelingInputs,
                              OWCommentUserViewModelingOutputs {

    var inputs: OWCommentUserViewModelingInputs { return self }
    var outputs: OWCommentUserViewModelingOutputs { return self }
    
    let avatarVM: OWAvatarViewModeling
    
    init(user: SPUser?, imageProvider: SPImageProvider? = nil) {
        avatarVM = OWAvatarViewModel(user: user, imageURLProvider: imageProvider)
        if let user = user {
            subscriberBadgeVM.inputs.configureUser(user: user)
        }
    }
    
    let subscriberBadgeVM: OWUserSubscriberBadgeViewModeling = OWUserSubscriberBadgeViewModel()
    
    func configure(with model: CommentViewModel) {
        
    }
}
