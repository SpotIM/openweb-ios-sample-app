//
//  OWCommentCreationFloatingKeyboardViewVM.swift
//  SpotImCore
//
//  Created by Alon Shprung on 07/06/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWCommentCreationFloatingKeyboardViewViewModelingInputs {
    var closeButtonTap: PublishSubject<Void> { get }
}

protocol OWCommentCreationFloatingKeyboardViewViewModelingOutputs {
    var commentType: OWCommentCreationType { get }
    var accessoryViewStrategy: OWAccessoryViewStrategy { get }
}

protocol OWCommentCreationFloatingKeyboardViewViewModeling {
    var inputs: OWCommentCreationFloatingKeyboardViewViewModelingInputs { get }
    var outputs: OWCommentCreationFloatingKeyboardViewViewModelingOutputs { get }
}

class OWCommentCreationFloatingKeyboardViewViewModel:
    OWCommentCreationFloatingKeyboardViewViewModeling,
    OWCommentCreationFloatingKeyboardViewViewModelingInputs,
    OWCommentCreationFloatingKeyboardViewViewModelingOutputs {

    var inputs: OWCommentCreationFloatingKeyboardViewViewModelingInputs { return self }
    var outputs: OWCommentCreationFloatingKeyboardViewViewModelingOutputs { return self }

    fileprivate let servicesProvider: OWSharedServicesProviding
    fileprivate let _commentCreationData = BehaviorSubject<OWCommentCreationRequiredData?>(value: nil)

    let commentType: OWCommentCreationType
    let accessoryViewStrategy: OWAccessoryViewStrategy

    var closeButtonTap = PublishSubject<Void>()

    init (commentCreationData: OWCommentCreationRequiredData,
          servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared,
          viewableMode: OWViewableMode = .independent) {
        self.servicesProvider = servicesProvider
        self._commentCreationData.onNext(commentCreationData)
        commentType = commentCreationData.commentCreationType

        // Setting accessoryViewStrategy
        let style = commentCreationData.settings.commentCreationSettings.style
        if case let OWCommentCreationStyle.floatingKeyboard(strategy) = style {
            accessoryViewStrategy = strategy
        } else {
            accessoryViewStrategy = OWAccessoryViewStrategy.default
        }
        setupObservers()
    }
}

fileprivate extension OWCommentCreationFloatingKeyboardViewViewModel {
    func setupObservers() {

    }
}
