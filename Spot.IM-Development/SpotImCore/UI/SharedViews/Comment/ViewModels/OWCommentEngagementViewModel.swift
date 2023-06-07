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
    var shareClickedOutput: Observable<Void> { get }
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
    fileprivate let disposeBag = DisposeBag()

    var replyClicked = PublishSubject<Void>()
    var replyClickedOutput: Observable<Void> {
        replyClicked
            .asObservable()
    }

    var shareClicked = PublishSubject<Void>()
    var shareClickedOutput: Observable<Void> {
        shareClicked
            .asObservable()
    }

    var isReadOnly = BehaviorSubject(value: true)
    var showReplyButton: Observable<Bool> {
        isReadOnly
            .map { !$0 }
            .asObservable()
    }

    fileprivate var _repliesCount = BehaviorSubject<Int>(value: 0)

    init(comment: OWComment) {
        _repliesCount.onNext(comment.repliesCount ?? 0)
        let rank = comment.rank ?? OWComment.Rank()
        let commentId = comment.id ?? ""
        votingVM = OWCommentRatingViewModel(model: OWCommentVotingModel(
            rankUpCount: rank.ranksUp ?? 0,
            rankDownCount: rank.ranksDown ?? 0,
            rankedByUserValue: rank.rankedByCurrentUser ?? 0
        ), commentId: commentId)
    }

    init() {
        self.votingVM = OWCommentRatingViewModel()
    }

}
