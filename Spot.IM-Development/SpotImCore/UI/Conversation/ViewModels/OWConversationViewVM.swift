//
//  OWConversationViewVM.swift
//  SpotImCore
//
//  Created by Alon Haiut on 06/07/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

// Our sections is just a string as we will flat all the comments, replies, ads and everything into cells
typealias ConversationDataSourceModel = OWAnimatableSectionModel<String, OWConversationCellOption>

protocol OWConversationViewViewModelingInputs {
    var viewInitialized: PublishSubject<Void> { get }
    var willDisplayCell: PublishSubject<WillDisplayCellEvent> { get }
    var pullToRefresh: PublishSubject<Void> { get }
}

protocol OWConversationViewViewModelingOutputs {
    var shouldShowTiTleHeader: Bool { get }
    var conversationTitleHeaderViewModel: OWConversationTitleHeaderViewModeling { get }
    var articleDescriptionViewModel: OWArticleDescriptionViewModeling { get }
    var conversationSummaryViewModel: OWConversationSummaryViewModeling { get }
    var communityGuidelinesCellViewModel: OWCommunityGuidelinesCellViewModeling { get }
    var conversationDataSourceSections: Observable<[ConversationDataSourceModel]> { get }
    var performTableViewAnimation: Observable<Void> { get }
    var initialDataLoaded: Observable<Bool> { get }
    var openCommentCreation: Observable<OWCommentCreationType> { get }
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
        static let delayForPerformGuidelinesViewAnimation: Int = 500
        static let delayForPerformTableViewAnimation: Int = 10
        static let willDisplayCellThrottle: Int = 700
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

    fileprivate var _loadMoreReplies = PublishSubject<OWCommentPresentationData>()
    fileprivate var _loadMoreComments = PublishSubject<Int>()

    fileprivate lazy var _isReadOnly = BehaviorSubject<Bool>(value: conversationData.article.additionalSettings.readOnlyMode == .enable)
    fileprivate lazy var isReadOnly: Observable<Bool> = {
        return _isReadOnly
            .share(replay: 1)
    }()

