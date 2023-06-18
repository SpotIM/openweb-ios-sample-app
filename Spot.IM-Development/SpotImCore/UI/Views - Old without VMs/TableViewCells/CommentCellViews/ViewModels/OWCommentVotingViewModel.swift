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
    func configure(with model: OWCommentVotingModel)

    func setDelegate(_ delegate: CommentActionsDelegate)

    var tapRankUp: PublishSubject<Void> { get }
    var tapRankDown: PublishSubject<Void> { get }
}

protocol OWCommentVotingViewModelingOutputs {
    var rankUpText: Observable<String> { get }
    var rankDownText: Observable<String> { get }
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
}

enum VoteType {
    case voteUp
    case voteDown
}

class OWCommentVotingViewModel: OWCommentVotingViewModeling,
                                OWCommentVotingViewModelingInputs,
                                OWCommentVotingViewModelingOutputs {

    // TODO - use RX
    fileprivate var delegate: CommentActionsDelegate?

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

    fileprivate let _votesType = BehaviorSubject<OWVotesType?>(value: nil)

    fileprivate let _voteTypesToShow = BehaviorSubject<[VoteType]?>(value: nil)

    fileprivate let _votingUpImages = BehaviorSubject<VotingImages>(value: (nil, nil))
    fileprivate let _votingDownImages = BehaviorSubject<VotingImages>(value: (nil, nil))

    init () {
        _brandColor.onNext(UIColor.brandColor)

        self.handleVotesType()
        self.setupObservers()
    }

    var rankUpText: Observable<String> {
        _rankUp
            .unwrap()
            .withLatestFrom(_votesType.unwrap()) { rankUpCount, votesType in
                let formattedRankCount = rankUpCount.kmFormatted
                if (votesType == .recommend) {
                    let recommendText = SPLocalizationManager.localizedString(key: "Recommend")
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

    var brandColor: Observable<UIColor> {
        _brandColor
            .unwrap()
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
        _votesType
            .unwrap()
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
            .unwrap()
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

    func setDelegate(_ delegate: CommentActionsDelegate) {
        self.delegate = delegate
    }

    func configure(with model: OWCommentVotingModel) {
        _rankUp.onNext(model.rankUpCount)
        _rankDown.onNext(model.rankDownCount)
        _rankedByUser.onNext(model.rankedByUserValue)
    }
}

fileprivate extension OWCommentVotingViewModel {
    func handleVotesType() {
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
            _votesType.onNext(sharedConfig.votesType)
        } else {
            _votesType.onNext(.like) // default
        }

        _voteTypesToShow.onNext(voteTypesToShow)
    }

    func setupObservers() {
        tapRankUp.withLatestFrom(_rankedByUser.unwrap())
            .subscribe(onNext: { [weak self] ranked in
                guard let self = self else { return }
                let from: SPRank = SPRank(rawValue: ranked) ?? .unrank
                let to: SPRank = (ranked == 0 || ranked == -1) ? .up : .unrank

                self.delegate?.rankUp(SPRankChange(from: from, to: to))
            })
            .disposed(by: disposeBag)

        tapRankDown.withLatestFrom(_rankedByUser.unwrap())
            .subscribe(onNext: { [weak self] ranked in
                guard let self = self else { return }
                let from: SPRank = SPRank(rawValue: ranked) ?? .unrank
                let to: SPRank = (ranked == 0 || ranked == 1) ? .down : .unrank

                self.delegate?.rankUp(SPRankChange(from: from, to: to))
            })
            .disposed(by: disposeBag)
    }
}
