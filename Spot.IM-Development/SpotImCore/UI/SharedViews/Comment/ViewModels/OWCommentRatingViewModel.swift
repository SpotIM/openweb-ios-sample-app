//
//  OWCommentRatingViewModel.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 28/12/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

protocol OWCommentRatingViewModelingInputs {
    // TODO: handle taps!    
    var tapRankUp: PublishSubject<Void> { get }
    var tapRankDown: PublishSubject<Void> { get }
}

protocol OWCommentRatingViewModelingOutputs {
    var rankUpText: Observable<String> { get }
    var rankDownText: Observable<String> { get }
    var voteTypes: Observable<[VoteType]> { get }
    var rankUpSelected: Observable<Bool> { get }
    var rankDownSelected: Observable<Bool> { get }
    
    var votingUpImages: Observable<VotingImages> { get }
    var votingDownImages: Observable<VotingImages> { get }
}

protocol OWCommentRatingViewModeling {
    var inputs: OWCommentRatingViewModelingInputs { get }
    var outputs: OWCommentRatingViewModelingOutputs { get }
}

class OWCommentRatingViewModel: OWCommentRatingViewModeling,
                                OWCommentRatingViewModelingInputs,
                                OWCommentRatingViewModelingOutputs {
    
    // TODO - use RX
    fileprivate var delegate: CommentActionsDelegate?

    var inputs: OWCommentRatingViewModelingInputs { return self }
    var outputs: OWCommentRatingViewModelingOutputs { return self }
    
    fileprivate let disposeBag = DisposeBag()
    
    var tapRankUp = PublishSubject<Void>()
    var tapRankDown = PublishSubject<Void>()
    
    fileprivate let _rankUp = BehaviorSubject<Int?>(value: nil)
    fileprivate let _rankDown = BehaviorSubject<Int?>(value: nil)
    fileprivate let _rankedByUser = BehaviorSubject<Int?>(value: nil)
    
    fileprivate let _rankUpSelected = BehaviorSubject<Bool?>(value: nil)
    fileprivate let _rankDownSelected = BehaviorSubject<Bool?>(value: nil)
    
    fileprivate var _votesType : Observable<OWVotesType> {
        OWSharedServicesProvider.shared.spotConfigurationService()
            .config(spotId: OWManager.manager.spotId)
            .map { config -> OWVotesType in
                guard let sharedConfig = config.shared,
                      [OWVotesType.heart, OWVotesType.recommend].contains( sharedConfig.votesType)
                else { return .like }
                
                return sharedConfig.votesType
            }
            .asObservable()
    }
    
    fileprivate let _votingUpImages = BehaviorSubject<VotingImages>(value: (nil, nil))
    fileprivate let _votingDownImages = BehaviorSubject<VotingImages>(value: (nil, nil))
    
    init () { }
    
    init(model: OWCommentVotingModel) {
        _rankUp.onNext(model.rankUpCount)
        _rankDown.onNext(model.rankDownCount)
        _rankedByUser.onNext(model.rankedByUserValue)
        
        setupObservers()
    }
    
    var rankUpText: Observable<String> {
        _rankUp
            .unwrap()
            .withLatestFrom(_votesType) { rankUpCount, votesType in
                let formattedRankCount = rankUpCount.kmFormatted
                if (votesType == .recommend) {
                    let recommendText = LocalizationManager.localizedString(key: "Recommend")
                    return "\(recommendText) (\(formattedRankCount))"
                } else {
                    return rankUpCount > 0 ? formattedRankCount : ""
                }
            }
    }
    
    var rankDownText: Observable<String> {
        _rankDown
            .unwrap()
            .map { $0 > 0 ? $0.kmFormatted : "" }
    }
    
    var voteTypes : Observable<[VoteType]> {
        OWSharedServicesProvider.shared.spotConfigurationService()
            .config(spotId: OWManager.manager.spotId)
            .map { config -> [VoteType] in
                var voteTypesToShow: [VoteType] = [.voteUp, .voteDown]
                guard let convConfig = config.conversation
                else { return voteTypesToShow }
                
                if (convConfig.disableVoteUp == true) {
                    voteTypesToShow.removeAll { $0 == .voteUp }
                }
                if (convConfig.disableVoteDown == true) {
                    voteTypesToShow.removeAll { $0 == .voteDown }
                }
                return voteTypesToShow
            }
            .asObservable()
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
        _votesType
            .map { votesType in
                switch votesType {
                case .like:
                    return (
                        regular: UIImage(spNamed: "rank_like_up"),
                        selected: UIImage(spNamed: "rank_like_up_selected")
                    )
                case .updown:
                    return (
                        regular: UIImage(spNamed: "rank_arrow_up"),
                        selected: UIImage(spNamed: "rank_arrow_up_selected")
                    )
                case .recommend:
                    return (
                        regular: UIImage(spNamed: "rank_star"),
                        selected: UIImage(spNamed: "rank_star_selected")
                    )
                case .heart:
                    return (
                        regular: UIImage(spNamed: "rank_heart"),
                        selected: UIImage(spNamed: "rank_heart_selected")
                    )
                }
            }
    }
    
    var votingDownImages: Observable<VotingImages> {
        _votesType
            .map { votesType in
                switch votesType {
                case .like:
                    return (
                        regular: UIImage(spNamed: "rank_like_down"),
                        selected: UIImage(spNamed: "rank_like_down_selected")
                    )
                case .updown:
                    return (
                        regular: UIImage(spNamed: "rank_arrow_down"),
                        selected: UIImage(spNamed: "rank_arrow_down_selected")
                    )
                default:
                    return (nil, nil)
                }
            }
    }
}

fileprivate extension OWCommentRatingViewModel {
    func setupObservers() {
        tapRankUp.withLatestFrom(_rankedByUser.unwrap())
            .subscribe(onNext: { [weak self] ranked in
                guard let self = self else { return }
                let from: SPRank = SPRank(rawValue: ranked) ?? .unrank
                let to: SPRank = (ranked == 0 || ranked == -1) ? .up : .unrank
                
//                self.delegate?.rankUp(SPRankChange(from: from, to: to)) // TODO: call new api rank
            })
            .disposed(by: disposeBag)
        
        tapRankDown.withLatestFrom(_rankedByUser.unwrap())
            .subscribe(onNext: { [weak self] ranked in
                guard let self = self else { return }
                let from: SPRank = SPRank(rawValue: ranked) ?? .unrank
                let to: SPRank = (ranked == 0 || ranked == 1) ? .down : .unrank
                
//                self.delegate?.rankUp(SPRankChange(from: from, to: to)) // TODO: call new api rank
            })
            .disposed(by: disposeBag)
    }
}
