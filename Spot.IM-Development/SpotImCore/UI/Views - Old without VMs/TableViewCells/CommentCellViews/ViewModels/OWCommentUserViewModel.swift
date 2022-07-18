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
    
    fileprivate let _conversationModel = BehaviorSubject<SPMainConversationModel?>(value: nil)
    
    init(user: SPUser?, imageProvider: SPImageProvider? = nil) {
        avatarVM = OWAvatarViewModel(user: user, imageURLProvider: imageProvider)
        userNameVM = OWUserNameViewModel(user: user)
        
        self.setupObservers()
    }
    
    let subscriberBadgeVM: OWUserSubscriberBadgeViewModeling = OWUserSubscriberBadgeViewModel()
    
    func configure(with model: CommentViewModel) {
        _conversationModel.onNext(model.conversationModel)
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
        userNameVM.outputs.moreTapped.subscribe(onNext: { [weak self] sender in
            guard let self = self else { return }
            self.delegate?.moreTapped(for: self.commentId, replyingToID: self.replyToCommentId, sender: sender)
        }).disposed(by: disposeBag)
        
        userNameVM.outputs.userNameTapped.withLatestFrom(_conversationModel.unwrap())
            .subscribe(onNext: { [weak self] conversationModel in
                guard let self = self, let commentId = self.commentId else { return }
                conversationModel.authorTapped.onNext((
                    userId: commentId,
                    isTappedOnAvatar: false
                ))
            }).disposed(by: disposeBag)
        
        avatarVM.outputs.avatarTapped
            .withLatestFrom(_conversationModel.unwrap())
            .subscribe(onNext: { [weak self] conversationModel in
                guard let self = self, let commentId = self.commentId else { return }
                conversationModel.authorTapped.onNext((
                    userId: commentId,
                    isTappedOnAvatar: true
                ))
            }).disposed(by: disposeBag)
    }
}
