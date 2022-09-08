//
//  OWConversationVM.swift
//  SpotImCore
//
//  Created by Alon Haiut on 06/07/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWConversationViewModelingInputs {
    // String is the commentId
    var highlightComment: PublishSubject<String> { get }
}

protocol OWConversationViewModelingOutputs {
    var conversationViewVM: OWConversationViewViewModeling { get }
    var ctaCommentCreationTapped: Observable<Void> { get }
    var userInitiatedAuthenticationFlow: Observable<Void> { get }
    var highlightedComment: Observable<String> { get }
}

protocol OWConversationViewModeling {
    var inputs: OWConversationViewModelingInputs { get }
    var outputs: OWConversationViewModelingOutputs { get }
}

class OWConversationViewModel: OWConversationViewModeling, OWConversationViewModelingInputs, OWConversationViewModelingOutputs {
    var inputs: OWConversationViewModelingInputs { return self }
    var outputs: OWConversationViewModelingOutputs { return self }
    
    fileprivate let servicesProvider: OWSharedServicesProviding
    fileprivate let conversationData: OWConversationRequiredData
    fileprivate let disposeBag = DisposeBag()
    
    lazy var conversationViewVM: OWConversationViewViewModeling = {
        return OWConversationViewViewModel(conversationData: conversationData)
    }()
    
    var ctaCommentCreationTapped: Observable<Void> {
        // TODO: Complete
        return .never()
    }
    
    var userInitiatedAuthenticationFlow: Observable<Void> {
        // TODO: Complete
        return .never()
    }
    
    var highlightComment = PublishSubject<String>()
    
    fileprivate var _highlightedComment = BehaviorSubject<String?>(value: nil)
    var highlightedComment: Observable<String> {
        return _highlightedComment
            .unwrap()
            .asObservable()
    }

    init (conversationData: OWConversationRequiredData,
          servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.servicesProvider = servicesProvider
        self.conversationData = conversationData
        setupObservers()
    }
}

fileprivate extension OWConversationViewModel {
    func setupObservers() {
        // Using BehaviorSubject behind the scene as the view create only after the coordinator initiated `viewModel.inputs.highlightComment.onNext(...)`
        highlightComment
            .bind(to: _highlightedComment)
            .disposed(by: disposeBag)
    }
}
