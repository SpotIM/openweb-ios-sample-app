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
            .asObservable()
    }()

    fileprivate var _commentsPresentationData = OWObservableArray<OWCommentPresentationData>()

    fileprivate var _commentIdToCommentCellVM: [String: OWCommentCellViewModel] = [:]

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
    private func getCells(for commentsPresentationData: [OWCommentPresentationData]) -> [OWCommentThreadCellOption] {
        var cellOptions = [OWCommentThreadCellOption]()

        for (idx, commentPresentationData) in commentsPresentationData.enumerated() {
            guard let commentCellVM = self._commentIdToCommentCellVM[commentPresentationData.id] else { continue }

            if (commentCellVM.outputs.commentVM.outputs.comment.depth == 0 && idx > 0) {
                cellOptions.append(OWCommentThreadCellOption.spacer(viewModel: OWSpacerCellViewModel()))
            }

            cellOptions.append(OWCommentThreadCellOption.comment(viewModel: commentCellVM))

            let depth = commentCellVM.outputs.commentVM.outputs.comment.depth ?? 0

            switch (commentPresentationData.repliesThreadState, commentPresentationData.totalRepliesCount) {
            case (.collapsed, 0):
                break
            case (.showFirst, 0):
                break
            case (.collapsed, _):
                cellOptions.append(OWCommentThreadCellOption.commentThreadExpand(viewModel: OWCommentThreadExpandCellViewModel(data: commentPresentationData, depth: depth)))
            case (.showFirst(let count), _):
                cellOptions.append(OWCommentThreadCellOption.commentThreadCollapse(viewModel: OWCommentThreadCollapseCellViewModel(data: commentPresentationData, depth: depth)))

                let commentsToShow = Array(commentPresentationData.repliesPresentation.prefix(count))

                cellOptions.append(contentsOf: getCells(for: commentsToShow))

                if (commentsToShow.count < commentPresentationData.totalRepliesCount) {
                    cellOptions.append(OWCommentThreadCellOption.commentThreadExpand(viewModel: OWCommentThreadExpandCellViewModel(data: commentPresentationData, depth: depth)))
                }
            }
        }
        return cellOptions
    }

    private func getSkeletonCells() -> [OWCommentThreadCellOption] {
        var cellOptions = [OWCommentThreadCellOption]()
        let numberOfComments = Metrics.numberOfCommentsInSkeleton
        let skeletonCellVMs = (0 ..< numberOfComments).map { index in
            OWCommentSkeletonShimmeringCellViewModel(depth: index > 0 ? 1 : 0)
        }
        let skeletonCells = skeletonCellVMs.map { OWCommentThreadCellOption.commentSkeletonShimmering(viewModel: $0) }
        cellOptions.append(contentsOf: skeletonCells)

        return cellOptions
    }
}

fileprivate extension OWCommentThreadViewViewModel {
    // swiftlint:disable function_body_length
    func setupObservers() {
        // Observable for the conversation network API
        // TODO - split to - initial fetch / pull to refresh + pagination + replies
        let conversationThreadReadObservable = Observable.merge([_commentThreadData.unwrap().flatMap { _ in
            return Observable.just(0)
        }, _loadMoreComments.distinctUntilChanged()]).flatMap { [weak self] offset -> Observable<OWConversationReadRM> in
            guard let self = self else { return .empty() }
            return self.servicesProvider
            .netwokAPI()
            .conversation
            .conversationRead(mode: .best, page: OWPaginationPage.first, parentId: "", offset: offset)
//            .conversationRead(mode: .newest, page: OWPaginationPage.first, messageId: data.commentId)
            .response
        }

        let commentThreadFetchedObservable = viewInitialized
            .flatMap { _ -> Observable<OWConversationReadRM> in
                return conversationThreadReadObservable
            }

        // update comments presentation data
        commentThreadFetchedObservable
            .subscribe(onNext: { [weak self] response in
                guard let self = self, let responseComments = response.conversation?.comments else { return }

                let comments: [OWComment] = Array(responseComments)

                var commentsPresentationData = [OWCommentPresentationData]()
                var repliesPresentationData = [OWCommentPresentationData]()

                self.offset = response.conversation?.offset ?? 0

                for comment in comments {
                    guard let commentId = comment.id else { return }

                    guard self._commentIdToCommentCellVM[commentId] == nil else { return }

                    guard let user = response.conversation?.users?[comment.userId ?? ""] else { return }

                    let vm = OWCommentCellViewModel(data: OWCommentRequiredData(comment: comment, user: user, replyToUser: nil, collapsableTextLineLimit: 4))
                    self._commentIdToCommentCellVM[commentId] = vm

                    if let replies = comment.replies {

                        repliesPresentationData = []

                        for reply in replies {
                            guard let replyId = reply.id else { return }
                            guard let replyUser = response.conversation?.users?[reply.userId ?? ""] else { return }
                            let vm = OWCommentCellViewModel(data: OWCommentRequiredData(comment: reply, user: replyUser, replyToUser: user, collapsableTextLineLimit: 4))
                            self._commentIdToCommentCellVM[replyId] = vm

                            let replyPresentationData = OWCommentPresentationData(
                                id: replyId,
                                repliesThreadState: .collapsed,
                                repliesIds: reply.replies?.map { $0.id! } ?? [],
                                totalRepliesCount: reply.repliesCount ?? 0,
                                repliesOffset: reply.offset ?? 0, repliesPresentation: []
                            )

                            repliesPresentationData.append(replyPresentationData)
                        }
                    }

                    let commentPresentationData = OWCommentPresentationData(
                        id: commentId,
                        repliesThreadState: .showFirst(numberOfReplies: repliesPresentationData.count),
                        repliesIds: comment.replies?.map { $0.id! } ?? [],
                        totalRepliesCount: comment.repliesCount ?? 0,
                        repliesOffset: comment.offset ?? 0,
                        repliesPresentation: repliesPresentationData
                    )

                    commentsPresentationData.append(commentPresentationData)
                }

                self._commentsPresentationData.append(contentsOf: commentsPresentationData)
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
                commentPresentationData.repliesThreadState = .collapsed
            })
            .disposed(by: disposeBag)
    }
}
