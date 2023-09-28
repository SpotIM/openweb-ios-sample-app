//
//  OWErrorStateCellVM.swift
//  SpotImCore
//
//  Created by Refael Sommer on 10/09/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

// TODO: Decide if we need an OWConversationEmptyStateCell after final design in all orientations
protocol OWErrorStateCellViewModelingInputs {

}

protocol OWErrorStateCellViewModelingOutputs {
    var id: String { get }
    var errorStateViewModel: OWErrorStateViewViewModeling { get }
    var depth: Int { get }
}

protocol OWErrorStateCellViewModeling: OWCellViewModel {
    var inputs: OWErrorStateCellViewModelingInputs { get }
    var outputs: OWErrorStateCellViewModelingOutputs { get }
}

class OWErrorStateCellViewModel: OWErrorStateCellViewModeling,
                                 OWErrorStateCellViewModelingInputs,
                                 OWErrorStateCellViewModelingOutputs {
    var inputs: OWErrorStateCellViewModelingInputs { return self }
    var outputs: OWErrorStateCellViewModelingOutputs { return self }

    var depth: Int = 0

    lazy var errorStateViewModel: OWErrorStateViewViewModeling = {
        return OWErrorStateViewViewModel(errorStateType: errorStateType)
    }()

    fileprivate let errorStateType: OWErrorStateTypes
    fileprivate let commentPresentationData: OWCommentPresentationData?

    // Unique identifier
    let id: String

    init(id: String = UUID().uuidString, errorStateType: OWErrorStateTypes, commentPresentationData: OWCommentPresentationData? = nil, depth: Int = 0) {
        self.id = id
        self.errorStateType = errorStateType
        self.commentPresentationData = commentPresentationData
        self.depth = depth
    }
}

extension OWErrorStateCellViewModel {
    static func stub() -> OWErrorStateCellViewModeling {
        return OWErrorStateCellViewModel(errorStateType: .none)
    }
}
