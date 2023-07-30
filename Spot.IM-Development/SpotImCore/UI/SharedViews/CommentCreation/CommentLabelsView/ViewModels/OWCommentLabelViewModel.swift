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
    var labelClicked: PublishSubject<Void> { get }
}

protocol OWCommentLabelViewModelingOutputs {
    var commentLabelSettings: Observable<OWCommentLabelSettings> { get }
    var state: Observable<OWLabelState> { get }
    var labelClickedOutput: Observable<Void> { get }
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
    fileprivate let _state = BehaviorSubject<OWLabelState>(value: .readOnly)

    init(commentLabelSettings: OWCommentLabelSettings, state: OWLabelState = .readOnly) {
        _setting.onNext(commentLabelSettings)
        _state.onNext(state)
    }

    var commentLabelSettings: Observable<OWCommentLabelSettings> {
        _setting
            .unwrap()
            .asObservable()
    }

    var state: Observable<OWLabelState> {
        _state
            .asObservable()
    }

    var labelClicked = PublishSubject<Void>()
    var labelClickedOutput: Observable<Void> {
        labelClicked
            .asObservable()
    }
}
