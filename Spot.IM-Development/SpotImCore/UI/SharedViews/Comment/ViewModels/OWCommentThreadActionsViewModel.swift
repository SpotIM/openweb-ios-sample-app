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
    var updateActionType: BehaviorSubject<OWCommentThreadActionType> { get }
}

protocol OWCommentThreadActionsViewModelingOutputs {
    var tapOutput: Observable<Void> { get }
    var actionLabelText: Observable<String> { get }
    var disclosureTransform: Observable<CGAffineTransform> { get }
    var commentId: String { get }
}

protocol OWCommentThreadActionsViewModeling {
    var inputs: OWCommentThreadActionsViewModelingInputs { get }
    var outputs: OWCommentThreadActionsViewModelingOutputs { get }
}

class OWCommentThreadActionsViewModel: OWCommentThreadActionsViewModeling, OWCommentThreadActionsViewModelingInputs, OWCommentThreadActionsViewModelingOutputs {
    var inputs: OWCommentThreadActionsViewModelingInputs { return self }
    var outputs: OWCommentThreadActionsViewModelingOutputs { return self }

    fileprivate let disposeBag = DisposeBag()

    var tap = PublishSubject<Void>()
    var tapOutput: Observable<Void> {
        tap.asObservable()
    }

    var updateActionType = BehaviorSubject<OWCommentThreadActionType>(value: .collapseThread)
    fileprivate lazy var updatedType: Observable<OWCommentThreadActionType> = {
       return updateActionType
            .asObservable()
    }()

    let commentId: String

    init(with type: OWCommentThreadActionType, commentId: String) {
        self.commentId = commentId
        self.setupObservers()
        self.updateActionType.onNext(type)
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

fileprivate extension OWCommentThreadActionsViewModel {
    func setupObservers() {
        updatedType
            .subscribe { [weak self] type in
                guard let self = self else { return }
                switch type {
                case .collapseThread:
                    self._actionLabelText.onNext(OWLocalizationManager.shared.localizedString(key: "CollapseThread"))
                    self._disclosureTransform.onNext(.identity)

                case .viewMoreReplies(count: let count):
                    let multipleRepliesString = OWLocalizationManager.shared.localizedString(key: "ViewMultipleRepliesFormat")
                    let singleReplyString = OWLocalizationManager.shared.localizedString(key: "ViewSingleReplyFormat")

                    let repliesString = count > 1 ? multipleRepliesString : singleReplyString
                    self._actionLabelText.onNext(String(format: repliesString, count))
                    self._disclosureTransform.onNext(CGAffineTransform(rotationAngle: .pi))

                case .viewMoreRepliesRange(from: let from, to: let to):
                    let repliesString = OWLocalizationManager.shared.localizedString(key: "ViewPartOfRepliesFormat")
                    self._actionLabelText.onNext(String(format: repliesString, from, to))
                    self._disclosureTransform.onNext(CGAffineTransform(rotationAngle: .pi))
                }
            }
            .disposed(by: disposeBag)
    }
}
