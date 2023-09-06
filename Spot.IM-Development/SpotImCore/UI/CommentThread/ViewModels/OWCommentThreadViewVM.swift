//
//  OWCommentThreadViewVM.swift
//  SpotImCore
//
//  Created by Alon Shprung on 30/01/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

// swiftlint:disable file_length

import Foundation
import RxSwift

typealias CommentThreadDataSourceModel = OWAnimatableSectionModel<String, OWCommentThreadCellOption>

protocol OWCommentThreadViewViewModelingInputs {
    var viewInitialized: PublishSubject<Void> { get }
    var pullToRefresh: PublishSubject<Void> { get }
    var scrolledToCellIndex: PublishSubject<Int> { get }
    var changeThreadOffset: PublishSubject<CGPoint> { get }
}

protocol OWCommentThreadViewViewModelingOutputs {
    var commentThreadDataSourceSections: Observable<[CommentThreadDataSourceModel]> { get }
    var performTableViewAnimation: Observable<Void> { get }
    var openCommentCreation: Observable<OWCommentCreationTypeInternal> { get }
    var urlClickedOutput: Observable<URL> { get }
    var openProfile: Observable<URL> { get }
    var openPublisherProfile: Observable<String> { get }
    var scrollToCellIndex: Observable<Int> { get }
    var highlightCellIndex: Observable<Int> { get }
    var shouldShowError: Observable<Void> { get }
    var threadOffset: Observable<CGPoint> { get }
    var dataSourceTransition: OWViewTransition { get }
    var openReportReason: Observable<OWCommentViewModeling> { get }
}

protocol OWCommentThreadViewViewModeling {
    var inputs: OWCommentThreadViewViewModelingInputs { get }
    var outputs: OWCommentThreadViewViewModelingOutputs { get }
}

class OWCommentThreadViewViewModel: OWCommentThreadViewViewModeling, OWCommentThreadViewViewModelingInputs, OWCommentThreadViewViewModelingOutputs {
    var inputs: OWCommentThreadViewViewModelingInputs { return self }
    var outputs: OWCommentThreadViewViewModelingOutputs { return self }

    fileprivate struct Metrics {
        static let numberOfSkeletonComments: Int = 10
        static let delayForPerformTableViewAnimation: Int = 10 // ms
        static let commentCellCollapsableTextLineLimit: Int = 4
        static let delayForPerformHighlightAnimation: Int = 500 // ms
        static let delayAfterRecievingUpdatedComments: Int = 500 // ms
        static let delayBeforeReEnablingTableViewAnimation: Int = 500 // ms
    }

    fileprivate var postId: OWPostId {
        return OWManager.manager.postId ?? ""
    }

    fileprivate let commentThreadData: OWCommentThreadRequiredData

    fileprivate let servicesProvider: OWSharedServicesProviding
    fileprivate let commentPresentationDataHelper: OWCommentsPresentationDataHelperProtocol
    fileprivate let viewableMode: OWViewableMode
    fileprivate let _commentThreadData = BehaviorSubject<OWCommentThreadRequiredData?>(value: nil)
    fileprivate let disposeBag = DisposeBag()

    fileprivate lazy var _isReadOnly = BehaviorSubject<Bool>(value: commentThreadData.article.additionalSettings.readOnlyMode == .enable)
    fileprivate lazy var isReadOnly: Observable<Bool> = {
        return _isReadOnly
            .share(replay: 1)
    }()

    fileprivate lazy var cellsViewModels: Observable<[OWCommentThreadCellOption]> = {
        return _commentsPresentationData
            .rx_elements()
            .startWith([])
            .flatMapLatest({ [weak self] commentsPresentationData -> Observable<[OWCommentThreadCellOption]> in
                guard let self = self else { return Observable.empty() }

                if (commentsPresentationData.isEmpty) {
                    return Observable.just(self.getSkeletonCells())
                }

                return Observable.just(self.getCells(for: commentsPresentationData))
            })
            .scan([], accumulator: { previousCommentThreadCellsOptions, newCommentThreadCellsOptions in
                var commentsVmsMapper = [OWCommentId: OWCommentCellViewModeling]()

                previousCommentThreadCellsOptions.forEach { commentThreadCellOption in
                    switch commentThreadCellOption {
                    case .comment(let commentCellViewModel):
                        guard let commentId = commentCellViewModel.outputs.commentVM.outputs.comment.id else { return }
                        commentsVmsMapper[commentId] = commentCellViewModel
                    default:
                        break
                    }
                }

                let adjustedNewCommentCellOptions: [OWCommentThreadCellOption] = newCommentThreadCellsOptions.map { commentThreadCellOptions in
                    switch commentThreadCellOptions {
                    case .comment(let viewModel):
                        guard let commentId = viewModel.outputs.commentVM.outputs.comment.id else {
                            return commentThreadCellOptions
                        }
                        if let commentVm = commentsVmsMapper[commentId] {
                            return OWCommentThreadCellOption.comment(viewModel: commentVm)
                        } else {
                            return commentThreadCellOptions
                        }
                    default:
                        return commentThreadCellOptions
                    }
                }

                return adjustedNewCommentCellOptions
            })
            .share(replay: 1)
    }()

