//
//  OWCommentEngagementViewModel.swift
//  OpenWebSDK
//
//  Created by  Nogah Melamed on 27/12/2022.
//  Copyright © 2022 OpenWeb. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

protocol OWCommentEngagementViewModelingInputs {
    var replyClicked: PublishSubject<Void> { get }
    var shareClicked: PublishSubject<Void> { get }
    var isReadOnly: BehaviorSubject<Bool> { get }
    func update(for comment: OWComment)
}

protocol OWCommentEngagementViewModelingOutputs {
    var votingVM: OWCommentRatingViewModeling { get }
    var replyClickedOutput: Observable<Void> { get }
    var shareCommentUrl: Observable<URL> { get }
    var showReplyButton: Observable<Bool> { get }
    var votesPosition: Observable<OWVotesPosition> { get }
    var shareButtonStyle: Observable<OWShareButtonStyle> { get }
    var commentActionsFontStyle: OWCommentActionsFontStyle { get }
    var commentActionsColor: OWCommentActionsColor { get }
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
    fileprivate let sharedServiceProvider: OWSharedServicesProviding

    fileprivate let commentId: String
    fileprivate let parentCommentId: String?

    var replyClicked = PublishSubject<Void>()
    var replyClickedOutput: Observable<Void> {
        replyClicked
            .asObservable()
    }

    var shareClicked = PublishSubject<Void>()
    var shareCommentUrl: Observable<URL> {
        shareClicked
            .flatMap({ [weak self] _ -> Observable<Event<OWShareLink>> in
                guard let self = self else { return .empty() }
                return self.sharedServiceProvider.networkAPI()
                    .conversation
                    .commentShare(id: self.commentId, parentId: self.parentCommentId)
                    .response
                    .materialize() // Required to keep the final subscriber even if errors arrived from the network
            })
            .map { event -> URL? in
                switch event {
                case .next(let shareLink):
                    return shareLink.reference
                case .error(_):
                    return nil
                default:
                    return nil
                }
            }
            .unwrap()
            .asObservable()
    }

    var isReadOnly = BehaviorSubject(value: true)
    var showReplyButton: Observable<Bool> {
        isReadOnly
            .map { !$0 }
            .asObservable()
    }

    lazy var votesPosition: Observable<OWVotesPosition> = {
        self.sharedServiceProvider.spotConfigurationService()
            .config(spotId: OWManager.manager.spotId)
            .map { config -> OWVotesPosition in
                guard let sharedConfig = config.shared
                else { return .default }
                return sharedConfig.votesPosition
            }
            .asObservable()
    }()

    lazy var commentActionsColor: OWCommentActionsColor = {
        self.customizationsLayer.commentActions.color
    }()

    lazy var commentActionsFontStyle: OWCommentActionsFontStyle = {
        self.customizationsLayer.commentActions.fontStyle
    }()

    lazy var shareButtonStyle: Observable<OWShareButtonStyle> = {
        self.sharedServiceProvider.spotConfigurationService()
            .config(spotId: OWManager.manager.spotId)
            .map { config -> OWShareButtonStyle in
                return config.mobileSdk.shareButtonStyle
            }
            .asObservable()
    }()

    fileprivate let customizationsLayer: OWCustomizations

    init(comment: OWComment,
         sharedServiceProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared,
         customizationsLayer: OWCustomizations = OpenWeb.manager.ui.customizations) {
        self.sharedServiceProvider = sharedServiceProvider
        self.customizationsLayer = customizationsLayer
        self.commentId = comment.id ?? ""
        self.parentCommentId = comment.parentId
        let rank = comment.rank ?? OWComment.Rank()
        votingVM = OWCommentRatingViewModel(model: OWCommentVotingModel(
            rankUpCount: rank.ranksUp ?? 0,
            rankDownCount: rank.ranksDown ?? 0,
            rankedByUserValue: rank.rankedByCurrentUser ?? 0
        ), commentId: commentId)
    }

    func update(for comment: OWComment) {
        let rank = comment.rank ?? OWComment.Rank()
        let votingModel = OWCommentVotingModel(
            rankUpCount: rank.ranksUp ?? 0,
            rankDownCount: rank.ranksDown ?? 0,
            rankedByUserValue: rank.rankedByCurrentUser ?? 0
        )
        votingVM.inputs.update(for: votingModel)
    }

    init(sharedServiceProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared,
         customizationsLayer: OWCustomizations = OpenWeb.manager.ui.customizations) {
        self.sharedServiceProvider = sharedServiceProvider
        self.customizationsLayer = customizationsLayer
        self.votingVM = OWCommentRatingViewModel()
        self.commentId = ""
        self.parentCommentId = nil
    }
}
