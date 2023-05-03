//
//  OWConversationViewVM.swift
//  SpotImCore
//
//  Created by Alon Haiut on 06/07/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

// Our sections is just a string as we will flat all the comments, replies, ads and everything into cells
typealias ConversationDataSourceModel = OWAnimatableSectionModel<String, OWConversationCellOption>

protocol OWConversationViewViewModelingInputs {
    var viewInitialized: PublishSubject<Void> { get }
}

protocol OWConversationViewViewModelingOutputs {
    var shouldShowTiTleHeader: Bool { get }
    var conversationTitleHeaderViewModel: OWConversationTitleHeaderViewModeling { get }
    var articleDescriptionViewModel: OWArticleDescriptionViewModeling { get }
    var conversationSummaryViewModel: OWConversationSummaryViewModeling { get }
    var communityGuidelinesCellViewModel: OWCommunityGuidelinesCellViewModeling { get }
    var conversationDataSourceSections: Observable<[ConversationDataSourceModel]> { get }
    var updateCellSizeAtIndex: Observable<Int> { get }
    var initialDataLoaded: Observable<Bool> { get }
}

protocol OWConversationViewViewModeling {
    var inputs: OWConversationViewViewModelingInputs { get }
    var outputs: OWConversationViewViewModelingOutputs { get }
}

