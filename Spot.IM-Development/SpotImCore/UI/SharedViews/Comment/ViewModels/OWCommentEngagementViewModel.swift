//
//  OWCommentEngagementViewModel.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 27/12/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

protocol OWCommentEngagementViewModelingInputs {
    var replyClicked: PublishSubject<Void> { get }
    var shareClicked: PublishSubject<Void> { get }
    var isReadOnly: BehaviorSubject<Bool> { get }
}

protocol OWCommentEngagementViewModelingOutputs {
    var votingVM: OWCommentRatingViewModeling { get }
    var replyClickedOutput: Observable<Void> { get }
    var shareCommentUrl: Observable<URL> { get }
    var showReplyButton: Observable<Bool> { get }
}

protocol OWCommentEngagementViewModeling {
    var inputs: OWCommentEngagementViewModelingInputs { get }
    var outputs: OWCommentEngagementViewModelingOutputs { get }
}

class OWCommentEngagementViewModel: OWCommentEngagementViewModeling,
                                    OWCommentEngagementViewModelingInputs,
                                    OWCommentEngagementViewModelingOutputs {

    var inputs: OWCommentEngagementViewModelingInputs { return self }
    var outputs: OWCommentEngagementViewModelingOutputs { return self }

    let votingVM: OWCommentRatingViewModeling
    fileprivate let sharedServiceProvider: OWSharedServicesProviding

    fileprivate let commentId: String
    fileprivate let parentCommentId: String?

    var replyClicked = PublishSubject<Void>()
    var replyClickedOutput: Observable<Void> {
        replyClicked
            .asObservable()
    }

    var shareClicked = PublishSubject<Void>()
    var shareCommentUrl: Observable<URL> {
        shareClicked
            .flatMap({ [weak self] _ -> Observable<Event<OWShareLink>> in
                guard let self = self else { return .empty() }
                return self.sharedServiceProvider.netwokAPI()
                    .conversation
                    .commentShare(id: self.commentId, parentId: self.parentCommentId)
                    .response
                    .materialize() // Required to keep the final subscriber even if errors arrived from the network
            })
            .map { event -> URL? in
                switch event {
                case .next(let shareLink):
                    return shareLink.reference
                case .error(_):
                    return nil
                default:
                    return nil
                }
            }
            .unwrap()
            .asObservable()
    }

    var isReadOnly = BehaviorSubject(value: true)
    var showReplyButton: Observable<Bool> {
        isReadOnly
            .map { !$0 }
            .asObservable()
    }

    fileprivate var _repliesCount = BehaviorSubject<Int>(value: 0)

    init(comment: OWComment, sharedServiceProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.sharedServiceProvider = sharedServiceProvider
        _repliesCount.onNext(comment.repliesCount ?? 0)
        let rank = comment.rank ?? OWComment.Rank()
        self.commentId = comment.id ?? ""
        self.parentCommentId = comment.parentId
        votingVM = OWCommentRatingViewModel(model: OWCommentVotingModel(
            rankUpCount: rank.ranksUp ?? 0,
            rankDownCount: rank.ranksDown ?? 0,
            rankedByUserValue: rank.rankedByCurrentUser ?? 0
        ), commentId: commentId)
    }

    init(sharedServiceProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.sharedServiceProvider = sharedServiceProvider
        self.votingVM = OWCommentRatingViewModel()
        self.commentId = ""
        self.parentCommentId = nil
    }
}
