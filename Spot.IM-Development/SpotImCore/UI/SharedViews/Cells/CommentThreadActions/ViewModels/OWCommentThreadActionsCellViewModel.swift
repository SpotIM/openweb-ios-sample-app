//
//  OWCommentThreadActionsCellViewModel.swift
//  SpotImCore
//
//  Created by Alon Shprung on 22/03/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

enum OWCommentThreadActionType {
    case collapseThread
    case viewReplies(repliesCount: Int, totalRepliesCount: Int)
}

protocol OWCommentThreadActionsCellViewModelingInputs {

}

protocol OWCommentThreadActionsCellViewModelingOutputs {
    var id: String { get }
}

protocol OWCommentThreadActionsCellViewModeling: OWCellViewModel {
    var inputs: OWCommentThreadActionsCellViewModelingInputs { get }
    var outputs: OWCommentThreadActionsCellViewModelingOutputs { get }
}

class OWCommentThreadActionsCellViewModel: OWCommentThreadActionsCellViewModeling, OWCommentThreadActionsCellViewModelingInputs, OWCommentThreadActionsCellViewModelingOutputs {
    var inputs: OWCommentThreadActionsCellViewModelingInputs { return self }
    var outputs: OWCommentThreadActionsCellViewModelingOutputs { return self }

    let id: String = UUID().uuidString
}

extension OWCommentThreadActionsCellViewModel {
    static func stub() -> OWCommentThreadActionsCellViewModeling {
        return OWCommentThreadActionsCellViewModel()
    }
}
