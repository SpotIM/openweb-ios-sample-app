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
    var isReadOnly: BehaviorSubject<Bool> { get }
}

protocol OWCommentEngagementViewModelingOutputs {
    var votingVM: OWCommentRatingViewModeling { get }
    var replyClickedOutput: Observable<Void> { get }
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

    var isReadOnly = BehaviorSubject(value: true)
//    var _showReplyButton = BehaviorSubject(value: true)
    var showReplyButton: Observable<Bool> {
        isReadOnly
            .map { !$0 }
            .asObservable()
    }

    fileprivate var _replies = BehaviorSubject<Int>(value: 0)

    init(replies: Int, rank: SPComment.Rank) {
        _replies.onNext(replies)
        votingVM = OWCommentRatingViewModel(model: OWCommentVotingModel(rankUpCount: rank.ranksUp ?? 0,
                                                                        rankDownCount: rank.ranksDown ?? 0,
                                                                        rankedByUserValue: rank.rankedByCurrentUser ?? 0))

        setupObservers()
    }

    init() {
        self.votingVM = OWCommentRatingViewModel()
    }

}

fileprivate extension OWCommentEngagementViewModel {
    func setupObservers() {
//        isReadOnly
//            .subscribe(onNext: {
//                _showReplyButton.onNext(<#T##element: Bool##Bool#>)
//            })
    }
}
