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
    var repliesText: Observable<String> { get }
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
    
    var votingVM: OWCommentRatingViewModeling = OWCommentRatingViewModel()
    fileprivate let disposeBag = DisposeBag()
    
    // TODO: handle disabled (disable button, change text, disable voting?) - on read only + comment deleted/reported etc
    // TODO: handle when HIDING replies button
    var repliesText: Observable<String> {
        _replies
            .map {
                $0 > 0 ?
                "\(LocalizationManager.localizedString(key: "Reply")) (\($0))" :
                LocalizationManager.localizedString(key: "Reply")
            }
            .asObservable()
    }
    
    var replyClicked = PublishSubject<Void>() // TODO: handle click
    
    fileprivate var _replies = BehaviorSubject<Int>(value: 0)
   
    init(replies: Int, rank: SPComment.Rank?) {
        guard let rank = rank else { return } // TODO: should not be optional
        _replies.onNext(replies)
        votingVM = OWCommentRatingViewModel(model: OWCommentVotingModel(rankUpCount: rank.ranksUp ?? 0, rankDownCount: rank.ranksDown ?? 0, rankedByUserValue: rank.rankedByCurrentUser ?? 0))
    }

    init() {}

}
