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

typealias VotingImages = (regular: UIImage?, selected: UIImage?)

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
    
    var votingUpImages: Observable<VotingImages> { get }
    var votingDownImages: Observable<VotingImages> { get }
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
    
    fileprivate let _votingUpImages = BehaviorSubject<VotingImages?>(value: nil)
    fileprivate let _votingDownImages = BehaviorSubject<VotingImages?>(value: nil)
    
    init () {
        _brandColor.onNext(UIColor.brandColor)
        
        self.handleVotesTypeToShow()
        self.handleVotingImages()
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
    
    private func handleVotingImages() {
        if let sharedConfig = SPConfigsDataSource.appConfig?.shared {
            let votesType = sharedConfig.votesType
            let votingUpImages: VotingImages
            var votingDownImages: VotingImages? = nil
            switch votesType {
            case .like:
                votingUpImages = (
                    regular: UIImage(spNamed: "rank_like_up"),
                    selected: UIImage(spNamed: "rank_like_up_selected")
                )
                votingDownImages = (
                    regular: UIImage(spNamed: "rank_like_down"),
                    selected: UIImage(spNamed: "rank_like_down_selected")
                )
                break
            case .updown:
                votingUpImages = (
                    regular: UIImage(spNamed: "rank_arrow_up"),
                    selected: UIImage(spNamed: "rank_arrow_up_selected")
                )
                votingDownImages = (
                    regular: UIImage(spNamed: "rank_arrow_down"),
                    selected: UIImage(spNamed: "rank_arrow_down_selected")
                )
                break
            case .recommend:
                votingUpImages = (
                    regular: UIImage(spNamed: "rank_star"),
                    selected: UIImage(spNamed: "rank_star_selected")
                )
                break
            case .heart:
                votingUpImages = (
                    regular: UIImage(spNamed: "rank_heart"),
                    selected: UIImage(spNamed: "rank_heart_selected")
                )
                break
            }
            _votingUpImages.onNext(votingUpImages)
            _votingDownImages.onNext(votingDownImages)
        }
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
    
    var votingUpImages: Observable<VotingImages> {
        _votingUpImages
            .unwrap()
    }
    
    var votingDownImages: Observable<VotingImages> {
        _votingDownImages
            .unwrap()
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
