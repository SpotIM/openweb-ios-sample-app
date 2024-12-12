//
//  OWCommentRatingViewModel.swift
//  OpenWebSDK
//
//  Created by  Nogah Melamed on 28/12/2022.
//  Copyright © 2022 OpenWeb. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

protocol OWCommentRatingViewModelingInputs {
    var rankChanged: PublishSubject<SPRankChange> { get }
    var tapRankUp: PublishSubject<Void> { get }
    var tapRankDown: PublishSubject<Void> { get }
    func update(for votingModel: OWCommentVotingModel)
}

protocol OWCommentRatingViewModelingOutputs {
    var rankUpText: Observable<String> { get }
    var rankDownText: Observable<String> { get }
    var voteTypes: Observable<[OWVoteType]> { get }
    var rankUpSelected: Observable<Bool> { get }
    var rankDownSelected: Observable<Bool> { get }
    var votingUpImages: Observable<OWVotingImages> { get }
    var votingDownImages: Observable<OWVotingImages> { get }
    var rankChangeTriggered: Observable<SPRankChange> { get }
    var commentActionsFontStyle: Observable<OWCommentActionsFontStyle> { get }
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

    private let disposeBag = DisposeBag()
    private let servicesProvider: OWSharedServicesProviding
    private var retryVote = PublishSubject<Void>()

    var rankChanged = PublishSubject<SPRankChange>()
    var tapRankUp = PublishSubject<Void>()
    var tapRankDown = PublishSubject<Void>()

    private let _rankUp = BehaviorSubject<Int?>(value: nil)
    private let _rankDown = BehaviorSubject<Int?>(value: nil)
    private let _rankedByUser = BehaviorSubject<Int?>(value: nil)

    private var _voteSymbolType: Observable<OWVotesType> {
        self.servicesProvider.spotConfigurationService()
            .config(spotId: OWManager.manager.spotId)
            .map { config -> OWVotesType in
                guard let sharedConfig = config.shared
                else { return .like }
                return sharedConfig.votesType
            }
            .asObservable()
    }

    lazy var commentActionsFontStyle: Observable<OWCommentActionsFontStyle> = {
        return Observable.just(self.customizationsLayer.commentActions.fontStyle)
    }()

    var rankChangeTriggered: Observable<SPRankChange> {
        let rankUpTriggeredObservable = tapRankUp
            .withLatestFrom(_rankedByUser.unwrap())
            .map { ranked -> SPRankChange in
                let from: SPRank = SPRank(rawValue: ranked) ?? .unrank
                let to: SPRank = (ranked == 0 || ranked == -1) ? .up : .unrank
                return SPRankChange(from: from, to: to)
            }

        let rankDownTriggeredObservable = tapRankDown
            .withLatestFrom(_rankedByUser.unwrap())
            .map { ranked -> SPRankChange in
                let from: SPRank = SPRank(rawValue: ranked) ?? .unrank
                let to: SPRank = (ranked == 0 || ranked == 1) ? .down : .unrank
                return SPRankChange(from: from, to: to)
            }

        return Observable.merge(rankUpTriggeredObservable, rankDownTriggeredObservable)
    }

    private let commentId: String

    init(servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared,
         customizationsLayer: OWCustomizations = OpenWeb.manager.ui.customizations) {
        self.servicesProvider = servicesProvider
        self.customizationsLayer = customizationsLayer
        commentId = ""
    }

    private let customizationsLayer: OWCustomizations

    init(model: OWCommentVotingModel,
         commentId: String,
         servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared,
         customizationsLayer: OWCustomizations = OpenWeb.manager.ui.customizations) {
        self.servicesProvider = servicesProvider
        self.customizationsLayer = customizationsLayer
        _rankUp.onNext(model.rankUpCount)
        _rankDown.onNext(model.rankDownCount)
        _rankedByUser.onNext(model.rankedByUserValue)
        self.commentId = commentId
        setupObservers()
    }

    func update(for votingModel: OWCommentVotingModel) {
        _rankUp.onNext(votingModel.rankUpCount)
        _rankDown.onNext(votingModel.rankDownCount)
        _rankedByUser.onNext(votingModel.rankedByUserValue)
    }

    var rankUpText: Observable<String> {
        _rankUp
            .unwrap()
            .withLatestFrom(_voteSymbolType) { rankUpCount, votesType in
                let formattedRankCount = rankUpCount.kmFormatted
                if votesType == .recommend {
                    let recommendText = OWLocalize.string("Recommend")
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

    var voteTypes: Observable<[OWVoteType]> {
        self.servicesProvider.spotConfigurationService()
            .config(spotId: OWManager.manager.spotId)
            .map { config -> [OWVoteType] in
                var voteTypesToShow: [OWVoteType] = [.voteUp, .voteDown]
                guard let convConfig = config.conversation
                else { return voteTypesToShow }

                if convConfig.disableVoteUp == true {
                    voteTypesToShow.removeAll { $0 == .voteUp }
                }
                if convConfig.disableVoteDown == true {
                    voteTypesToShow.removeAll { $0 == .voteDown }
                }
                return voteTypesToShow
            }
            .withLatestFrom(_voteSymbolType) { voteTypes, availableTypes -> [OWVoteType] in
                if [OWVotesType.heart, OWVotesType.recommend].contains(availableTypes) {
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

    var votingUpImages: Observable<OWVotingImages> {
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

    var votingDownImages: Observable<OWVotingImages> {
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

private extension OWCommentRatingViewModel {
    func setupObservers() {
        let rankChangedLocallyObservable: Observable<SPRankChange> = rankChanged
            .flatMapLatest { [weak self] rankChange -> Observable<SPRankChange> in
                guard let self else { return .empty() }

                return Observable.combineLatest(self._rankUp, self._rankDown)
                    .take(1)
                    .do(onNext: { [weak self] rankUp, rankDown in
                        guard let self else { return }
                        self.updateChangeLocally(rankChange: rankChange, rankUp: rankUp ?? 0, rankDown: rankDown ?? 0)
                    })
                    .map { _ in rankChange }
            }

        retryVote
            .bind(to: servicesProvider.toastNotificationService().clearCurrentToast)
            .disposed(by: disposeBag)

        let retryObserver = retryVote
            .withLatestFrom(rankChanged)

        // Updating Network/Remote about rank change
        Observable.merge(rankChangedLocallyObservable, retryObserver)
            .flatMapLatest { [weak self] rankChange -> Observable<Event<EmptyDecodable>> in
                guard let self,
                      let postId = OWManager.manager.postId,
                      let operation = rankChange.operation
                else { return .empty() }
                return self.servicesProvider
                    .networkAPI()
                    .conversation
                    .commentRankChange(conversationId: "\(OWManager.manager.spotId)_\(postId)", operation: operation, commentId: self.commentId)
                    .response
                    .materialize()
            }
            .subscribe(onNext: { [weak self] event  in
                guard let self else { return }
                switch event {
                case .error:
                    let data = OWToastRequiredData(type: .warning, action: .tryAgain, title: OWLocalize.string("SomethingWentWrong"))
                    self.servicesProvider.toastNotificationService()
                        .showToast(data: OWToastNotificationCombinedData(presentData: OWToastNotificationPresentData(data: data),
                                                                         actionCompletion: self.retryVote))
                default:
                    return
                }
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
        var comment = self.servicesProvider.commentsService().get(commentId: self.commentId, postId: postId)
        else { return }

        comment.rank = rank
        self.servicesProvider.commentsService().set(comments: [comment], postId: postId)
    }
}
