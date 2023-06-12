//
//  OWCommentSkeletonShimmeringCellViewModel.swift
//  SpotImCore
//
//  Created by Alon Haiut on 24/10/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWCommentSkeletonShimmeringCellViewModelingInputs {

}

protocol OWCommentSkeletonShimmeringCellViewModelingOutputs {
    var id: String { get }
    var depth: Int { get }
}

protocol OWCommentSkeletonShimmeringCellViewModeling: OWCellViewModel {
    var inputs: OWCommentSkeletonShimmeringCellViewModelingInputs { get }
    var outputs: OWCommentSkeletonShimmeringCellViewModelingOutputs { get }
}

class OWCommentSkeletonShimmeringCellViewModel: OWCommentSkeletonShimmeringCellViewModeling,
                                                    OWCommentSkeletonShimmeringCellViewModelingInputs,
                                                    OWCommentSkeletonShimmeringCellViewModelingOutputs {
    var inputs: OWCommentSkeletonShimmeringCellViewModelingInputs { return self }
    var outputs: OWCommentSkeletonShimmeringCellViewModelingOutputs { return self }

    // Unique identifier
    let id: String = UUID().uuidString

    let depth: Int

    init(depth: Int = 0) {
        self.depth = depth
    }
}

extension OWCommentSkeletonShimmeringCellViewModel {
    static func stub() -> OWCommentSkeletonShimmeringCellViewModeling {
        return OWCommentSkeletonShimmeringCellViewModel()
    }
}

