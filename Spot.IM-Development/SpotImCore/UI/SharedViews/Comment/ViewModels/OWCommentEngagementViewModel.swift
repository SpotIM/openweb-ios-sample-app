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
}

protocol OWCommentEngagementViewModelingOutputs {
    var votingVM: OWCommentRatingViewModeling { get }
    var replyClickedOutput: Observable<Void> { get }
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

    fileprivate var _replies = BehaviorSubject<Int>(value: 0)

    init(replies: Int, rank: SPComment.Rank) {
        _replies.onNext(replies)
        votingVM = OWCommentRatingViewModel(model: OWCommentVotingModel(rankUpCount: rank.ranksUp ?? 0,
                                                                        rankDownCount: rank.ranksDown ?? 0,
                                                                        rankedByUserValue: rank.rankedByCurrentUser ?? 0))
    }

    init() {
        self.votingVM = OWCommentRatingViewModel()
    }

}
