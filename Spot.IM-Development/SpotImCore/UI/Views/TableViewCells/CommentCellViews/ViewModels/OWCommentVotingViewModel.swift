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
    
    var tapRankUp: PublishSubject<Void> { get }
    var tapRankDown: PublishSubject<Void> { get }
}

protocol OWCommentVotingViewModelingOutputs {
    var rankUpCount: Observable<String> { get }
    var rankDownCount: Observable<String> { get }
    var rankedByUser: Observable<Int> { get }
    var brandColor: Observable<UIColor> { get }
    var voteTypes: Observable<[VoteType]> { get }
    var rankUpSelected: Observable<Bool> { get }
    var rankDownSelected: Observable<Bool> { get }
}

protocol OWCommentVotingViewModeling {
    var inputs: OWCommentVotingViewModelingInputs { get }
    var outputs: OWCommentVotingViewModelingOutputs { get }
    
    // TODO - use RX
    var delegate: CommentActionsDelegate? { get set }
}

enum VoteType {
    case voteUp
    case voteDown
}

class OWCommentVotingViewModel: OWCommentVotingViewModeling,
                                OWCommentVotingViewModelingInputs,
                                OWCommentVotingViewModelingOutputs {
    
    var delegate: CommentActionsDelegate?

    var inputs: OWCommentVotingViewModelingInputs { return self }
    var outputs: OWCommentVotingViewModelingOutputs { return self }
    
    fileprivate let disposeBag = DisposeBag()
    
    var tapRankUp = PublishSubject<Void>()
    var tapRankDown = PublishSubject<Void>()
    
    fileprivate let _brandColor = BehaviorSubject<UIColor?>(value: nil)
    fileprivate let _rankUp = BehaviorSubject<Int?>(value: nil)
    fileprivate let _rankDown = BehaviorSubject<Int?>(value: nil)
    fileprivate let _rankedByUser = BehaviorSubject<Int?>(value: nil)
    
    fileprivate let _rankUpSelected = BehaviorSubject<Bool?>(value: nil)
    fileprivate let _rankDownSelected = BehaviorSubject<Bool?>(value: nil)
    
    fileprivate let _voteTypesToShow = BehaviorSubject<[VoteType]?>(value: nil)
    
    init () {
        _brandColor.onNext(UIColor.brandColor)
        
        self.handleVotesTypeToShow()
        self.setupObservers()
    }
    
    private func handleVotesTypeToShow() {
        var voteTypesToShow: [VoteType] = [.voteUp, .voteDown]
        
        if let convConfig = SPConfigsDataSource.appConfig?.conversation {
            if (convConfig.disableVoteUp == true) {
                voteTypesToShow.removeAll { $0 == .voteUp }
            }
            if (convConfig.disableVoteDown == true) {
                voteTypesToShow.removeAll { $0 == .voteDown }
            }
        }
        
        if let sharedConfig = SPConfigsDataSource.appConfig?.shared {
            if [OWVotesType.heart, OWVotesType.recommend].contains( sharedConfig.votesType) {
                voteTypesToShow.removeAll { $0 == .voteDown }
            }
        }
        
        _voteTypesToShow.onNext(voteTypesToShow)
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
    
    var voteTypes: Observable<[VoteType]> {
        _voteTypesToShow
            .unwrap()
    }
    
    var rankUpSelected: Observable<Bool> {
        _rankedByUser
            .unwrap()
            .map { $0 == 1 }
            .distinctUntilChanged()
    }
    
    var rankDownSelected: Observable<Bool> {
        _rankedByUser
            .unwrap()
            .map { $0 == -1 }
            .distinctUntilChanged()
    }
    
    private func setupObservers() {
        tapRankUp.withLatestFrom(rankedByUser)
            .subscribe(onNext: { [weak self] ranked in
                guard let self = self else { return }
                let from: SPRank = SPRank(rawValue: ranked) ?? .unrank
                let to: SPRank = (ranked == 0 || ranked == -1) ? .up : .unrank
                
                self.delegate?.rankUp(SPRankChange(from: from, to: to))
            })
            .disposed(by: disposeBag)
        
        tapRankDown.withLatestFrom(rankedByUser)
            .subscribe(onNext: { [weak self] ranked in
                guard let self = self else { return }
                let from: SPRank = SPRank(rawValue: ranked) ?? .unrank
                let to: SPRank = (ranked == 0 || ranked == 1) ? .down : .unrank
                
                self.delegate?.rankUp(SPRankChange(from: from, to: to))
            })
            .disposed(by: disposeBag)
    }
}
