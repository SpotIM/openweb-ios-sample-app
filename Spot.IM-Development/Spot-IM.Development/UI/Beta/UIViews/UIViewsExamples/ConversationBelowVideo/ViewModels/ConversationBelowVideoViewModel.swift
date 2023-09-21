//
//  ConversationBelowVideoViewModel.swift
//  Spot-IM.Development
//
//  Created by Alon Haiut on 21/09/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift
import SpotImCore

#if NEW_API

protocol ConversationBelowVideoViewModelingInputs {}

protocol ConversationBelowVideoViewModelingOutputs {
    var title: String { get }
}

protocol ConversationBelowVideoViewModeling {
    var inputs: ConversationBelowVideoViewModelingInputs { get }
    var outputs: ConversationBelowVideoViewModelingOutputs { get }
}

class ConversationBelowVideoViewModel: ConversationBelowVideoViewModeling, ConversationBelowVideoViewModelingOutputs, ConversationBelowVideoViewModelingInputs {
    var inputs: ConversationBelowVideoViewModelingInputs { return self }
    var outputs: ConversationBelowVideoViewModelingOutputs { return self }

    fileprivate let postId: OWPostId
    fileprivate let disposeBag = DisposeBag()

    lazy var title: String = {
        return NSLocalizedString("VideoExample", comment: "")
    }()

    init(postId: OWPostId) {
        self.postId = postId
        setupObservers()
    }
}

fileprivate extension ConversationBelowVideoViewModel {
    func setupObservers() {}
}

#endif