    var _shouldShowError = PublishSubject<Void>()
    var shouldShowError: Observable<Void> {
        return _shouldShowError
            .asObservable()
    }

    var commentThreadDataSourceSections: Observable<[CommentThreadDataSourceModel]> {
        return cellsViewModels
            .map { [weak self] items in
                guard let self = self else { return [] }
                let section = CommentThreadDataSourceModel(model: self.postId, items: items)
                return [section]
            }
    }

    fileprivate var _commentsPresentationData = OWObservableArray<OWCommentPresentationData>()

    var commentCreationTap = PublishSubject<OWCommentCreationTypeInternal>()
    var openCommentCreation: Observable<OWCommentCreationTypeInternal> {
        return commentCreationTap
            .asObservable()
    }

    fileprivate let _updateLocalComment = PublishSubject<(OWComment, OWCommentId)>()
    fileprivate let _replyToLocalComment = PublishSubject<(OWComment, OWCommentId)>()

    fileprivate let _performHighlightAnimationCellIndex = PublishSubject<Int>()
    var scrolledToCellIndex = PublishSubject<Int>()

    var scrollToCellIndex: Observable<Int> {
        _performHighlightAnimationCellIndex
            .asObserver()
    }

    var highlightCellIndex: Observable<Int> {
        return scrolledToCellIndex
            .asObserver()
    }

    fileprivate var _openProfile = PublishSubject<URL>()
    var openProfile: Observable<URL> {
        return _openProfile
            .asObservable()
    }

    fileprivate var _openPublisherProfile = PublishSubject<String>()
    var openPublisherProfile: Observable<String> {
        return _openPublisherProfile
            .asObservable()
    }

    fileprivate var _urlClick = PublishSubject<URL>()
    var urlClickedOutput: Observable<URL> {
        return _urlClick
            .asObservable()
    }

    fileprivate var deleteComment = PublishSubject<OWCommentViewModeling>()
    fileprivate var muteCommentUser = PublishSubject<OWCommentViewModeling>()

    var viewInitialized = PublishSubject<Void>()
    var pullToRefresh = PublishSubject<Void>()
    fileprivate var _loadMoreReplies = PublishSubject<OWCommentPresentationData>()

    fileprivate var _performTableViewAnimation = PublishSubject<Void>()
    var performTableViewAnimation: Observable<Void> {
        return _performTableViewAnimation
            .asObservable()
    }

    var changeThreadOffset = PublishSubject<CGPoint>()
    var threadOffset: Observable<CGPoint> {
        return changeThreadOffset
            .asObservable()
    }

    fileprivate var openReportReasonChange = PublishSubject<OWCommentViewModeling>()
    var openReportReason: Observable<OWCommentViewModeling> {
        return openReportReasonChange
            .asObservable()
    }

    var dataSourceTransition: OWViewTransition = .reload

    init (commentThreadData: OWCommentThreadRequiredData,
          servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared,
          commentPresentationDataHelper: OWCommentsPresentationDataHelperProtocol = OWCommentsPresentationDataHelper(),
          viewableMode: OWViewableMode = .independent
    ) {
        self.servicesProvider = servicesProvider
        self.commentPresentationDataHelper = commentPresentationDataHelper
        self.viewableMode = viewableMode
        self.commentThreadData = commentThreadData
        self._commentThreadData.onNext(commentThreadData)
        self.setupObservers()
    }
}

