//
//  OWCommentThreadViewVM.swift
//  SpotImCore
//
//  Created by Alon Shprung on 30/01/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

typealias CommentThreadDataSourceModel = OWAnimatableSectionModel<String, OWCommentThreadCellOption>

protocol OWCommentThreadViewViewModelingInputs {
    var viewInitialized: PublishSubject<Void> { get }
    var pullToRefresh: PublishSubject<Void> { get }
}

protocol OWCommentThreadViewViewModelingOutputs {
    var commentThreadDataSourceSections: Observable<[CommentThreadDataSourceModel]> { get }
    var performTableViewAnimation: Observable<Void> { get }
    var openCommentCreation: Observable<OWCommentCreationType> { get }
}

protocol OWCommentThreadViewViewModeling {
    var inputs: OWCommentThreadViewViewModelingInputs { get }
    var outputs: OWCommentThreadViewViewModelingOutputs { get }
}

class OWCommentThreadViewViewModel: OWCommentThreadViewViewModeling, OWCommentThreadViewViewModelingInputs, OWCommentThreadViewViewModelingOutputs {
    var inputs: OWCommentThreadViewViewModelingInputs { return self }
    var outputs: OWCommentThreadViewViewModelingOutputs { return self }

    fileprivate struct Metrics {
        static let numberOfCommentsInSkeleton: Int = 4
        static let delayForPerformTableViewAnimation: Int = 10
    }

    fileprivate var postId: OWPostId {
        return OWManager.manager.postId ?? ""
    }

    fileprivate let commentThreadData: OWCommentThreadRequiredData

    fileprivate let servicesProvider: OWSharedServicesProviding
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
            .flatMapLatest({ [weak self] commentsPresentationData -> Observable<[OWCommentThreadCellOption]> in
                guard let self = self else { return Observable.never() }

                if (commentsPresentationData.isEmpty) {
                    return Observable.just(self.getSkeletonCells())
                }

                return Observable.just(self.getCells(for: commentsPresentationData))
            })
            .share()
            .asObservable()
    }()

    fileprivate var _commentsPresentationData = OWObservableArray<OWCommentPresentationData>()

    var commentCreationTap = PublishSubject<OWCommentCreationType>()
    var openCommentCreation: Observable<OWCommentCreationType> {
        return commentCreationTap
            .asObservable()
    }

    var commentThreadDataSourceSections: Observable<[CommentThreadDataSourceModel]> {
        return cellsViewModels
            .map { items in
                // TODO: We might decide to work with few sections in the future.
                // Current implementation will be one section.
                // The String can be the `postId` which we will add once the VM will be ready.
                let section = CommentThreadDataSourceModel(model: "postId", items: items)
                return [section]
            }
    }

    var viewInitialized = PublishSubject<Void>()
    var pullToRefresh = PublishSubject<Void>()
    fileprivate var _loadMoreReplies = PublishSubject<OWCommentPresentationData>()

    var offset = 0

    fileprivate var _performTableViewAnimation = PublishSubject<Void>()
    var performTableViewAnimation: Observable<Void> {
        return _performTableViewAnimation
            .asObservable()
    }

    init (commentThreadData: OWCommentThreadRequiredData, servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared, viewableMode: OWViewableMode = .independent) {
        self.servicesProvider = servicesProvider
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
        let numberOfComments = Metrics.numberOfCommentsInSkeleton
        let skeletonCellVMs = (0 ..< numberOfComments).map { index in
            OWCommentSkeletonShimmeringCellViewModel(depth: index > 0 ? 1 : 0)
        }
        let skeletonCells = skeletonCellVMs.map { OWCommentThreadCellOption.commentSkeletonShimmering(viewModel: $0) }
        cellOptions.append(contentsOf: skeletonCells)

        return cellOptions
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

fileprivate extension OWCommentThreadViewViewModel {
    // swiftlint:disable function_body_length
    func setupObservers() {
        // Observable for the conversation network API
        let initialConversationThreadReadObservable = _commentThreadData
            .unwrap()
            .flatMap { [weak self] data -> Observable<OWConversationReadRM> in
                guard let self = self else { return .empty() }
                return self.servicesProvider
                .netwokAPI()
                .conversation
                .conversationRead(mode: .newest, page: OWPaginationPage.first, childCount: 5, messageId: data.commentId)
                .response
        }

        let commentThreadFetchedObservable = Observable.merge(viewInitialized, pullToRefresh)
            .flatMap { _ -> Observable<OWConversationReadRM> in
                return initialConversationThreadReadObservable
            }
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
                case .default:
                    break
                }
                self._isReadOnly.onNext(isReadOnly)
            })
            .disposed(by: disposeBag)

        // first load comments or refresh comments
        commentThreadFetchedObservable
            .subscribe(onNext: { [weak self] response in
                guard let self = self else { return }

                self.cacheConversationRead(response: response)

                let commentsPresentationData = self.getCommentsPresentationData(from: response)

                self._commentsPresentationData.replaceAll(with: commentsPresentationData)
            })
            .disposed(by: disposeBag)

        let loadMoreRepliesReadObservable = _loadMoreReplies
            .flatMap { [weak self] commentPresentationData -> Observable<(OWCommentPresentationData, OWConversationReadRM?)> in
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
            .flatMap { commentCellsVms -> Observable<OWComment> in
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

        // Observable of the comment collapse cell VMs
        let commentCollapseCellsVmsObservable: Observable<[OWCommentThreadActionsCellViewModeling]> = cellsViewModels
            .flatMapLatest { viewModels -> Observable<[OWCommentThreadActionsCellViewModeling]> in
                let commentThreadCollapseCellsVms: [OWCommentThreadActionsCellViewModeling] = viewModels.map { vm in
                    if case.commentThreadActions(let commentThreadCollapseCellViewModel) = vm {
                        return commentThreadCollapseCellViewModel
                    } else {
                        return nil
                    }
                }
                    .unwrap()

                return Observable.just(commentThreadCollapseCellsVms)
            }
            .share()

        // responding to thread action clicked
        commentCollapseCellsVmsObservable
            .flatMap { commentCollapseCellsVms -> Observable<(OWCommentPresentationData, OWCommentThreadActionsCellMode)> in
                let collapseClickObservable: [Observable<(OWCommentPresentationData, OWCommentThreadActionsCellMode)>] = commentCollapseCellsVms.map { commentCollapseCellsVm in
                    return commentCollapseCellsVm.outputs.commentActionsVM
                        .outputs.tapOutput
                        .map { (commentCollapseCellsVm.outputs.commentPresentationData, commentCollapseCellsVm.outputs.mode) }
                }
                return Observable.merge(collapseClickObservable)
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
    }
}
