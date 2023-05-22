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
    var viewDidLoad: PublishSubject<Void> { get }
    var closeConversationTapped: PublishSubject<Void> { get }
}

protocol OWConversationViewModelingOutputs {
    var conversationViewVM: OWConversationViewViewModeling { get }
    var highlightedComment: Observable<String> { get }
    var loadedToScreen: Observable<Void> { get }
    var shouldCustomizeNavigationBar: Bool { get }
    var shouldShowCloseButton: Bool { get }
    var closeConversation: Observable<Void> { get }
}

protocol OWConversationViewModeling {
    var inputs: OWConversationViewModelingInputs { get }
    var outputs: OWConversationViewModelingOutputs { get }
}

class OWConversationViewModel: OWConversationViewModeling,
                                OWConversationViewModelingInputs,
                               OWConversationViewModelingOutputs {

    var inputs: OWConversationViewModelingInputs { return self }
    var outputs: OWConversationViewModelingOutputs { return self }

    fileprivate let servicesProvider: OWSharedServicesProviding
    fileprivate let conversationData: OWConversationRequiredData
    fileprivate let viewableMode: OWViewableMode
    fileprivate let disposeBag = DisposeBag()

    lazy var conversationViewVM: OWConversationViewViewModeling = {
        return OWConversationViewViewModel(conversationData: conversationData,
                                           viewableMode: self.viewableMode)
    }()

    var shouldCustomizeNavigationBar: Bool {
        guard case OWPresentationalModeCompact.present(_) = conversationData.presentationalStyle,
              viewableMode == .partOfFlow else { return false }
        return true
    }

    var shouldShowCloseButton: Bool {
        guard case OWPresentationalModeCompact.present(_) = conversationData.presentationalStyle else { return false }
        return true
    }

    var highlightComment = PublishSubject<String>()
    fileprivate var _highlightedComment = BehaviorSubject<String?>(value: nil)
    var highlightedComment: Observable<String> {
        return _highlightedComment
            .unwrap()
            .asObservable()
    }

    var viewDidLoad = PublishSubject<Void>()
    var _viewDidLoad = BehaviorSubject<Void?>(value: nil)
    var loadedToScreen: Observable<Void> {
        return _viewDidLoad
            .unwrap()
            .asObservable()
    }

    var closeConversationTapped = PublishSubject<Void>()
    var closeConversation: Observable<Void> {
        return closeConversationTapped.asObservable()
    }

    init (conversationData: OWConversationRequiredData,
          servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared,
          viewableMode: OWViewableMode) {
        self.servicesProvider = servicesProvider
        self.conversationData = conversationData
        self.viewableMode = viewableMode
        setupObservers()
    }
}

fileprivate extension OWConversationViewModel {
    func setupObservers() {
        // Using BehaviorSubject behind the scene as the view create only after the coordinator initiated `viewModel.inputs.highlightComment.onNext(...)`
        highlightComment
            .bind(to: _highlightedComment)
            .disposed(by: disposeBag)

        // Same reason
        viewDidLoad
            .bind(to: _viewDidLoad)
            .disposed(by: disposeBag)
    }
}