class OWConversationViewViewModel: OWConversationViewViewModeling,
                                    OWConversationViewViewModelingInputs,
                                    OWConversationViewViewModelingOutputs {
    var inputs: OWConversationViewViewModelingInputs { return self }
    var outputs: OWConversationViewViewModelingOutputs { return self }

    fileprivate struct Metrics {
        static let numberOfCommentsInSkeleton: Int = 4
        static let delayForUICellUpdate: Int = 100
    }

    fileprivate var postId: OWPostId {
        return OWManager.manager.postId ?? ""
    }

    fileprivate let servicesProvider: OWSharedServicesProviding
    fileprivate let conversationData: OWConversationRequiredData
    fileprivate let viewableMode: OWViewableMode
    fileprivate let disposeBag = DisposeBag()

    fileprivate var offset = 0

    fileprivate var _commentsPresentationData = OWObservableArray<OWCommentPresentationData>()

    lazy var conversationTitleHeaderViewModel: OWConversationTitleHeaderViewModeling = {
        return OWConversationTitleHeaderViewModel()
    }()

    lazy var articleDescriptionViewModel: OWArticleDescriptionViewModeling = {
        return OWArticleDescriptionViewModel(article: conversationData.article)
    }()

    lazy var conversationSummaryViewModel: OWConversationSummaryViewModeling = {
        return OWConversationSummaryViewModel()
    }()

    lazy var communityQuestionCellViewModel: OWCommunityQuestionCellViewModeling = {
        return OWCommunityQuestionCellViewModel(style: conversationStyle.communityQuestionStyle)
    }()

    lazy var communitySpacerCellViewModel: OWSpacerCellViewModeling = {
        return OWSpacerCellViewModel(style: .community)
    }()

    lazy var communityGuidelinesCellViewModel: OWCommunityGuidelinesCellViewModeling = {
        return OWCommunityGuidelinesCellViewModel(style: conversationStyle.communityGuidelinesStyle)
    }()

    fileprivate lazy var communityQuestionCellOptions: OWConversationCellOption = {
        return OWConversationCellOption.communityQuestion(viewModel: communityQuestionCellViewModel)
    }()

    fileprivate lazy var communityGuidelinesCellOption: OWConversationCellOption = {
        return OWConversationCellOption.communityGuidelines(viewModel: communityGuidelinesCellViewModel)
    }()

    fileprivate lazy var communitySpacerCellOption: OWConversationCellOption = {
        return OWConversationCellOption.spacer(viewModel: communitySpacerCellViewModel)
    }()

    fileprivate var shouldShowCommunityQuestion: Observable<Bool> {
        return communityQuestionCellViewModel.outputs
            .communityQuestionViewModel.outputs
            .shouldShowView
    }

    fileprivate var shouldShowCommunityGuidelines: Observable<Bool> {
        return communityGuidelinesCellViewModel.outputs
            .communityGuidelinesViewModel.outputs
            .shouldShowView
    }

    fileprivate var commentCellsOptions: Observable<[OWConversationCellOption]> {
        return _commentsPresentationData
            .rx_elements()
            .flatMapLatest({ [weak self] commentsPresentationData -> Observable<[OWConversationCellOption]> in
                guard let self = self else { return Observable.never() }

                return Observable.just(self.getCommentCells(for: commentsPresentationData))
            })
            .share()
            .asObservable()
    }

    fileprivate var topCellsOptions: Observable<[OWConversationCellOption]> {
        return Observable.combineLatest(shouldShowCommunityQuestion, shouldShowCommunityGuidelines)
            .flatMapLatest({ [weak self] showCommunityQuestion, showCommunityGuidlines -> Observable<[OWConversationCellOption]> in
                guard let self = self else { return Observable.never() }
                return Observable.just(self.getTopCells(shouldShowCommunityQuestion: showCommunityQuestion, shouldShowCommunityGuidelines: showCommunityGuidlines))
            })
            .share()
            .asObservable()
    }

    fileprivate var cellsViewModels: Observable<[OWConversationCellOption]> {
        return Observable.combineLatest(topCellsOptions.startWith([]), commentCellsOptions.startWith([]))
            .flatMapLatest({ [weak self] topCellsOptions, commentCellsOptions -> Observable<[OWConversationCellOption]> in
                guard let self = self else { return Observable.never() }
                if commentCellsOptions.isEmpty {
                    return Observable.just(self.getSkeletonCells())
                }
                return Observable.just(topCellsOptions + commentCellsOptions)
            })
    }

    fileprivate var _changeSizeAtIndex = PublishSubject<Int>()
    var updateCellSizeAtIndex: Observable<Int> {
        return _changeSizeAtIndex
            .asObservable()
    }

    fileprivate var _initialDataLoaded = BehaviorSubject<Bool>(value: false)
    var initialDataLoaded: Observable<Bool> {
        return _initialDataLoaded
            .asObservable()
    }

    var conversationDataSourceSections: Observable<[ConversationDataSourceModel]> {
        return cellsViewModels
            .map { items in
                // TODO: We might decide to work with few sections in the future.
                // Current implementation will be one section.
                // The String can be the `postId` which we will add once the VM will be ready.
                let section = ConversationDataSourceModel(model: "postId", items: items)
                return [section]
            }
    }

    fileprivate lazy var conversationStyle: OWConversationStyle = {
        return self.conversationData.settings?.style ?? OWConversationStyle.regular
    }()

    var shouldShowTiTleHeader: Bool {
        return viewableMode == .independent
    }

    var viewInitialized = PublishSubject<Void>()

    init (servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared,
          conversationData: OWConversationRequiredData,
          viewableMode: OWViewableMode) {
        self.servicesProvider = servicesProvider
        self.conversationData = conversationData
        self.viewableMode = viewableMode
        setupObservers()
    }
}

