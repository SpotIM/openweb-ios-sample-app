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
            .conversationRead(mode: .newest, page: OWPaginationPage.first, messageId: data.commentId)
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
                // TODO - Build cells from response
                print(responseComments)
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
