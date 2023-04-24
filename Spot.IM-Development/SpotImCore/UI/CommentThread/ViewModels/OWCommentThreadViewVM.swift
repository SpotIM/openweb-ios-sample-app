//
//  OWCommentThreadViewVM.swift
//  SpotImCore
//
//  Created by Alon Shprung on 30/01/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

typealias CommentThreadDataSourceModel = OWAnimatableSectionModel<String, OWCommentThreadCellOption>

protocol OWCommentThreadViewViewModelingInputs {
    var viewInitialized: PublishSubject<Void> { get }
    var willDisplayCell: PublishSubject<WillDisplayCellEvent> { get }
}

protocol OWCommentThreadViewViewModelingOutputs {
    var commentThreadDataSourceSections: Observable<[CommentThreadDataSourceModel]> { get }
    var updateCellSizeAtIndex: Observable<Int> { get }
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
        static let delayForUICellUpdate: Int = 100
    }

    fileprivate var postId: OWPostId {
        return OWManager.manager.postId ?? ""
    }

    fileprivate let servicesProvider: OWSharedServicesProviding
    fileprivate let _commentThreadData = BehaviorSubject<OWCommentThreadRequiredData?>(value: nil)
    fileprivate let disposeBag = DisposeBag()

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
    var willDisplayCell = PublishSubject<WillDisplayCellEvent>()
    fileprivate var _loadMoreComments = PublishSubject<Int>()
    fileprivate var _loadMoreReplies = PublishSubject<OWCommentPresentationData>()

    var offset = 0

    fileprivate var _changeSizeAtIndex = PublishSubject<Int>()
    var updateCellSizeAtIndex: Observable<Int> {
        return _changeSizeAtIndex
            .asObservable()
    }

    init (commentThreadData: OWCommentThreadRequiredData, servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.servicesProvider = servicesProvider
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
                cellOptions.append(OWCommentThreadCellOption.spacer(viewModel: OWSpacerCellViewModel()))
            }

            cellOptions.append(OWCommentThreadCellOption.comment(viewModel: commentCellVM))

            let depth = commentCellVM.outputs.commentVM.outputs.comment.depth ?? 0

            let repliesToShowCount = commentPresentationData.repliesPresentation.count

            switch (repliesToShowCount, commentPresentationData.totalRepliesCount) {
            case (_, 0):
                break
            case (0, _):
                cellOptions.append(OWCommentThreadCellOption.commentThreadExpand(viewModel: OWCommentThreadExpandCellViewModel(data: commentPresentationData, depth: depth)))
            default:
                cellOptions.append(OWCommentThreadCellOption.commentThreadCollapse(viewModel: OWCommentThreadCollapseCellViewModel(data: commentPresentationData, depth: depth)))

                cellOptions.append(contentsOf: getCells(for: commentPresentationData.repliesPresentation))

                if (repliesToShowCount < commentPresentationData.totalRepliesCount) {
                    cellOptions.append(OWCommentThreadCellOption.commentThreadExpand(viewModel: OWCommentThreadExpandCellViewModel(data: commentPresentationData, depth: depth)))
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
        // TODO - split to - initial fetch / pull to refresh + pagination + replies
        let initialConversationThreadReadObservable = _commentThreadData
            .unwrap()
            .flatMap { [weak self] _ -> Observable<OWConversationReadRM> in
                guard let self = self else { return .empty() }
                return self.servicesProvider
                .netwokAPI()
                .conversation
                .conversationRead(mode: .best, page: OWPaginationPage.first, parentId: "", offset: 0)
    //            .conversationRead(mode: .newest, page: OWPaginationPage.first, messageId: data.commentId)
                .response
        }

        let commentThreadFetchedObservable = viewInitialized
            .flatMap { _ -> Observable<OWConversationReadRM> in
                return initialConversationThreadReadObservable
            }

        let loadMoreCommentsReadObservable = _loadMoreComments
            .distinctUntilChanged()
            .flatMap { [weak self] offset -> Observable<OWConversationReadRM> in
                guard let self = self else { return .empty() }
                return self.servicesProvider
                .netwokAPI()
                .conversation
                .conversationRead(mode: .best, page: OWPaginationPage.next, parentId: "", offset: offset)
                .response
            }

        // append new comments
        Observable.merge(commentThreadFetchedObservable, loadMoreCommentsReadObservable)
            .subscribe(onNext: { [weak self] response in
                guard let self = self else { return }

                self.cacheConversationRead(response: response)

                var commentsPresentationData = self.getCommentsPresentationData(from: response)

                commentsPresentationData = commentsPresentationData.filter { !(self._commentsPresentationData.map { $0.id }).contains($0.id) }

                self._commentsPresentationData.append(contentsOf: commentsPresentationData)
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

            commentPresentationData.repliesPresentation = repliesPresentation

            commentPresentationData.update.onNext()
        })
        .disposed(by: disposeBag)

        // Responding to comment height change (for updating cell)
        cellsViewModels
            .flatMapLatest { cellsVms -> Observable<Int> in
                let sizeChangeObservable: [Observable<Int>] = cellsVms.enumerated().map { (index, vm) in
                    if case.comment(let commentCellViewModel) = vm {
                        let commentVM = commentCellViewModel.outputs.commentVM
                        return commentVM.outputs.contentVM
                            .outputs.collapsableLabelViewModel.outputs.height
                            .map { _ in index }
                    } else {
                        return nil
                    }
                }
                .unwrap()
                return Observable.merge(sizeChangeObservable)
            }
            .delay(.milliseconds(Metrics.delayForUICellUpdate), scheduler: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] commentIndex in
                self?._changeSizeAtIndex.onNext(commentIndex)
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
            .withLatestFrom(cellsViewModels) { rowIndex, cellsVMs in
                return (rowIndex, cellsVMs.count)
            }.subscribe(onNext: { [weak self] rowIndex, cellsCount in
                guard let self = self else { return }
                if (rowIndex > cellsCount - 5) {
                    self._loadMoreComments.onNext(self.offset)
                }
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

        // Observable of the comment collapse cell VMs
        let commentCollapseCellsVmsObservable: Observable<[OWCommentThreadCollapseCellViewModeling]> = cellsViewModels
            .flatMapLatest { viewModels -> Observable<[OWCommentThreadCollapseCellViewModeling]> in
                let commentThreadCollapseCellsVms: [OWCommentThreadCollapseCellViewModeling] = viewModels.map { vm in
                    if case.commentThreadCollapse(let commentThreadCollapseCellViewModel) = vm {
                        return commentThreadCollapseCellViewModel
                    } else {
                        return nil
                    }
                }
                    .unwrap()

                return Observable.just(commentThreadCollapseCellsVms)
            }
            .share()

        // responding to collapse thread clicked
        commentCollapseCellsVmsObservable
            .flatMap { commentCollapseCellsVms -> Observable<OWCommentPresentationData> in
                let collapseClickObservable: [Observable<OWCommentPresentationData>] = commentCollapseCellsVms.map { commentCollapseCellsVm in
                    return commentCollapseCellsVm.outputs.commentActionsVM
                        .outputs.tapOutput
                        .map { commentCollapseCellsVm.outputs.commentPresentationData }
                }
                return Observable.merge(collapseClickObservable)
            }
            .subscribe(onNext: { commentPresentationData in
                commentPresentationData.repliesPresentation.removeAll()

                commentPresentationData.update.onNext()
            })
            .disposed(by: disposeBag)

        // Observable of the comment expand cell VMs
        let commentExpandCellsVmsObservable: Observable<[OWCommentThreadExpandCellViewModeling]> = cellsViewModels
            .flatMapLatest { viewModels -> Observable<[OWCommentThreadExpandCellViewModeling]> in
                let commentThreadExpandCellsVms: [OWCommentThreadExpandCellViewModeling] = viewModels.map { vm in
                    if case.commentThreadExpand(let commentThreadExpandCellViewModel) = vm {
                        return commentThreadExpandCellViewModel
                    } else {
                        return nil
                    }
                }
                    .unwrap()

                return Observable.just(commentThreadExpandCellsVms)
            }
            .share()

        // responding to expand thread clicked
        commentExpandCellsVmsObservable
            .flatMap { commentExpandCellsVms -> Observable<OWCommentPresentationData> in
                let expandClickObservable: [Observable<OWCommentPresentationData>] = commentExpandCellsVms.map { commentExpandCellsVm in
                    return commentExpandCellsVm.outputs.commentActionsVM
                        .outputs.tapOutput
                        .map { commentExpandCellsVm.outputs.commentPresentationData }
                }
                return Observable.merge(expandClickObservable)
            }
            .subscribe(onNext: { [weak self] commentPresentationData in
                guard let self = self else { return }
                self._loadMoreReplies.onNext(commentPresentationData)
            })
            .disposed(by: disposeBag)
    }
}
