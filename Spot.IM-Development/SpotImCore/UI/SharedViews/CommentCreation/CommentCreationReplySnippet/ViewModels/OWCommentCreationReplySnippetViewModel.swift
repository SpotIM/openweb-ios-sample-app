//
//  OWCommentCreationReplySnippetViewModel.swift
//  SpotImCore
//
//  Created by Alon Shprung on 16/07/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWCommentCreationReplySnippetViewModelingInputs {
}

protocol OWCommentCreationReplySnippetViewModelingOutputs {
}

protocol OWCommentCreationReplySnippetViewModeling {
    var inputs: OWCommentCreationReplySnippetViewModelingInputs { get }
    var outputs: OWCommentCreationReplySnippetViewModelingOutputs { get }
}

class OWCommentCreationReplySnippetViewModel: OWCommentCreationReplySnippetViewModeling,
                                              OWCommentCreationReplySnippetViewModelingInputs,
                                              OWCommentCreationReplySnippetViewModelingOutputs {

    var inputs: OWCommentCreationReplySnippetViewModelingInputs { return self }
    var outputs: OWCommentCreationReplySnippetViewModelingOutputs { return self }

    fileprivate let disposeBag = DisposeBag()
    fileprivate let servicesProvider: OWSharedServicesProviding

    init(commentCreationType: OWCommentCreationType,
         servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.servicesProvider = servicesProvider
        setupObservers()
    }
}

fileprivate extension OWCommentCreationReplySnippetViewModel {
    func setupObservers() {

    }
}