    var commentCreationTap = PublishSubject<OWCommentCreationType>()
    var openCommentCreation: Observable<OWCommentCreationType> {
        return commentCreationTap
            .asObservable()
    }

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
            .asObservable()
    }

    fileprivate var topCellsOptions: Observable<[OWConversationCellOption]> {
        return Observable.combineLatest(shouldShowCommunityQuestion, shouldShowCommunityGuidelines)
            .flatMapLatest({ [weak self] showCommunityQuestion, showCommunityGuidlines -> Observable<[OWConversationCellOption]> in
                guard let self = self else { return Observable.never() }
                return Observable.just(self.getTopCells(shouldShowCommunityQuestion: showCommunityQuestion, shouldShowCommunityGuidelines: showCommunityGuidlines))
            })
            .asObservable()
    }

    // TODO - Check why when it is not lazy we are not observing cells
    fileprivate lazy var cellsViewModels: Observable<[OWConversationCellOption]> = {
        return Observable.combineLatest(topCellsOptions, commentCellsOptions)
            .startWith(([], []))
            .flatMapLatest({ [weak self] topCellsOptions, commentCellsOptions -> Observable<[OWConversationCellOption]> in
                guard let self = self else { return Observable.never() }
                if commentCellsOptions.isEmpty {
                    return Observable.just(self.getSkeletonCells())
                }
                return Observable.just(topCellsOptions + commentCellsOptions)
            })
            .share()
            .asObservable()
    }()

    fileprivate var _performTableViewAnimation = PublishSubject<Void>()
    var performTableViewAnimation: Observable<Void> {
        return _performTableViewAnimation
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
    var willDisplayCell = PublishSubject<WillDisplayCellEvent>()
    var pullToRefresh = PublishSubject<Void>()

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
                cellOptions.append(OWConversationCellOption.spacer(viewModel: OWSpacerCellViewModel(
                    id: "\(commentPresentationData.id)_spacer",
                    style: .comment
                )))
            }

            cellOptions.append(OWConversationCellOption.comment(viewModel: commentCellVM))

            let depth = commentCellVM.outputs.commentVM.outputs.comment.depth ?? 0

            let repliesToShowCount = commentPresentationData.repliesPresentation.count

            switch (repliesToShowCount, commentPresentationData.totalRepliesCount) {
            case (_, 0):
                break
            case (0, _):
                cellOptions.append(OWConversationCellOption.commentThreadActions(viewModel: OWCommentThreadActionsCellViewModel(
                    id: "\(commentPresentationData.id)_expand_only",
                    data: commentPresentationData,
                    mode: .expand,
                    depth: depth
                )))
            default:
                cellOptions.append(OWConversationCellOption.commentThreadActions(viewModel: OWCommentThreadActionsCellViewModel(
                    id: "\(commentPresentationData.id)_collapse",
                    data: commentPresentationData,
                    mode: .collapse,
                    depth: depth
                )))

                cellOptions.append(contentsOf: getCommentCells(for: commentPresentationData.repliesPresentation))

                if (repliesToShowCount < commentPresentationData.totalRepliesCount) {
                    cellOptions.append(OWConversationCellOption.commentThreadActions(viewModel: OWCommentThreadActionsCellViewModel(
                        id: "\(commentPresentationData.id)_expand",
                        data: commentPresentationData,
                        mode: .expand,
                        depth: depth
                    )))
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
    // swiftlint:disable function_body_length
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

        let conversationFetchedObservable = Observable.merge(viewInitialized, pullToRefresh)
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

                self._commentsPresentationData.removeAll()
                self._commentsPresentationData.append(contentsOf: commentsPresentationData)
            })
            .disposed(by: disposeBag)

        // Set read only mode
        conversationFetchedObservable
            .subscribe(onNext: { [weak self] response in
                guard let self = self else { return }
                var isReadOnly: Bool = response.conversation?.readOnly ?? false
                switch self.conversationData.article.additionalSettings.readOnlyMode {
                case .disable:
                    isReadOnly = false
                case .enable:
                    isReadOnly = true
                case .default:
                    break
                }
                self._isReadOnly.onNext(isReadOnly)
            })
            .disposed(by: disposeBag)

        // Binding to community question component
        conversationFetchedObservable
            .bind(to: communityQuestionCellViewModel.outputs.communityQuestionViewModel.inputs.conversationFetched)
            .disposed(by: disposeBag)

        let loadMoreRepliesReadObservable = _loadMoreReplies
            .withLatestFrom(sortOptionObservable) { (commentPresentationData, sortOption) -> (OWCommentPresentationData, OWSortOption)  in
                return (commentPresentationData, sortOption)
            }
            .flatMap { [weak self] (commentPresentationData, sortOption) -> Observable<(OWCommentPresentationData, OWConversationReadRM?)> in
                guard let self = self else { return .empty() }

                let countAfterUpdate = min(commentPresentationData.repliesPresentation.count + 5, commentPresentationData.totalRepliesCount)

                if countAfterUpdate <= commentPresentationData.repliesIds.count {
                    // no need to fetch more comments
                    return Observable.just((commentPresentationData, nil))
                }

                let currentRepliesCount = commentPresentationData.repliesIds.count
                let fetchCount = countAfterUpdate - currentRepliesCount

                return self.servicesProvider
                    .netwokAPI()
                    .conversation
                    .conversationRead(mode: sortOption, page: .next, count: fetchCount, parentId: commentPresentationData.id, offset: commentPresentationData.repliesOffset)
                    .response
                    .map { (commentPresentationData, $0) }
            }

        loadMoreRepliesReadObservable.subscribe(onNext: { [weak self] (commentPresentationData, response) in
            guard let self = self else { return }

            let existingRepliesPresentationData = self.getExistingRepliesPresentationData(for: commentPresentationData)

            // add presentation data from response
            var presentationDataFromResponse: [OWCommentPresentationData] = []
            if let response = response {
                self.cacheConversationRead(response: response)

                presentationDataFromResponse = self.getCommentsPresentationData(from: response)

                // filter existing comments
                presentationDataFromResponse = presentationDataFromResponse.filter { !commentPresentationData.repliesIds.contains($0.id) }

                // filter existing reply ids
                let newRepliesIds = (response.conversation?.comments?.map { $0.id! })?.filter { !commentPresentationData.repliesIds.contains($0) }

                // update commentPresentationData according to the response
                commentPresentationData.repliesIds.append(contentsOf: newRepliesIds ?? [])
                commentPresentationData.repliesOffset = response.conversation?.offset ?? 0
            }

            var repliesPresentation = existingRepliesPresentationData + presentationDataFromResponse

            // take required count of replies
            let countAfterUpdate = min(commentPresentationData.repliesPresentation.count + 5, commentPresentationData.totalRepliesCount)
            repliesPresentation = Array(repliesPresentation.prefix(countAfterUpdate))

            commentPresentationData.setRepliesPresentation(repliesPresentation)
            commentPresentationData.update.onNext()

        })
        .disposed(by: disposeBag)

        // fetch more comments
        let loadMoreCommentsReadObservable = _loadMoreComments
            .distinctUntilChanged()
            .withLatestFrom(sortOptionObservable) { (offset, sortOption) -> (OWSortOption, Int) in
                return (sortOption, offset)
            }
            .flatMap { [weak self] (sortOption, offset) -> Observable<OWConversationReadRM> in
                guard let self = self else { return .empty() }
                return self.servicesProvider
                .netwokAPI()
                .conversation
                .conversationRead(mode: sortOption, page: OWPaginationPage.next, parentId: "", offset: offset)
                .response
            }

        // append new comments on load more
        loadMoreCommentsReadObservable
            .subscribe(onNext: { [weak self] response in
                guard let self = self else { return }

                self.cacheConversationRead(response: response)

                var commentsPresentationData = self.getCommentsPresentationData(from: response)

                commentsPresentationData = commentsPresentationData.filter { !(self._commentsPresentationData.map { $0.id }).contains($0.id) }

                self._commentsPresentationData.append(contentsOf: commentsPresentationData)
            })
            .disposed(by: disposeBag)

        // Responding to guidelines height change (for updating cell)
        cellsViewModels
            .flatMapLatest { cellsVms -> Observable<Void> in
                let sizeChangeObservable: [Observable<Void>] = cellsVms.map { vm in
                    if case.communityGuidelines(let guidelinesCellViewModel) = vm {
                        let guidelinesVM = guidelinesCellViewModel.outputs.communityGuidelinesViewModel
                        return guidelinesVM.outputs.shouldShowViewAfterHeightChanged
                            .filter { $0 == true }
                            .voidify()
                    } else {
                        return nil
                    }
                }
                .unwrap()
                return Observable.merge(sizeChangeObservable)
            }
            .delay(.milliseconds(Metrics.delayForPerformGuidelinesViewAnimation), scheduler: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] _ in
                self?._performTableViewAnimation.onNext()
            })
            .disposed(by: disposeBag)

        // Responding to comment height change (for updating cell)
        cellsViewModels
            .flatMapLatest { cellsVms -> Observable<Void> in
                let sizeChangeObservable: [Observable<Void>] = cellsVms.map { vm in
                    if case.comment(let commentCellViewModel) = vm {
                        let commentVM = commentCellViewModel.outputs.commentVM
                        return commentVM.outputs.contentVM
                            .outputs.collapsableLabelViewModel.outputs.height
                            .voidify()
                    } else {
                        return nil
                    }
                }
                .unwrap()
                return Observable.merge(sizeChangeObservable)
            }
            .delay(.milliseconds(Metrics.delayForPerformTableViewAnimation), scheduler: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] _ in
                self?._performTableViewAnimation.onNext()
            })
            .disposed(by: disposeBag)

        // Observable of the comment cell VMs
        let commentCellsVmsObservable: Observable<[OWCommentCellViewModeling]> = cellsViewModels
            .flatMapLatest { viewModels -> Observable<[OWCommentCellViewModeling]> in
                let commentCellsVms: [OWCommentCellViewModeling] = viewModels.map { vm in
                    if case.comment(let commentCellViewModel) = vm {
                        return commentCellViewModel
                    } else {
                        return nil
                    }
                }
                .unwrap()

                 return Observable.just(commentCellsVms)
            }
            .share()

        // Responding to reply click from comment cells VMs
        commentCellsVmsObservable
            .flatMapLatest { commentCellsVms -> Observable<OWComment> in
                let replyClickOutputObservable: [Observable<OWComment>] = commentCellsVms.map { commentCellVm in
                    let commentVM = commentCellVm.outputs.commentVM
                    return commentVM.outputs.commentEngagementVM
                        .outputs.replyClickedOutput
                        .map { commentVM.outputs.comment }
                }
                return Observable.merge(replyClickOutputObservable)
            }
            .subscribe(onNext: { [weak self] comment in
                self?.commentCreationTap.onNext(.replyToComment(originComment: comment))
            })
            .disposed(by: disposeBag)

        // Update comments cells on ReadOnly mode
        Observable.combineLatest(commentCellsVmsObservable, isReadOnly) { commentCellsVms, isReadOnly -> ([OWCommentCellViewModeling], Bool) in
            return (commentCellsVms, isReadOnly)
        }
        .subscribe(onNext: { commentCellsVms, isReadOnly in
            commentCellsVms.forEach {
                $0.outputs.commentVM
                .outputs.commentEngagementVM
                .inputs.isReadOnly
                .onNext(isReadOnly)
            }
        })
        .disposed(by: disposeBag)

        // Observable of the comment action cell VMs
        let commentThreadActionsCellsVmsObservable: Observable<[OWCommentThreadActionsCellViewModeling]> = cellsViewModels
            .flatMapLatest { viewModels -> Observable<[OWCommentThreadActionsCellViewModeling]> in
                let commentThreadActionsCellsVms: [OWCommentThreadActionsCellViewModeling] = viewModels.map { vm in
                    if case.commentThreadActions(let commentThreadActionsCellViewModel) = vm {
                        return commentThreadActionsCellViewModel
                    } else {
                        return nil
                    }
                }
                    .unwrap()

                return Observable.just(commentThreadActionsCellsVms)
            }
            .share()

        // responding to thread action clicked
        commentThreadActionsCellsVmsObservable
            .flatMap { commentThreadActionsCellsVms -> Observable<(OWCommentPresentationData, OWCommentThreadActionsCellMode)> in
                let threadActionsClickObservable = commentThreadActionsCellsVms.map { commentThreadActionsCellsVm in
                    return commentThreadActionsCellsVm.outputs.commentActionsVM
                        .outputs.tapOutput
                        .map { (commentThreadActionsCellsVm.outputs.commentPresentationData, commentThreadActionsCellsVm.outputs.mode) }
                }
                return Observable.merge(threadActionsClickObservable)
            }
            .subscribe(onNext: { [weak self] commentPresentationData, mode in
                guard let self = self else { return }
                switch mode {
                case .collapse:
                    commentPresentationData.setRepliesPresentation([])
                    commentPresentationData.update.onNext()
                case .expand:
                    self._loadMoreReplies.onNext(commentPresentationData)
                }

            })
            .disposed(by: disposeBag)

        // Observe tableview will display cell to load more comments
        willDisplayCell
            .map { willDisplayCellEvent -> Int in
                return willDisplayCellEvent.indexPath.row
            }
            .withLatestFrom(_commentsPresentationData.rx_elements()) { rowIndex, presentationData -> Int? in
                guard !presentationData.isEmpty else { return nil }
                return rowIndex
            }
            .unwrap()
            .throttle(.milliseconds(Metrics.willDisplayCellThrottle), scheduler: MainScheduler.asyncInstance)
            .withLatestFrom(cellsViewModels) { rowIndex, cellsVMs in
                return (rowIndex, cellsVMs.count)
            }.subscribe(onNext: { [weak self] rowIndex, cellsCount in
                guard let self = self else { return }
                if (rowIndex > cellsCount - 5) {
                    self._loadMoreComments.onNext(self.offset)
                }
            })
            .disposed(by: disposeBag)

        // Open menu for comment and handle actions
        commentCellsVmsObservable
            .flatMap { commentCellsVms -> Observable<(OWComment, [UIRxPresenterAction])> in
                let openMenuClickObservable: [Observable<(OWComment, [UIRxPresenterAction])>] = commentCellsVms.map { commentCellVm -> Observable<(OWComment, [UIRxPresenterAction])> in
                    let commentVm = commentCellVm.outputs.commentVM
                    let commentHeaderVm = commentVm.outputs.commentHeaderVM

                    return commentHeaderVm.outputs.openMenu
                        .map { (commentVm.outputs.comment, $0) }
                }
                return Observable.merge(openMenuClickObservable)
            }
            // swiftlint:disable unused_closure_parameter
            .subscribe(onNext: { [weak self] comment, actions in
            // swiftlint:enable unused_closure_parameter
                guard let self = self else { return }
                _ = self.servicesProvider.presenterService()
                    .showMenu(actions: actions, viewableMode: self.viewableMode)
                    .subscribe(onNext: { result in
                        switch result {
                        case .completion:
                            // Do nothing
                            break
                        case .selected(let action):
                            // TODO: handle selection
                            break
                        }
                    })
                    .disposed(by: self.disposeBag)
            })
            .disposed(by: disposeBag)
    }
}
