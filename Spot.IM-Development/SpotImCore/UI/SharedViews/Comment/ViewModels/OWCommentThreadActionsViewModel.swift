//
//  OWCommentThreadActionsViewModel.swift
//  SpotImCore
//
//  Created by Alon Shprung on 27/03/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

enum OWCommentThreadActionType {
    case collapseThread
    case viewMoreReplies(count: Int)
    case viewMoreRepliesRange(from: Int, to: Int)
}

protocol OWCommentThreadActionsViewModelingInputs {
    var tap: PublishSubject<Void> { get }
}

protocol OWCommentThreadActionsViewModelingOutputs {
    var tapOutput: Observable<Void> { get }
    var actionLabelText: Observable<String> { get }
    var disclosureTransform: Observable<CGAffineTransform> { get }
}

protocol OWCommentThreadActionsViewModeling {
    var inputs: OWCommentThreadActionsViewModelingInputs { get }
    var outputs: OWCommentThreadActionsViewModelingOutputs { get }
}

class OWCommentThreadActionsViewModel: OWCommentThreadActionsViewModeling, OWCommentThreadActionsViewModelingInputs, OWCommentThreadActionsViewModelingOutputs {
    var inputs: OWCommentThreadActionsViewModelingInputs { return self }
    var outputs: OWCommentThreadActionsViewModelingOutputs { return self }

    var tap = PublishSubject<Void>()
    var tapOutput: Observable<Void> {
        tap
            .asObservable()
    }

    init(with type: OWCommentThreadActionType) {
        switch type {
        case .collapseThread:
            // TODO - localization
            _actionLabelText.onNext("Collapse thread")
            _disclosureTransform.onNext(.identity)
        case .viewMoreReplies(count: let count):
            // TODO - localization + logic
            _actionLabelText.onNext("View \(count) \(count > 1 ? "replies" : "reply")")
            _disclosureTransform.onNext(.init(rotationAngle: .pi))
        case .viewMoreRepliesRange(from: let from, to: let to):
            // TODO - localization + logic
            _actionLabelText.onNext("View \(from) of \(to) replies")
            _disclosureTransform.onNext(.init(rotationAngle: .pi))
        }
    }

    let _actionLabelText = BehaviorSubject<String?>(value: nil)
    var actionLabelText: Observable<String> {
        _actionLabelText
            .unwrap()
            .asObservable()
    }

    let _disclosureTransform = BehaviorSubject<CGAffineTransform?>(value: nil)
    var disclosureTransform: Observable<CGAffineTransform> {
        _disclosureTransform
            .unwrap()
            .asObservable()
    }
}
