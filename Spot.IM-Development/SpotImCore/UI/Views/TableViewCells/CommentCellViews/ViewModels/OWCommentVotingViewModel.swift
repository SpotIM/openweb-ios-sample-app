//
//  OWCommentVotingViewModel.swift
//  SpotImCore
//
//  Created by Alon Shprung on 06/03/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

protocol OWCommentVotingViewModelingInputs {
    func configureRankUp(_ count: Int)
    func configureRankDown(_ count: Int)
    func configureRankedByUser(_ value: Int)
}

protocol OWCommentVotingViewModelingOutputs {
    var rankUpCount: Observable<String> { get }
    var rankDownCount: Observable<String> { get }
    var rankedByUser: Observable<Int> { get }
    var brandColor: Observable<UIColor> { get }
}

protocol OWCommentVotingViewModeling {
    var inputs: OWCommentVotingViewModelingInputs { get }
    var outputs: OWCommentVotingViewModelingOutputs { get }
}

class OWCommentVotingViewModel: OWCommentVotingViewModeling,
                                OWCommentVotingViewModelingInputs,
                                OWCommentVotingViewModelingOutputs {

    var inputs: OWCommentVotingViewModelingInputs { return self }
    var outputs: OWCommentVotingViewModelingOutputs { return self }
    
    fileprivate let _brandColor = BehaviorSubject<UIColor?>(value: nil)
    fileprivate let _rankUp = BehaviorSubject<Int?>(value: nil)
    fileprivate let _rankDown = BehaviorSubject<Int?>(value: nil)
    fileprivate let _rankedByUser = BehaviorSubject<Int?>(value: nil)
    
    init () {
        _brandColor.onNext(UIColor.brandColor)
    }
    
    var rankUpCount: Observable<String> {
        _rankUp
            .unwrap()
            .map { $0.kmFormatted }
    }
    
    var rankDownCount: Observable<String> {
        _rankDown
            .unwrap()
            .map { $0.kmFormatted }
    }
    
    var brandColor: Observable<UIColor> {
        _brandColor
            .unwrap()
    }
    
    var rankedByUser: Observable<Int> {
        _rankedByUser
            .unwrap()
    }
    
    func configureRankUp(_ count: Int) {
        _rankUp.onNext(count)
    }
    
    func configureRankDown(_ count: Int) {
        _rankDown.onNext(count)
    }
    
    func configureRankedByUser(_ value: Int) {
        _rankedByUser.onNext(value)
    }
}
