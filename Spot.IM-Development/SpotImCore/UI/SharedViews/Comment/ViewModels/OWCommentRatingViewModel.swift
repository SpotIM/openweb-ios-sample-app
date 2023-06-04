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

    var inputs: OWCommentRatingViewModelingInputs { return self }
    var outputs: OWCommentRatingViewModelingOutputs { return self }

    fileprivate let disposeBag = DisposeBag()
    fileprivate let sharedServiceProvider: OWSharedServicesProviding

    var tapRankUp = PublishSubject<Void>()
    var tapRankDown = PublishSubject<Void>()

    fileprivate let _rankUp = BehaviorSubject<Int?>(value: nil)
    fileprivate let _rankDown = BehaviorSubject<Int?>(value: nil)
    fileprivate let _rankedByUser = BehaviorSubject<Int?>(value: nil)

    fileprivate var _voteSymbolType: Observable<OWVotesType> {
        self.sharedServiceProvider.spotConfigurationService()
            .config(spotId: OWManager.manager.spotId)
            .map { config -> OWVotesType in
                guard let sharedConfig = config.shared
                else { return .like }
                return sharedConfig.votesType
            }
            .asObservable()
    }

    fileprivate let commentId: String

    init (sharedServiceProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.sharedServiceProvider = sharedServiceProvider
        commentId = ""
    }

    init(model: OWCommentVotingModel, commentId: String, sharedServiceProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.sharedServiceProvider = sharedServiceProvider
        _rankUp.onNext(model.rankUpCount)
        _rankDown.onNext(model.rankDownCount)
        _rankedByUser.onNext(model.rankedByUserValue)
        self.commentId = commentId
        setupObservers()
    }

    var rankUpText: Observable<String> {
        _rankUp
            .unwrap()
            .withLatestFrom(_voteSymbolType) { rankUpCount, votesType in
                let formattedRankCount = rankUpCount.kmFormatted
                if (votesType == .recommend) {
                    let recommendText = OWLocalizationManager.shared.localizedString(key: "Recommend")
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

    var voteTypes: Observable<[VoteType]> {
        self.sharedServiceProvider.spotConfigurationService()
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
            .withLatestFrom(_voteSymbolType) { voteTypes, availableTypes -> [VoteType] in
                if([OWVotesType.heart, OWVotesType.recommend].contains(availableTypes)) {
                    return voteTypes.filter { $0 == .voteUp }
                }
                return voteTypes
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
        _voteSymbolType
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
        _voteSymbolType
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
        let rankUpTriggeredObservable = tapRankUp.withLatestFrom(_rankedByUser.unwrap())
            .flatMapLatest { [weak self] ranked -> Observable<Int> in
                // 1. Triggering authentication UI if needed
                guard let self = self else { return .empty() }
                return self.sharedServiceProvider.authenticationManager().ifNeededTriggerAuthenticationUI(for: .votingComment)
                    .map { _ in ranked }
            }
            .flatMapLatest { [weak self] ranked -> Observable<Int> in
                // 2. Waiting for authentication required for voting
                guard let self = self else { return .empty() }
                return self.sharedServiceProvider.authenticationManager().waitForAuthentication(for: .votingComment)
                    .map { _ in ranked }
            }
            .map { ranked -> SPRankChange in
                let from: SPRank = SPRank(rawValue: ranked) ?? .unrank
                let to: SPRank = (ranked == 0 || ranked == -1) ? .up : .unrank
                return SPRankChange(from: from, to: to)
            }

        let rankDownTriggeredObservable = tapRankDown.withLatestFrom(_rankedByUser.unwrap())
            .flatMapLatest { [weak self] ranked -> Observable<Int> in
                // 1. Triggering authentication UI if needed
                guard let self = self else { return .empty() }
                return self.sharedServiceProvider.authenticationManager().ifNeededTriggerAuthenticationUI(for: .votingComment)
                    .map { _ in ranked }
            }
            .flatMapLatest { [weak self] ranked -> Observable<Int> in
                // 2. Waiting for authentication required for voting
                guard let self = self else { return .empty() }
                return self.sharedServiceProvider.authenticationManager().waitForAuthentication(for: .votingComment)
                    .map { _ in ranked }
            }
            .map { ranked -> SPRankChange in
                let from: SPRank = SPRank(rawValue: ranked) ?? .unrank
                let to: SPRank = (ranked == 0 || ranked == 1) ? .down : .unrank
                return SPRankChange(from: from, to: to)
            }

        let rankChangedLocallyObservable: Observable<SPRankChange> = Observable.merge(rankUpTriggeredObservable, rankDownTriggeredObservable)
            .flatMap { [weak self] rankChange -> Observable<SPRankChange> in
                guard let self = self else { return .empty() }

                return Observable.combineLatest(self._rankUp, self._rankDown)
                    .take(1)
                    .do(onNext: { [weak self] rankUp, rankDown in
                        guard let self = self else { return }
                        self.updateChangeLocally(rankChange: rankChange, rankUp: rankUp ?? 0, rankDown: rankDown ?? 0)
                    })
                    .map { _ in rankChange}
            }

        // Updating Network/Remote about rank change
        rankChangedLocallyObservable
            .flatMap { [weak self] rankChange -> Observable<EmptyDecodable> in
                guard let self = self,
                      let postId = OWManager.manager.postId,
                      let operation = rankChange.operation
                else { return .empty() }

                return self.sharedServiceProvider
                    .netwokAPI()
                    .conversation
                    .commentRankChange(conversationId: "\(OWManager.manager.spotId)_\(postId)", operation: operation, commentId: self.commentId)
                    .response
            }
            .subscribe(onError: { error in
                // TODO: if did not work - change locally back (using rankChange.reverse)
                print("error \(error)")
            })
            .disposed(by: disposeBag)
    }

    func updateChangeLocally(rankChange: SPRankChange, rankUp: Int, rankDown: Int) {
        var rankedByUserCount: Int = 0
        var rankUpCount: Int = rankUp
        var rankDownCount: Int = rankDown

        switch (rankChange.from, rankChange.to) {
        case (.unrank, .up):
            rankedByUserCount = 1
            rankUpCount = rankUp + 1
        case (.unrank, .down):
            rankedByUserCount = -1
            rankDownCount = rankDown + 1
        case (.up, .unrank):
            rankedByUserCount = 0
            rankUpCount = rankUp - 1
        case (.up, .down):
            rankedByUserCount = -1
            rankUpCount = rankUp - 1
            rankDownCount = rankDown + 1
        case (.down, .unrank):
            rankedByUserCount = 0
            rankDownCount = rankDown - 1
        case (.down, .up):
            rankedByUserCount = 1
            rankUpCount = rankUp + 1
            rankDownCount = rankDown - 1
        default: break
        }

        _rankedByUser.onNext(rankedByUserCount)
        _rankUp.onNext(rankUpCount)
        _rankDown.onNext(rankDownCount)

        let newRank = OWComment.Rank(ranksUp: rankUpCount, ranksDown: rankDownCount, rankedByCurrentUser: rankedByUserCount)
        updateRankChangeInCommentsService(rank: newRank)
    }

    func updateRankChangeInCommentsService(rank: OWComment.Rank) {
        guard let postId = OWManager.manager.postId,
        var comment = self.sharedServiceProvider.commentsService().get(commentId: self.commentId, postId: postId)
        else { return }

        comment.rank = rank
        self.sharedServiceProvider.commentsService().set(comments: [comment], postId: postId)
    }
}
