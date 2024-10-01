//
//  OWCommentCellViewModel.swift
//  OpenWebSDK
//
//  Created by Alon Haiut on 27/07/2022.
//  Copyright © 2022 OpenWeb. All rights reserved.
//

import Foundation
import RxSwift

protocol OWCommentCellViewModelingInputs {

}

protocol OWCommentCellViewModelingOutputs {
    var commentVM: OWCommentViewModeling { get }
    var id: String { get }
    var viewAccessibilityIdentifier: String { get }
    var updateSpacing: Observable<OWVerticalSpacing> { get }
}

protocol OWCommentCellViewModeling: OWCellViewModel {
    var inputs: OWCommentCellViewModelingInputs { get }
    var outputs: OWCommentCellViewModelingOutputs { get }
}

class OWCommentCellViewModel: OWCommentCellViewModeling,
                              OWCommentCellViewModelingInputs,
                              OWCommentCellViewModelingOutputs {
    private struct Metrics {
        static let viewAccessibilityIdentifier = "comment_cell_id_"
    }

    var inputs: OWCommentCellViewModelingInputs { return self }
    var outputs: OWCommentCellViewModelingOutputs { return self }

    lazy var viewAccessibilityIdentifier: String = {
        return Metrics.viewAccessibilityIdentifier + id
    }()

    private let _updateSpacing = BehaviorSubject<OWVerticalSpacing?>(value: nil)
    var updateSpacing: Observable<OWVerticalSpacing> {
        _updateSpacing
            .unwrap()
            .take(1)
            .asObservable()
    }

    let commentVM: OWCommentViewModeling

    var id: String = ""

    init(data: OWCommentRequiredData,
         spacing: OWVerticalSpacing) {
        self.id = data.comment.id ?? ""

        self.commentVM = OWCommentViewModel(data: data)

        _updateSpacing.onNext(spacing)
    }

    init() {
        self.commentVM = OWCommentViewModel()
    }
}

extension OWCommentCellViewModel {
    static func stub() -> OWCommentCellViewModeling {
        return OWCommentCellViewModel()
    }
}
