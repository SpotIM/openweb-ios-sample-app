//
//  OWCommentCreationContentViewModel.swift
//  SpotImCore
//
//  Created by Alon Shprung on 03/07/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWCommentCreationContentViewModelingInputs {
    var commentText: BehaviorSubject<String> { get }
}

protocol OWCommentCreationContentViewModelingOutputs {
    var commentTextOutput: Observable<String> { get }
    var showPlaceholder: Observable<Bool> { get }
    var avatarViewVM: OWAvatarViewModeling { get }
    var placeholderText: Observable<String> { get }
}

protocol OWCommentCreationContentViewModeling {
    var inputs: OWCommentCreationContentViewModelingInputs { get }
    var outputs: OWCommentCreationContentViewModelingOutputs { get }
}

class OWCommentCreationContentViewModel: OWCommentCreationContentViewModeling,
                                         OWCommentCreationContentViewModelingInputs,
                                         OWCommentCreationContentViewModelingOutputs {

    var inputs: OWCommentCreationContentViewModelingInputs { return self }
    var outputs: OWCommentCreationContentViewModelingOutputs { return self }

    fileprivate let disposeBag = DisposeBag()
    fileprivate let imageURLProvider: OWImageProviding
    fileprivate let servicesProvider: OWSharedServicesProviding
    fileprivate let commentCreationType: OWCommentCreationTypeInternal

    fileprivate lazy var postId = OWManager.manager.postId

    var commentText = BehaviorSubject<String>(value: "")

    lazy var avatarViewVM: OWAvatarViewModeling = {
        OWAvatarViewModel(imageURLProvider: imageURLProvider)
    }()

    fileprivate lazy var _commentTextCharactersLimit: Observable<Int?> = {
        return servicesProvider.spotConfigurationService().config(spotId: OWManager.manager.spotId)
            .map { config -> Int? in
                guard config.mobileSdk.shouldShowCommentCounter else { return nil }
                return config.mobileSdk.commentCounterCharactersLimit
            }
    }()

    var commentTextOutput: Observable<String> {
        commentText
            .asObservable()
            .withLatestFrom(_commentTextCharactersLimit) { ($0, $1) }
            .scan(("", nil)) { previous, newTuple -> (String, Int?) in
                // Handle characters limit for comment text
                guard let limiter = newTuple.1 else { return newTuple }
                let previousText = previous.0
                let newText = newTuple.0

                return newText.count <= limiter ? (newText, limiter) : (previousText, limiter)
            }
            .map { $0.0 }
    }

    var showPlaceholder: Observable<Bool> {
        commentTextOutput
            .map { $0.count == 0 }
    }

    var placeholderText: Observable<String> {
        switch commentCreationType {
        case .replyToComment:
            return Observable.just(OWLocalizationManager.shared.localizedString(key: "Type your reply…"))
        default:
            return Observable.just(OWLocalizationManager.shared.localizedString(key: "What do you think?"))
        }
    }

    init(commentCreationType: OWCommentCreationTypeInternal,
         servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared,
         imageURLProvider: OWImageProviding = OWCloudinaryImageProvider()) {
        self.servicesProvider = servicesProvider
        self.imageURLProvider = imageURLProvider
        self.commentCreationType = commentCreationType

        self.setupInitialTextIfNeeded()

        setupObservers()
    }
}

fileprivate extension OWCommentCreationContentViewModel {
    func setupInitialTextIfNeeded() {
        let commentsCacheService = self.servicesProvider.commentsInMemoryCacheService()
        var initialText: String? = nil
        switch commentCreationType {
        case .comment:
            guard let postId = self.postId else { return }
            initialText = commentsCacheService[.comment(postId: postId)]
        case .replyToComment(originComment: let originComment):
            guard let postId = self.postId,
                  let originCommentId = originComment.id
            else { return }
            initialText = commentsCacheService[.reply(postId: postId, commentId: originCommentId)]
        case .edit(comment: let comment):
            if let commentText = comment.text?.text {
                initialText = commentText
            }
        }

        if let initialText = initialText {
            self.inputs.commentText.onNext(initialText)
        }
    }

    func setupObservers() {
        servicesProvider.authenticationManager()
            .activeUserAvailability
            .subscribe(onNext: { [weak self] availability in
                guard let self = self else { return }
                switch (availability) {
                case .notAvailable:
                    self.avatarViewVM.inputs.userInput.onNext(nil)
                case .user(let user):
                    self.avatarViewVM.inputs.userInput.onNext(user)
                }
            })
            .disposed(by: disposeBag)

    }
}

