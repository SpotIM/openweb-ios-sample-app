//
//  OWCommentLabelViewModel.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 15/12/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import RxSwift
import RxCocoa
import UIKit

typealias CommentLabelsSectionsConfig = Dictionary<String, SPCommentLabelsSectionConfiguration>

protocol OWCommentLabelViewModelingInputs {
    // TODO: click ?
}

protocol OWCommentLabelViewModelingOutputs {
    var commentLabelSettings: Observable<OWCommentLabelSettings> { get }
    var state: Observable<OWLabelState> { get }
}

protocol OWCommentLabelViewModeling {
    var inputs: OWCommentLabelViewModelingInputs { get }
    var outputs: OWCommentLabelViewModelingOutputs { get }
}

class OWCommentLabelViewModel: OWCommentLabelViewModeling,
                               OWCommentLabelViewModelingInputs,
                               OWCommentLabelViewModelingOutputs {

    var inputs: OWCommentLabelViewModelingInputs { return self }
    var outputs: OWCommentLabelViewModelingOutputs { return self }
    
    fileprivate let _setting = BehaviorSubject<OWCommentLabelSettings?>(value: nil)
    
    init(commentLabelSettings: OWCommentLabelSettings) {
        _setting.onNext(commentLabelSettings)
    }
        
    var commentLabelSettings: Observable<OWCommentLabelSettings> {
        _setting
            .unwrap()
            .asObservable()
    }
    
    var state: Observable<OWLabelState> {
        _setting
            // TODO: for now only implement read only mode for displaying label. When create comment is developed should add selected & not selected by clicks
            .map { _ in return .readOnly }
            .asObservable()
    }
}
