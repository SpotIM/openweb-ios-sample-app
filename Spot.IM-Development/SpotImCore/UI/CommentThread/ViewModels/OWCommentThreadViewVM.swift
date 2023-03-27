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

    var _cellsViewModels = OWObservableArray<OWCommentThreadCellOption>()
    fileprivate var cellsViewModels: Observable<[OWCommentThreadCellOption]> {
        return _cellsViewModels
            .rx_elements()
            .asObservable()
    }

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

    fileprivate var _changeSizeAtIndex = PublishSubject<Int>()
    var updateCellSizeAtIndex: Observable<Int> {
        return _changeSizeAtIndex
            .asObservable()
    }

    init (commentThreadData: OWCommentThreadRequiredData, servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.servicesProvider = servicesProvider
        self._commentThreadData.onNext(commentThreadData)
        self.populateInitialUI()
        self.setupObservers()
    }
}

fileprivate extension OWCommentThreadViewViewModel {
    func setupObservers() {
        // Observable for the conversation network API
        let conversationThreadReadObservable = _commentThreadData.unwrap().flatMap { [weak self] data -> Observable<SPConversationReadRM> in
            guard let self = self else { return .empty() }
            return self.servicesProvider
            .netwokAPI()
            .conversation
            .conversationRead(mode: .best, page: OWPaginationPage.first)
//            .conversationRead(mode: .newest, page: OWPaginationPage.first, messageId: data.commentId)
            .response
        }

        let commentThreadFetchedObservable = viewInitialized
            .flatMap { _ -> Observable<SPConversationReadRM> in
                return conversationThreadReadObservable
                    .take(1)
            }
            .share()

        commentThreadFetchedObservable
            .subscribe(onNext: { [weak self] response in
                guard let self = self, let responseComments = response.conversation?.comments else { return }
                var viewModels = [OWCommentThreadCellOption]()

                let comments: [SPComment] = Array(responseComments)

                for comment in comments {
                    // TODO: replies
                    guard let user = response.conversation?.users?[comment.userId ?? ""] else { return }
                    let vm = OWCommentCellViewModel(data: OWCommentRequiredData(comment: comment, user: user, replyToUser: nil, collapsableTextLineLimit: 4))
                    viewModels.append(OWCommentThreadCellOption.comment(viewModel: vm))
                    if let replies = comment.replies {

                        viewModels.append(OWCommentThreadCellOption.spacer(viewModel: OWSpacerCellViewModel()))

                        for (index, reply) in replies.enumerated() {
                            guard let replyUser = response.conversation?.users?[reply.userId ?? ""] else { return }
                            let vm = OWCommentCellViewModel(data: OWCommentRequiredData(comment: reply, user: replyUser, replyToUser: nil, collapsableTextLineLimit: 4))
                            viewModels.append(OWCommentThreadCellOption.comment(viewModel: vm))
                            if (index < replies.count - 1) {
                                viewModels.append(OWCommentThreadCellOption.spacer(viewModel: OWSpacerCellViewModel()))
                            }
                        }
                    }
                }
                // TODO - Check why using replaceAll causing issues when click on "reply" - upen comment creation screen twice
//                self._cellsViewModels.replaceAll(with: viewModels)
                self._cellsViewModels.removeAll()
                self._cellsViewModels.append(contentsOf: viewModels)
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
            .flatMap { commentCellsVms -> Observable<SPComment> in
                let replyClickOutputObservable: [Observable<SPComment>] = commentCellsVms.map { commentCellVm in
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
    }

    func populateInitialUI() {
        let numberOfComments = Metrics.numberOfCommentsInSkeleton
        let skeletonCellVMs = (0 ..< numberOfComments).map { index in
            OWCommentSkeletonShimmeringCellViewModel(depth: index > 0 ? 1 : 0)
        }
        let skeletonCells = skeletonCellVMs.map { OWCommentThreadCellOption.commentSkeletonShimmering(viewModel: $0) }
        _cellsViewModels.append(contentsOf: skeletonCells)
    }
}