fileprivate extension OWConversationViewViewModel {
    func getCommentCells(for commentsPresentationData: [OWCommentPresentationData]) -> [OWConversationCellOption] {
        var cellOptions = [OWConversationCellOption]()

        for (idx, commentPresentationData) in commentsPresentationData.enumerated() {
            guard let commentCellVM = self.getCommentCellVm(for: commentPresentationData.id) else { continue }

            if (commentCellVM.outputs.commentVM.outputs.comment.depth == 0 && idx > 0) {
                cellOptions.append(OWConversationCellOption.spacer(viewModel: OWSpacerCellViewModel(style: .comment)))
            }

            cellOptions.append(OWConversationCellOption.comment(viewModel: commentCellVM))

            let depth = commentCellVM.outputs.commentVM.outputs.comment.depth ?? 0

            let repliesToShowCount = commentPresentationData.repliesPresentation.count

            switch (repliesToShowCount, commentPresentationData.totalRepliesCount) {
            case (_, 0):
                break
            case (0, _):
                cellOptions.append(OWConversationCellOption.commentThreadExpand(viewModel: OWCommentThreadExpandCellViewModel(data: commentPresentationData, depth: depth)))
            default:
                cellOptions.append(OWConversationCellOption.commentThreadCollapse(viewModel: OWCommentThreadCollapseCellViewModel(data: commentPresentationData, depth: depth)))

                cellOptions.append(contentsOf: getCommentCells(for: commentPresentationData.repliesPresentation))

                if (repliesToShowCount < commentPresentationData.totalRepliesCount) {
                    cellOptions.append(OWConversationCellOption.commentThreadExpand(viewModel: OWCommentThreadExpandCellViewModel(data: commentPresentationData, depth: depth)))
                }
            }
        }
        return cellOptions
    }

    func getTopCells(shouldShowCommunityQuestion: Bool, shouldShowCommunityGuidelines: Bool) -> [OWConversationCellOption] {
        var cells = [OWConversationCellOption]()

        switch (shouldShowCommunityQuestion, shouldShowCommunityGuidelines) {
        case (true, true):
            cells.append(contentsOf: [self.communityQuestionCellOptions,
                                             self.communitySpacerCellOption,
                                             self.communityGuidelinesCellOption])
        case (true, false):
            cells.append(self.communityQuestionCellOptions)
        case (false, true):
            cells.append(self.communityGuidelinesCellOption)
        default:
            break
        }

        return cells
    }

    func getSkeletonCells() -> [OWConversationCellOption] {
        let skeletonCellVMs = (0 ..< Metrics.numberOfCommentsInSkeleton).map { _ in
            OWCommentSkeletonShimmeringCellViewModel()
        }
        let skeletonCells = skeletonCellVMs.map { OWConversationCellOption.commentSkeletonShimmering(viewModel: $0) }

        return skeletonCells
    }

    func getCommentsPresentationData(from response: OWConversationReadRM) -> [OWCommentPresentationData] {
        guard let responseComments = response.conversation?.comments else { return [] }

        let comments: [OWComment] = Array(responseComments)

        var commentsPresentationData = [OWCommentPresentationData]()
        var repliesPresentationData = [OWCommentPresentationData]()

        self.offset = response.conversation?.offset ?? 0

        for comment in comments {
            guard let commentId = comment.id else { continue }

            if let replies = comment.replies {

                repliesPresentationData = []

                for reply in replies {
                    guard let replyId = reply.id else { continue }

                    let replyPresentationData = OWCommentPresentationData(
                        id: replyId,
                        repliesIds: reply.replies?.map { $0.id! } ?? [],
                        totalRepliesCount: reply.repliesCount ?? 0,
                        repliesOffset: reply.offset ?? 0,
                        repliesPresentation: []
                    )

                    repliesPresentationData.append(replyPresentationData)
                }
            }

            let commentPresentationData = OWCommentPresentationData(
                id: commentId,
                repliesIds: comment.replies?.map { $0.id! } ?? [],
                totalRepliesCount: comment.repliesCount ?? 0,
                repliesOffset: comment.offset ?? 0,
                repliesPresentation: repliesPresentationData
            )

            commentsPresentationData.append(commentPresentationData)
        }
        return commentsPresentationData
    }

    func getExistingRepliesPresentationData(for commentPresentationData: OWCommentPresentationData) -> [OWCommentPresentationData] {
        var existingRepliesPresentationData: [OWCommentPresentationData] = []
        for replyId in commentPresentationData.repliesIds {
            guard let replyCellVm = self.getCommentCellVm(for: replyId) else { continue }

            let reply = replyCellVm.outputs.commentVM.outputs.comment
            existingRepliesPresentationData.append(
                OWCommentPresentationData(
                    id: replyId,
                    totalRepliesCount: reply.repliesCount ?? 0,
                    repliesOffset: reply.offset ?? 0)
            )
        }
        return existingRepliesPresentationData
    }

    func getCommentCellVm(for commentId: String) -> OWCommentCellViewModel? {
        guard let comment = self.servicesProvider.commentsService().getComment(with: commentId, postId: self.postId),
              let commentUserId = comment.userId,
              let user = self.servicesProvider.usersService().getUser(with: commentUserId)
        else { return nil }

        var replyToUser: SPUser? = nil
        if let replyToCommentId = comment.parentId,
           let replyToComment = self.servicesProvider.commentsService().getComment(with: replyToCommentId, postId: self.postId),
           let replyToUserId = replyToComment.userId {
            replyToUser = self.servicesProvider.usersService().getUser(with: replyToUserId)
        }

        return OWCommentCellViewModel(data: OWCommentRequiredData(comment: comment, user: user, replyToUser: replyToUser, collapsableTextLineLimit: 4))
    }

    func cacheConversationRead(response: OWConversationReadRM) {
        if let responseComments = response.conversation?.comments {
            self.servicesProvider.commentsService().setComments(responseComments, postId: self.postId)
        }
        if let responseUsers = response.conversation?.users {
            self.servicesProvider.usersService().setUsers(responseUsers)
        }
    }
}

