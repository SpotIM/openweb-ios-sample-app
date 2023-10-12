//
//  OWCommentThreadActionsCellViewModel.swift
//  SpotImCore
//
//  Created by Alon Shprung on 29/03/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWCommentThreadActionsCellViewModelingInputs {
    func update(commentPresentationData: OWCommentPresentationData)
    var triggerUpdateActionType: PublishSubject<Void> { get }
}

protocol OWCommentThreadActionsCellViewModelingOutputs {
    var id: String { get }
    var mode: OWCommentThreadActionsCellMode { get }
    var commentPresentationData: OWCommentPresentationData { get }
    var commentActionsVM: OWCommentThreadActionsViewModel { get }
    var depth: Int { get }
}

protocol OWCommentThreadActionsCellViewModeling: OWCellViewModel {
    var inputs: OWCommentThreadActionsCellViewModelingInputs { get }
    var outputs: OWCommentThreadActionsCellViewModelingOutputs { get }
}

enum OWCommentThreadActionsCellMode {
    case collapse
    case expand
}

class OWCommentThreadActionsCellViewModel: OWCommentThreadActionsCellViewModeling, OWCommentThreadActionsCellViewModelingInputs, OWCommentThreadActionsCellViewModelingOutputs {
    fileprivate struct Metrics {
        static let expandCommentsCount: Int = 5
    }

    fileprivate let disposeBag = DisposeBag()

    var inputs: OWCommentThreadActionsCellViewModelingInputs { return self }
    var outputs: OWCommentThreadActionsCellViewModelingOutputs { return self }

    var id: String = UUID().uuidString

    var depth: Int = 0

    var commentPresentationData: OWCommentPresentationData

    var mode: OWCommentThreadActionsCellMode = .collapse

    var triggerUpdateActionType = PublishSubject<Void>()

    lazy var commentActionsVM: OWCommentThreadActionsViewModel = OWCommentThreadActionsViewModel(with: .collapseThread, commentId: self.commentPresentationData.id)

    init(id: String = UUID().uuidString, data: OWCommentPresentationData, mode: OWCommentThreadActionsCellMode = .collapse, depth: Int = 0) {
        self.id = id
        self.commentPresentationData = data
        self.depth = depth
        self.mode = mode
        self.setupObservers()
        self.triggerUpdateActionType.onNext()
    }

    init() {
        self.commentPresentationData = OWCommentPresentationData(
            id: "",
            repliesIds: [],
            totalRepliesCount: 0,
            repliesOffset: 0,
            repliesPresentation: []
        )
        self.setupObservers()
    }

    func update(commentPresentationData: OWCommentPresentationData) {
        self.commentPresentationData = commentPresentationData
    }
}

fileprivate extension OWCommentThreadActionsCellViewModel {
    func setupObservers() {
        triggerUpdateActionType
            .map({ [weak self] _ -> OWCommentThreadActionType? in
                guard let self = self else { return nil }
                return self.mode == .collapse ? .collapseThread : self.getCommentThreadActionTypeForExpand()
            })
            .unwrap()
            .bind(to: self.commentActionsVM.inputs.updateActionType)
            .disposed(by: disposeBag)
    }

    func getCommentThreadActionTypeForExpand() -> OWCommentThreadActionType {
        let visibleRepliesCount = commentPresentationData.repliesPresentation.count
        let totalRepliesCount = commentPresentationData.totalRepliesCount

        let extendedRepliesCount = min(visibleRepliesCount + Metrics.expandCommentsCount, totalRepliesCount)

        let commentThreadActionType: OWCommentThreadActionType
        if (visibleRepliesCount == 0 && totalRepliesCount < Metrics.expandCommentsCount) {
            commentThreadActionType = .viewMoreReplies(count: extendedRepliesCount)
        } else {
            commentThreadActionType = .viewMoreRepliesRange(from: extendedRepliesCount, to: totalRepliesCount)
        }
        return commentThreadActionType
    }
}

extension OWCommentThreadActionsCellViewModel {
    static func stub() -> OWCommentThreadActionsCellViewModeling {
        return OWCommentThreadActionsCellViewModel()
    }
}
