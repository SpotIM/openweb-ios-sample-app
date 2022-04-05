//
//  OWConversationSortViewModel.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 05/04/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWConversationSortViewModelingInputs {
    func configure(selectedSortOption: SPCommentSortMode)
}

protocol OWConversationSortViewModelingOutputs {
    var selectedSortOption: Observable<SPCommentSortMode> { get }
}

protocol OWConversationSortViewModeling {
    var inputs: OWConversationSortViewModelingInputs { get }
    var outputs: OWConversationSortViewModelingOutputs { get }
}

class OWConversationSortViewModel: OWConversationSortViewModeling,
                                   OWConversationSortViewModelingInputs,
                                   OWConversationSortViewModelingOutputs {
    var inputs: OWConversationSortViewModelingInputs { return self }
    var outputs: OWConversationSortViewModelingOutputs { return self }
          
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