fileprivate extension OWConversationViewViewModel {
    func setupObservers() {
        // Subscribing to start realtime service
        viewInitialized
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }

                self.servicesProvider.realtimeService().startFetchingData(postId: self.postId)
            })
            .disposed(by: disposeBag)

        // Observable for the sort option
        let sortOptionObservable = self.servicesProvider
            .sortDictateService()
            .sortOption(perPostId: self.postId)

        // Observable for the conversation network API
        let conversationReadObservable = sortOptionObservable
            .flatMap { [weak self] sortOption -> Observable<OWConversationReadRM> in
                guard let self = self else { return .empty() }
                return self.servicesProvider
                .netwokAPI()
                .conversation
                .conversationRead(mode: sortOption, page: OWPaginationPage.first, parentId: "", offset: 0)
                .response
            }

        let conversationFetchedObservable = viewInitialized
            .flatMap { _ -> Observable<OWConversationReadRM> in
                return conversationReadObservable
                    .take(1)
            }
            .share()

        // first load comments or refresh comments
        conversationFetchedObservable
            .subscribe(onNext: { [weak self] response in
                guard let self = self else { return }

                self.cacheConversationRead(response: response)

                let commentsPresentationData = self.getCommentsPresentationData(from: response)

                self._commentsPresentationData.replaceAll(with: commentsPresentationData)
            })
            .disposed(by: disposeBag)

        // Binding to community question component
        conversationFetchedObservable
            .bind(to: communityQuestionCellViewModel.outputs.communityQuestionViewModel.inputs.conversationFetched)
            .disposed(by: disposeBag)

        // Responding to guidelines height change (for updating cell)
        cellsViewModels
            .flatMapLatest { cellsVms -> Observable<Int> in
                let sizeChangeObservable: [Observable<Int>] = cellsVms.enumerated().map { (index, vm) in
                    if case.communityGuidelines(let guidelinesCellViewModel) = vm {
                        let guidelinesVM = guidelinesCellViewModel.outputs.communityGuidelinesViewModel
                        return guidelinesVM.outputs.shouldShowViewAfterHeightChanged
                            .filter { $0 == true }
                            .map { _ in index }
                    } else {
                        return nil
                    }
                }
                .unwrap()
                return Observable.merge(sizeChangeObservable)
            }
            .delay(.milliseconds(Metrics.delayForUICellUpdate), scheduler: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] guidelinesIndex in
                self?._changeSizeAtIndex.onNext(guidelinesIndex)
            })
            .disposed(by: disposeBag)
    }
}
