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

    fileprivate var _rankChange: PublishSubject<SPRankChange> = PublishSubject<SPRankChange>()
    fileprivate var rankChange: Observable<SPRankChange> {
        _rankChange.asObservable()
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
        tapRankUp.withLatestFrom(_rankedByUser.unwrap())
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
            .subscribe(onNext: { [weak self] ranked in
                guard let self = self else { return }
                let from: SPRank = SPRank(rawValue: ranked) ?? .unrank
                let to: SPRank = (ranked == 0 || ranked == -1) ? .up : .unrank
                let change = SPRankChange(from: from, to: to)
                self._rankChange.onNext(change)
            })
            .disposed(by: disposeBag)

        tapRankDown.withLatestFrom(_rankedByUser.unwrap())
            .subscribe(onNext: { [weak self] ranked in
                guard let self = self else { return }
                let from: SPRank = SPRank(rawValue: ranked) ?? .unrank
                let to: SPRank = (ranked == 0 || ranked == 1) ? .down : .unrank
                // TODO: call new api rank + update local
            })
            .disposed(by: disposeBag)

        rankChange
            .flatMap { [weak self] rankChange -> Observable<EmptyDecodable> in
                guard let self = self,
                      let postId = OWManager.manager.postId,
                      let operation = rankChange.operation
                else { return .empty() }

                self.updateChangeLocally(rankChange: rankChange)
                return self.sharedServiceProvider
                .netwokAPI()
                .conversation
                .commentRankChange(conversationId: "\(OWManager.manager.spotId)_\(postId)", operation: operation, commentId: self.commentId)
                .response
            }
            .subscribe(onError: { error in
                // TODO: if did not work - change locally back
                print("NOGAH: error \(error)")
            })
            .disposed(by: disposeBag)
    }

    func updateChangeLocally(rankChange: SPRankChange) {
        switch (rankChange.from, rankChange.to) {
        case (.unrank, .up):
            _rankedByUser.onNext(1)
//            rankUp += 1
        case (.unrank, .down):
            _rankedByUser.onNext(-1)
//            rankDown += 1
        case (.up, .unrank):
            _rankedByUser.onNext(0)
//            rankUp -= 1
        case (.up, .down):
            _rankedByUser.onNext(-1)
//            rankUp -= 1
//            rankDown += 1
        case (.down, .unrank):
            _rankedByUser.onNext(0)
//            rankDown -= 1
        case (.down, .up):
            _rankedByUser.onNext(1)
//            rankUp += 1
//            rankDown -= 1
        default: break
        }
    }
}
