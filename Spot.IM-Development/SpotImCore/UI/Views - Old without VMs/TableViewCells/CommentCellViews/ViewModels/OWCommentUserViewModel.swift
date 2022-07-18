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
    func setDelegate(_ delegate: SPCommentCellDelegate)
}

protocol OWCommentUserViewModelingOutputs {
    var userNameVM: OWUserNameViewModeling { get }
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
    
    fileprivate let disposeBag = DisposeBag()
    
    // TODO - use RX
    fileprivate var delegate: SPCommentCellDelegate?
    
    fileprivate var commentId: String?
    fileprivate var replyToCommentId: String?
    
    let avatarVM: OWAvatarViewModeling
    let userNameVM: OWUserNameViewModeling
    
    init(user: SPUser?, imageProvider: SPImageProvider? = nil) {
        avatarVM = OWAvatarViewModel(user: user, imageURLProvider: imageProvider)
        userNameVM = OWUserNameViewModel(user: user)
        
        self.setupObservers()
    }
    
    let subscriberBadgeVM: OWUserSubscriberBadgeViewModeling = OWUserSubscriberBadgeViewModel()
    
    func configure(with model: CommentViewModel) {
        commentId = model.commentId
        replyToCommentId = model.replyingToCommentId
        
        userNameVM.inputs.configure(with: model)
    }
    
    func setDelegate(_ delegate: SPCommentCellDelegate) {
        self.delegate = delegate
    }
}

fileprivate extension OWCommentUserViewModel {
    func setupObservers() {
        userNameVM.outputs.userNameTapped.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            self.delegate?.respondToAuthorTap(for: self.commentId, isAvatarClicked: false)
        }).disposed(by: disposeBag)
        
        userNameVM.outputs.moreTapped.subscribe(onNext: { [weak self] sender in
            guard let self = self else { return }
            self.delegate?.moreTapped(for: self.commentId, replyingToID: self.replyToCommentId, sender: sender)
        }).disposed(by: disposeBag)
        
        avatarVM.outputs.avatarTapped.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            self.delegate?.respondToAuthorTap(for: self.commentId, isAvatarClicked: true)
        }).disposed(by: disposeBag)
    }
}