fileprivate extension OWCommentThreadViewViewModel {
    func getCells(for commentsPresentationData: [OWCommentPresentationData]) -> [OWCommentThreadCellOption] {
        var cellOptions = [OWCommentThreadCellOption]()

        for (idx, commentPresentationData) in commentsPresentationData.enumerated() {
            guard let commentCellVM = self.getCommentCellVm(for: commentPresentationData.id) else { continue }

            if (commentCellVM.outputs.commentVM.outputs.comment.depth == 0 && idx > 0) {
                cellOptions.append(OWCommentThreadCellOption.spacer(viewModel: OWSpacerCellViewModel(
                    id: "\(commentPresentationData.id)_spacer",
                    style: .comment
                )))
            }

            cellOptions.append(OWCommentThreadCellOption.comment(viewModel: commentCellVM))

            let depth = commentCellVM.outputs.commentVM.outputs.comment.depth ?? 0

            let repliesToShowCount = commentPresentationData.repliesPresentation.count

            switch (repliesToShowCount, commentPresentationData.totalRepliesCount) {
            case (_, 0):
                break
            case (0, _):
                cellOptions.append(OWCommentThreadCellOption.commentThreadActions(viewModel: OWCommentThreadActionsCellViewModel(
                    id: "\(commentPresentationData.id)_expand_only",
                    data: commentPresentationData,
                    mode: .expand,
                    depth: depth
                )))
            default:
                cellOptions.append(OWCommentThreadCellOption.commentThreadActions(viewModel: OWCommentThreadActionsCellViewModel(
                    id: "\(commentPresentationData.id)_collapse",
                    data: commentPresentationData,
                    mode: .collapse,
                    depth: depth
                )))

                cellOptions.append(contentsOf: getCells(for: commentPresentationData.repliesPresentation))

                if (repliesToShowCount < commentPresentationData.totalRepliesCount) {
                    cellOptions.append(OWCommentThreadCellOption.commentThreadActions(viewModel: OWCommentThreadActionsCellViewModel(
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

    func getSkeletonCells() -> [OWCommentThreadCellOption] {
        var cellOptions = [OWCommentThreadCellOption]()
        let numberOfComments = Metrics.numberOfSkeletonComments
        let skeletonCellVMs = (0 ..< numberOfComments).map { index in
            OWCommentSkeletonShimmeringCellViewModel(depth: index > 0 ? 1 : 0)
        }
        let skeletonCells = skeletonCellVMs.map { OWCommentThreadCellOption.commentSkeletonShimmering(viewModel: $0) }
        cellOptions.append(contentsOf: skeletonCells)

        return cellOptions
    }

    func getCommentsPresentationData(of comments: [OWComment]) -> [OWCommentPresentationData] {
        var commentsPresentationData = [OWCommentPresentationData]()

        for comment in comments {
            guard let commentId = comment.id else { continue }

            let commentPresentationData = OWCommentPresentationData(
                id: commentId,
                repliesIds: comment.replies?.map { $0.id }.unwrap() ?? [],
                totalRepliesCount: comment.repliesCount ?? 0,
                repliesOffset: comment.offset ?? 0,
                repliesPresentation: getCommentsPresentationData(of: comment.replies ?? [])
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
                    repliesIds: reply.replies?.map { $0.id }.unwrap() ?? [],
                    totalRepliesCount: reply.repliesCount ?? 0,
                    repliesOffset: reply.offset ?? 0,
                    repliesPresentation: []
                )
            )
        }
        return existingRepliesPresentationData
    }

    func getCommentCellVm(for commentId: String) -> OWCommentCellViewModel? {
        guard let comment = self.servicesProvider.commentsService().get(commentId: commentId, postId: self.postId),
              let commentUserId = comment.userId,
              let user = self.servicesProvider.usersService().get(userId: commentUserId)
        else { return nil }

        var replyToUser: SPUser? = nil
        if let replyToCommentId = comment.parentId,
           let replyToComment = self.servicesProvider.commentsService().get(commentId: replyToCommentId, postId: self.postId),
           let replyToUserId = replyToComment.userId {
            replyToUser = self.servicesProvider.usersService().get(userId: replyToUserId)
        }

        let reportedCommentsService = self.servicesProvider.reportedCommentsService()
        let commentWithUpdatedStatus = reportedCommentsService.getUpdatedComment(for: comment, postId: self.postId)

        return OWCommentCellViewModel(data: OWCommentRequiredData(
            comment: commentWithUpdatedStatus,
            user: user,
            replyToUser: replyToUser,
            collapsableTextLineLimit: Metrics.commentCellCollapsableTextLineLimit,
            section: self.commentThreadData.article.additionalSettings.section
        ))
    }

    func cacheConversationRead(response: OWConversationReadRM) {
        if let responseComments = response.conversation?.comments {
            self.servicesProvider.commentsService().set(comments: responseComments, postId: self.postId)
        }
        if let responseUsers = response.conversation?.users {
            self.servicesProvider.usersService().set(users: responseUsers)
        }
    }
}

fileprivate extension OWCommentThreadViewViewModel {
    // swiftlint:disable function_body_length
    func setupObservers() {
        // Observable for the conversation network API
        let initialConversationThreadReadObservable = _commentThreadData
            .unwrap()
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.dataSourceTransition = .reload // Block animations in the table view
            })
            .flatMap { [weak self] data -> Observable<Event<OWConversationReadRM>> in
                guard let self = self else { return .empty() }
                return self.servicesProvider
                .netwokAPI()
                .conversation
                .conversationRead(mode: .newest, page: OWPaginationPage.first, childCount: 5, messageId: data.commentId)
                .response
                .materialize()
        }

        let commentThreadFetchedObservable = Observable.merge(viewInitialized, pullToRefresh)
            .flatMap { _ -> Observable<Event<OWConversationReadRM>> in
                return initialConversationThreadReadObservable
            }
            .map { [weak self] event -> OWConversationReadRM? in
                guard let self = self else { return nil }
                switch event {
                case .next(let conversationRead):
                    // TODO: Clear any RX variables which affect error state in the View layer (like _shouldShowError).
                    return conversationRead
                case .error(_):
                    // TODO: handle error - update the UI state for showing error in the View layer
                    self._shouldShowError.onNext()
                    return nil
                default:
                    return nil
                }
            }
            .unwrap()
            .share()

        // Set read only mode
        commentThreadFetchedObservable
            .subscribe(onNext: { [weak self] response in
                guard let self = self else { return }
                var isReadOnly: Bool = response.conversation?.readOnly ?? false
                switch self.commentThreadData.article.additionalSettings.readOnlyMode {
                case .disable:
                    isReadOnly = false
                case .enable:
                    isReadOnly = true
                case .server:
                    break
                }
                self._isReadOnly.onNext(isReadOnly)
            })
            .disposed(by: disposeBag)

        // first load comments or refresh comments
        commentThreadFetchedObservable
            .subscribe(onNext: { [weak self] response in
                guard let self = self else { return }

                // Should not be empty
                guard let comments = response.conversation?.comments,
                      !comments.isEmpty else {
                    self._shouldShowError.onNext()
                    return
                }

                self.cacheConversationRead(response: response)

                if let responseComments = response.conversation?.comments {
                    let commentsPresentationData = self.getCommentsPresentationData(of: responseComments)

                    self._commentsPresentationData.replaceAll(with: commentsPresentationData)
                }
            })
            .disposed(by: disposeBag)

        // Re-enabling animations in the pre conversation table view
        commentThreadFetchedObservable
            .delay(.milliseconds(Metrics.delayBeforeReEnablingTableViewAnimation), scheduler: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.dataSourceTransition = .animated
            })
            .disposed(by: disposeBag)

        let loadMoreRepliesReadObservable = _loadMoreReplies
            .flatMap { [weak self] commentPresentationData -> Observable<(OWCommentPresentationData, Event<OWConversationReadRM>?)> in
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
                    .conversationRead(mode: .best, page: .next, count: fetchCount, parentId: commentPresentationData.id, offset: commentPresentationData.repliesOffset)
                    .response
                    .materialize()
                    .map { (commentPresentationData, $0) }
            }

        let loadMoreRepliesReadUpdated = loadMoreRepliesReadObservable
            .map { [weak self] (commentPresentationData, event) -> (OWCommentPresentationData, OWConversationReadRM?)? in
                guard let self = self else { return nil }
                guard event != nil else {
                    // We didn't have to fetch new data - the event is nil
                    return (commentPresentationData, nil)
                }

                switch event {
                case .next(let conversationRead):
                    // TODO: Clear any RX variables which affect error state in the View layer (like _shouldShowError).
                    return (commentPresentationData, conversationRead)
                case .error(_):
                    // TODO: handle error - update the UI state for showing error in the View layer
                    self._shouldShowError.onNext()
                    return nil
                default:
                    return nil
                }
            }
            .unwrap()

        loadMoreRepliesReadUpdated
            .subscribe(onNext: { [weak self] (commentPresentationData, response) in
                guard let self = self else { return }

                let existingRepliesPresentationData = self.getExistingRepliesPresentationData(for: commentPresentationData)

                // add presentation data from response
                var presentationDataFromResponse: [OWCommentPresentationData] = []
                if let response = response {
                    self.cacheConversationRead(response: response)

                    if let responseComments = response.conversation?.comments {
                        presentationDataFromResponse = self.getCommentsPresentationData(of: responseComments)
                    }

                    // filter existing comments
                    presentationDataFromResponse = presentationDataFromResponse.filter { !commentPresentationData.repliesIds.contains($0.id) }

                    // filter existing reply ids
                    let newRepliesIds = (response.conversation?.comments?.map { $0.id }.unwrap())?.filter { !commentPresentationData.repliesIds.contains($0) }

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
            .share(replay: 1)

        // Responding to comments which are just reported
        let reportService = servicesProvider.reportedCommentsService()
        reportService.commentJustReported
            .withLatestFrom(commentCellsVmsObservable) {
                ($0, $1)
            }
            .flatMap { commentId, commentCellVMs -> Observable<(OWCommentId, OWCommentViewModeling)> in
                // 1. Find if such comment VM exist for this comment ID
                guard let commentCellVM = commentCellVMs.first(where: { $0.outputs.commentVM.outputs.comment.id == commentId }) else {
                    return .empty()
                }
                return Observable.just((commentId, commentCellVM.outputs.commentVM))
            }
            .map { [weak self] commentId, commentVm -> (OWComment, OWCommentViewModeling)? in
                // 2. Get updated comment from comments service
                guard let self = self else { return nil }
                if let updatedComment = self.servicesProvider
                    .commentsService()
                    .get(commentId: commentId, postId: self.postId) {
                    return (updatedComment, commentVm)
                } else {
                    return nil
                }
            }
            .unwrap()
            .observe(on: MainScheduler.instance)
            .do(onNext: { comment, commentVM in
                // 3. Update report locally
                commentVM.inputs.update(comment: comment)
            })
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                // 4. Update table view
                self._performTableViewAnimation.onNext()
            })
            .disposed(by: disposeBag)

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
            .do(onNext: { [weak self] comment in
                self?.sendEvent(for: .replyClicked(replyToCommentId: comment.id ?? ""))
            })
            .subscribe(onNext: { [weak self] comment in
                guard let self = self else { return }
                self.commentCreationTap.onNext(.replyToComment(originComment: comment))
            })
            .disposed(by: disposeBag)

        // Responding to share url from comment cells VMs
        commentCellsVmsObservable
            .flatMapLatest { commentCellsVms -> Observable<(URL, OWCommentViewModeling)> in
                let shareClickOutputObservable: [Observable<(URL, OWCommentViewModeling)>] = commentCellsVms.map { commentCellVm in
                    let commentVM = commentCellVm.outputs.commentVM
                    return commentVM.outputs.commentEngagementVM
                        .outputs.shareCommentUrl
                        .map { ($0, commentVM) }
                }
                return Observable.merge(shareClickOutputObservable)
            }
            .observe(on: MainScheduler.instance)
            .do(onNext: { [weak self] _, commentVm in
                self?.sendEvent(for: .commentShareClicked(commentId: commentVm.outputs.comment.id ?? ""))
            })
            .flatMap { [weak self] shareUrl, _ -> Observable<OWRxPresenterResponseType> in
                guard let self = self else { return .empty() }
                return self.servicesProvider.presenterService()
                    .showActivity(activityItems: [shareUrl], applicationActivities: nil, viewableMode: self.viewableMode)

            }
            .subscribe { result in
                switch result {
                case .completion:
                    // Do nothing
                    break
                case .selected:
                    // Do nothing
                    break
                }
            }
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
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] commentPresentationData, mode in
                guard let self = self else { return }
                switch mode {
                case .collapse:
                    self.sendEvent(for: .hideMoreRepliesClicked(commentId: commentPresentationData.id))
                    commentPresentationData.setRepliesPresentation([])
                    commentPresentationData.update.onNext()
                case .expand:
                    self.sendEvent(for: .loadMoreRepliesClicked(commentId: commentPresentationData.id))
                    self._loadMoreReplies.onNext(commentPresentationData)
                }

            })
            .disposed(by: disposeBag)

        // Responding to comment avatar click
        commentCellsVmsObservable
            .flatMapLatest { commentCellsVms -> Observable<(URL, OWUserProfileType, String)> in
                let avatarClickOutputObservable: [Observable<(URL, OWUserProfileType, String)>] = commentCellsVms.map { commentCellVm in
                    let avatarVM = commentCellVm.outputs.commentVM.outputs.commentHeaderVM.outputs.avatarVM
                    return avatarVM.outputs.openProfile
                        .map { url, type in
                            return (url, type, commentCellVm.outputs.commentVM.outputs.comment.userId ?? "")
                        }
                }
                return Observable.merge(avatarClickOutputObservable)
            }
            .subscribe(onNext: { [weak self] url, type, userId in
                self?._openProfile.onNext(url)
                switch type {
                case .currentUser: self?.sendEvent(for: .myProfileClicked(source: .comment))
                case .otherUser: self?.sendEvent(for: .userProfileClicked(userId: userId))
                }
            })
            .disposed(by: disposeBag)

        commentCellsVmsObservable
            .flatMapLatest { commentCellsVms -> Observable<String> in
                let commentOpenPublisherProfileOutput: [Observable<String>] = commentCellsVms.map { commentCellVm in
                    let avatarVM = commentCellVm.outputs.commentVM.outputs.commentHeaderVM.outputs.avatarVM
                    return avatarVM.outputs.openPublisherProfile
                }
                return Observable.merge(commentOpenPublisherProfileOutput)
            }
            .subscribe(onNext: { [weak self] id in
                self?._openPublisherProfile.onNext(id)
            })
            .disposed(by: disposeBag)

        // Subscribe to URL click in comment text
        commentCellsVmsObservable
            .flatMapLatest { commentCellsVms -> Observable<URL> in
                let urlClickObservable: [Observable<URL>] = commentCellsVms.map { commentCellVm -> Observable<URL> in
                    let commentTextVm = commentCellVm.outputs.commentVM.outputs.contentVM.outputs.collapsableLabelViewModel

                    return commentTextVm.outputs.urlClickedOutput
                }
                return Observable.merge(urlClickObservable)
            }
            .subscribe(onNext: { [weak self] url in
                self?._urlClick.onNext(url)
            })
            .disposed(by: disposeBag)

        // Observe on rank click
        commentCellsVmsObservable
            .flatMap { commentCellsVms -> Observable<(OWCommentId, SPRankChange)> in
                let rankClickObservable: [Observable<(OWCommentId, SPRankChange)>] = commentCellsVms.map { commentCellVm -> Observable<(OWCommentId, SPRankChange)> in
                    let commentRankVm = commentCellVm.outputs.commentVM.outputs.commentEngagementVM.outputs.votingVM

                    return commentRankVm.outputs.rankChanged
                        .map { (commentCellVm.outputs.commentVM.outputs.comment.id ?? "", $0) }
                }
                return Observable.merge(rankClickObservable)
            }
            .subscribe(onNext: { [weak self] commentId, rank in
                guard let self = self,
                      let eventType = rank.analyticsEventType(commentId: commentId)
                else { return }
                self.sendEvent(for: eventType)
            })
            .disposed(by: disposeBag)

        // Observe on read more click
        commentCellsVmsObservable
            .flatMap { commentCellsVms -> Observable<OWCommentId> in
                let readMoreClickObservable: [Observable<OWCommentId>] = commentCellsVms.map { commentCellVm -> Observable<OWCommentId> in
                    let commentTextVm = commentCellVm.outputs.commentVM.outputs.contentVM.outputs.collapsableLabelViewModel

                    return commentTextVm.outputs.readMoreTap
                        .map { commentCellVm.outputs.commentVM.outputs.comment.id ?? "" }
                }
                return Observable.merge(readMoreClickObservable)
            }
            .subscribe(onNext: { [weak self] commentId in
                self?.sendEvent(for: .commentReadMoreClicked(commentId: commentId))
            })
            .disposed(by: disposeBag)

        // perform highlight animation for selected comment id
        cellsViewModels
            .map { [weak self] cellsViewModels -> Int? in
                guard let self = self else { return nil }
                let commentIndex: Int? = cellsViewModels.firstIndex { vm in
                    if case.comment(let commentCellViewModel) = vm {
                        return commentCellViewModel.outputs.id == self.commentThreadData.commentId
                    } else {
                        return false
                    }
                }
                return commentIndex
            }
            .unwrap()
            .delay(.milliseconds(Metrics.delayForPerformHighlightAnimation), scheduler: ConcurrentDispatchQueueScheduler(qos: .userInteractive))
            .take(1)
            .subscribe(onNext: { [weak self] index in
                self?._performHighlightAnimationCellIndex.onNext(index)
            })
            .disposed(by: disposeBag)

        // error alert
        shouldShowError
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                let actions = [OWRxPresenterAction(title: OWLocalizationManager.shared.localizedString(key: "OK"), type: OWEmptyMenu.ok)]
                self.servicesProvider.presenterService()
                    .showAlert(
                        title: OWLocalizationManager.shared.localizedString(key: "Whoops! Looks like we’re\nexperiencing some\nconnectivity issues."),
                        message: "",
                        actions: actions,
                        viewableMode: self.viewableMode
                    )
                    .subscribe(onNext: { result in
                        switch result {
                        case .completion:
                            // Do nothing
                            break
                        case .selected:
                            // TODO: handle selection
                            break
                        }
                    })
                    .disposed(by: self.disposeBag)
            })
            .disposed(by: disposeBag)

        // Open menu for comment and handle actions
        commentCellsVmsObservable
            .flatMapLatest { commentCellsVms -> Observable<([OWRxPresenterAction], OWUISource, OWCommentViewModeling)> in
                let openMenuClickObservable = commentCellsVms.map { commentCellVm -> Observable<([OWRxPresenterAction], OWUISource, OWCommentViewModeling)> in
                    let commentVm = commentCellVm.outputs.commentVM
                    let commentHeaderVm = commentVm.outputs.commentHeaderVM

                    return commentHeaderVm.outputs.openMenu
                        .map { ($0.0, $0.1, commentVm) }
                }
                return Observable.merge(openMenuClickObservable)
            }
            .do(onNext: { [weak self] (_, _, commentVm) in
                self?.sendEvent(for: .commentMenuClicked(commentId: commentVm.outputs.comment.id ?? ""))
            })
            .observe(on: MainScheduler.instance)
            .flatMapLatest { [weak self] (actions, sender, commentVm) -> Observable<(OWRxPresenterResponseType, OWCommentViewModeling)> in
                guard let self = self else { return .empty()}
                return self.servicesProvider.presenterService()
                    .showMenu(actions: actions, sender: sender, viewableMode: self.viewableMode)
                    .map { ($0, commentVm) }
            }
            .subscribe(onNext: { [weak self] result, commentVm in
                guard let self = self else { return }
                switch result {
                case .completion:
                    self.sendEvent(for: .commentMenuClosed(commentId: commentVm.outputs.comment.id ?? ""))
                case .selected(action: let action):
                    switch (action.type) {
                    case OWCommentOptionsMenu.reportComment:
                        self.sendEvent(for: .commentMenuReportClicked(commentId: commentVm.outputs.comment.id ?? ""))
                        self.openReportReasonChange.onNext(commentVm)
                    case OWCommentOptionsMenu.deleteComment:
                        self.sendEvent(for: .commentMenuDeleteClicked(commentId: commentVm.outputs.comment.id ?? ""))
                        self.deleteComment.onNext(commentVm)
                    case OWCommentOptionsMenu.editComment:
                        self.sendEvent(for: .commentMenuEditClicked(commentId: commentVm.outputs.comment.id ?? ""))
                        self.commentCreationTap.onNext(.edit(comment: commentVm.outputs.comment))
                    case OWCommentOptionsMenu.muteUser:
                        self.sendEvent(for: .commentMenuMuteClicked(commentId: commentVm.outputs.comment.id ?? ""))
                        self.muteCommentUser.onNext(commentVm)
                    default:
                        return
                    }
                }
            })
            .disposed(by: disposeBag)

        let commentDeletedLocallyObservable = deleteComment
            .asObservable()
            .flatMap { [weak self] commentVm -> Observable<(OWRxPresenterResponseType, OWCommentViewModeling)> in
                guard let self = self else { return .empty() }
                let actions = [
                    OWRxPresenterAction(title: OWLocalizationManager.shared.localizedString(key: "Delete"), type: OWCommentDeleteAlert.delete, style: .destructive),
                    OWRxPresenterAction(title: OWLocalizationManager.shared.localizedString(key: "Cancel"), type: OWCommentDeleteAlert.cancel, style: .cancel)
                ]
                return self.servicesProvider.presenterService()
                    .showAlert(
                        title: OWLocalizationManager.shared.localizedString(key: "Delete Comment"),
                        message: OWLocalizationManager.shared.localizedString(key: "Do you really want to delete this comment?"),
                        actions: actions,
                        viewableMode: self.viewableMode
                    ).map { ($0, commentVm) }
            }
            .map { result, commentVm -> Bool in
                switch result {
                case .completion:
                    return false
                case .selected(let action):
                    switch action.type {
                    case OWCommentDeleteAlert.delete:
                        self.sendEvent(for: .commentMenuConfirmDeleteClicked(commentId: commentVm.outputs.comment.id ?? ""))
                        return true
                    default:
                        return false
                    }
                }
            }
            .filter { $0 }
            .withLatestFrom(deleteComment)
            .map { commentVm -> (OWCommentViewModeling, OWComment) in
                var updatedComment = commentVm.outputs.comment
                updatedComment.setIsDeleted(true)
                return (commentVm, updatedComment)
            }
            .do(onNext: { [weak self] _, updatedComment in
                guard let self = self else { return }
                self.servicesProvider
                    .commentsService()
                    .set(comments: [updatedComment], postId: self.postId)
            })
            .observe(on: MainScheduler.instance)
            .do(onNext: { [weak self] commentVm, updatedComment in
                guard let self = self else { return }
                commentVm.inputs.update(comment: updatedComment)
                self._performTableViewAnimation.onNext()
            })
            .map { $0.0 }

        // Deleting comment from network
        commentDeletedLocallyObservable
            .observe(on: MainScheduler.asyncInstance)
            .flatMap { [weak self] commentVm -> Observable<Event<OWCommentDelete>> in
                let comment = commentVm.outputs.comment
                guard let self = self,
                      let commentId = comment.id
                else { return .empty() }
                return self.servicesProvider
                    .netwokAPI()
                    .conversation
                    .commentDelete(id: commentId, parentId: comment.parentId)
                    .response
                    .materialize()
            }
            .map { event -> OWCommentDelete? in
                switch event {
                case .next(let commentDelete):
                    // TODO: Clear any RX variables which affect error state in the View layer (like _shouldShowError).
                    return commentDelete
                case .error(_):
                    // TODO: handle error - update something like _shouldShowError RX variable which affect the UI state for showing error in the View layer
                    return nil
                default:
                    return nil
                }
            }
            .unwrap()
            .subscribe(onNext: { _ in
                // successfully deleted
            })
            .disposed(by: disposeBag)

        let muteUserObservable = muteCommentUser
            .asObservable()
            .flatMap { [weak self] _ -> Observable<OWRxPresenterResponseType> in
                guard let self = self else { return .empty() }
                let actions = [
                    OWRxPresenterAction(title: OWLocalizationManager.shared.localizedString(key: "Mute"), type: OWCommentUserMuteAlert.mute, style: .destructive),
                    OWRxPresenterAction(title: OWLocalizationManager.shared.localizedString(key: "Cancel"), type: OWCommentUserMuteAlert.cancel, style: .cancel)
                ]
                return self.servicesProvider.presenterService()
                    .showAlert(
                        title: OWLocalizationManager.shared.localizedString(key: "Mute User"),
                        message: OWLocalizationManager.shared.localizedString(key: "MuteUserMessage"),
                        actions: actions,
                        viewableMode: self.viewableMode
                    )
            }
            .map { result -> Bool in
                switch result {
                case .completion:
                    return false
                case .selected(let action):
                    switch action.type {
                    case OWCommentUserMuteAlert.mute:
                        return true
                    default:
                        return false
                    }
                }
            }
            .filter { $0 }
            .withLatestFrom(muteCommentUser)
            .map { $0.outputs.comment.userId }
            .unwrap()
            .share()

        self.servicesProvider.commentUpdaterService()
            .getUpdatedComments(for: postId)
            .flatMap { updateType -> Observable<OWCommentUpdateType> in
                // Making sure comment cells are visible
                return commentCellsVmsObservable
                    .filter { !$0.isEmpty }
                    .take(1)
                    .map { _ in updateType }
            }
            .delay(.milliseconds(Metrics.delayAfterRecievingUpdatedComments), scheduler: ConcurrentDispatchQueueScheduler(qos: .userInteractive))
            .subscribe(onNext: { [weak self] updateType in
                guard let self = self else { return }
                switch updateType {
                case .insert:
                    // Not relevant in comment thread
                    break
                case let .update(commentId, withComment):
                    self._updateLocalComment.onNext((withComment, commentId))
                case let .insertReply(comment, toCommentId):
                    self._replyToLocalComment.onNext((comment, toCommentId))
                }
            })
            .disposed(by: disposeBag)

        _updateLocalComment
            .withLatestFrom(commentCellsVmsObservable) { ($0.0, $0.1, $1) }
            .map { comment, commentId, commentCellsVms -> (OWComment, OWCommentId, [OWCommentCellViewModeling]) in
                var updatedComment = comment
                updatedComment.setIsEdited(true)
                return (updatedComment, commentId, commentCellsVms)
            }
            .do(onNext: { [weak self] comment, _, _ in
                guard let self = self else { return }
                self.servicesProvider
                    .commentsService()
                    .set(comments: [comment], postId: self.postId)
            })
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { comment, commentId, commentCellsVms in
                if let commentCellVm = commentCellsVms.first(where: { $0.outputs.commentVM.outputs.comment.id == commentId }) {
                    commentCellVm.outputs.commentVM.inputs.update(comment: comment)
                    self._performTableViewAnimation.onNext()
                }
            })
            .disposed(by: disposeBag)

        _replyToLocalComment
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] comment, parentCommentId in
                guard let self = self,
                      let commentId = comment.id,
                      let parentCommentPresentationData = self.commentPresentationDataHelper.findVisibleCommentPresentationData(
                        with: parentCommentId,
                        in: Array(self._commentsPresentationData)
                      )
                else { return }
                guard self.commentPresentationDataHelper.findVisibleCommentPresentationData(with: commentId, in: Array(self._commentsPresentationData)) == nil else {
                    // making sure we are not adding an existing reply
                    return
                }
                let newCommentPresentationData = OWCommentPresentationData(id: commentId)
                let existingRepliesPresentationData: [OWCommentPresentationData]
                if (parentCommentPresentationData.repliesPresentation.count == 0) {
                    existingRepliesPresentationData = Array(self.getExistingRepliesPresentationData(for: parentCommentPresentationData).prefix(4))
                } else {
                    existingRepliesPresentationData = parentCommentPresentationData.repliesPresentation
                }
                parentCommentPresentationData.repliesIds.insert(commentId, at: 0)
                parentCommentPresentationData.setTotalRepliesCount(parentCommentPresentationData.totalRepliesCount + 1)
                parentCommentPresentationData.setRepliesPresentation([newCommentPresentationData] + existingRepliesPresentationData)
                parentCommentPresentationData.update.onNext()
            })
            .disposed(by: disposeBag)

        // Handling mute user from network
        muteUserObservable
            .flatMap { [weak self] userId -> Observable<Event<EmptyDecodable>> in
                guard let self = self else { return .empty() }
                return self.servicesProvider
                    .netwokAPI()
                    .user
                    .mute(userId: userId)
                    .response
                    .materialize()
            }
            .map { event -> Bool in
                switch event {
                case .next:
                    // TODO: Clear any RX variables which affect error state in the View layer (like _shouldShowError).
                    return true
                case .error(_):
                    // TODO: handle error - update something like _shouldShowError RX variable which affect the UI state for showing error in the View layer
                    return false
                default:
                    return false
                }
            }
            .filter { $0 }
            .subscribe(onNext: { _ in
                // successfully muted
            })
            .disposed(by: disposeBag)

        // Handling muting comments "locally" of a muted user
        muteUserObservable
            .withLatestFrom(commentCellsVmsObservable) { userId, commentCellsVms -> (String, [OWCommentCellViewModeling]) in
                return (userId, commentCellsVms)
            }
            .map { [weak self] userId, commentCellsVms -> (SPUser, [OWCommentCellViewModeling])? in
                guard let self = self,
                      let user = self.servicesProvider.usersService().get(userId: userId)
                else { return nil }

                user.isMuted = true
                return (user, commentCellsVms)

            }
            .unwrap()
            .do(onNext: { [weak self] user, _ in
                guard let self = self else { return }
                self.servicesProvider
                    .usersService()
                    .set(users: [user])
            })
            .map { user, commentCellsVms -> (SPUser, [OWCommentViewModeling]) in
                let userCommentCells = commentCellsVms.filter { $0.outputs.commentVM.outputs.comment.userId == user.id }
                return (user, userCommentCells.map { $0.outputs.commentVM })
            }
            .do(onNext: { user, mutedUserCommentCellsVms in
                mutedUserCommentCellsVms.forEach {
                    $0.inputs.update(user: user)
                }
            })
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self._performTableViewAnimation.onNext()
            })
            .disposed(by: disposeBag)
    }

    func event(for eventType: OWAnalyticEventType) -> OWAnalyticEvent {
        return servicesProvider
            .analyticsEventCreatorService()
            .analyticsEvent(
                for: eventType,
                articleUrl: commentThreadData.article.url.absoluteString,
                layoutStyle: OWLayoutStyle(from: commentThreadData.presentationalStyle),
                component: .commentCreation)
    }

    func sendEvent(for eventType: OWAnalyticEventType) {
        let event = event(for: eventType)
        servicesProvider
            .analyticsService()
            .sendAnalyticEvents(events: [event])
    }
}
