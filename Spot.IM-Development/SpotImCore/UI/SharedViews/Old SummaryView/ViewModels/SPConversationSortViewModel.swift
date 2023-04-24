//
//  SPConversationSortViewModel.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 05/04/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol SPConversationSortViewModelingInputs {
    func configure(selectedSortOption: SPCommentSortMode)
}

protocol SPConversationSortViewModelingOutputs {
    var selectedSortOption: Observable<SPCommentSortMode> { get }
}

protocol SPConversationSortViewModeling {
    var inputs: SPConversationSortViewModelingInputs { get }
    var outputs: SPConversationSortViewModelingOutputs { get }
}

class SPConversationSortViewModel: SPConversationSortViewModeling,
                                   SPConversationSortViewModelingInputs,
                                   SPConversationSortViewModelingOutputs {
    var inputs: SPConversationSortViewModelingInputs { return self }
    var outputs: SPConversationSortViewModelingOutputs { return self }

    fileprivate let _selectedSortOption = BehaviorSubject<SPCommentSortMode?>(value: nil)

    init (sortOption: SPCommentSortMode? = nil) {
        if let sortOption = sortOption {
            configure(selectedSortOption: sortOption)
        }
    }

    var selectedSortOption: Observable<SPCommentSortMode> {
        _selectedSortOption
            .unwrap()
            .map { $0 }
    }

    func configure(selectedSortOption: SPCommentSortMode) {
        _selectedSortOption.onNext(selectedSortOption)
    }
}
