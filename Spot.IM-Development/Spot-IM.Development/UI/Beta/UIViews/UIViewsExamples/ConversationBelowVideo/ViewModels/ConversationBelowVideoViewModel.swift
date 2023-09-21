//
//  ConversationBelowVideoViewModel.swift
//  Spot-IM.Development
//
//  Created by Alon Haiut on 21/09/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift
import SpotImCore

#if NEW_API

protocol ConversationBelowVideoViewModelingInputs {}

protocol ConversationBelowVideoViewModelingOutputs {
    var title: String { get }
    var componentRetrievingError: Observable<OWError> { get }
    var preConversationRetrieved: Observable<UIView> { get }
    var conversationRetrieved: Observable<UIView> { get }
    var commentCreationRetrieved: Observable<UIView> { get }
    var reportReasonsRetrieved: Observable<UIView> { get }
    var removeConversation: Observable<Void> { get }
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
    fileprivate let commonCreatorService: CommonCreatorServicing

    lazy var title: String = {
        return NSLocalizedString("VideoExample", comment: "")
    }()

    fileprivate let _componentRetrievingError = BehaviorSubject<OWError?>(value: nil)
    var componentRetrievingError: Observable<OWError> {
        return _componentRetrievingError
            .unwrap()
            .asObservable()
    }

    fileprivate let _preConversationRetrieved = BehaviorSubject<UIView?>(value: nil)
    var preConversationRetrieved: Observable<UIView> {
        return _preConversationRetrieved
            .unwrap()
            .asObservable()
    }

    fileprivate let _conversationRetrieved = PublishSubject<UIView>()
    var conversationRetrieved: Observable<UIView> {
        return _conversationRetrieved
            .asObservable()
    }

    fileprivate let _commentCreationRetrieved = PublishSubject<UIView>()
    var commentCreationRetrieved: Observable<UIView> {
        return _commentCreationRetrieved
            .asObservable()
    }

    fileprivate let _reportReasonsRetrieved = PublishSubject<UIView>()
    var reportReasonsRetrieved: Observable<UIView> {
        return _reportReasonsRetrieved
            .asObservable()
    }

    fileprivate let _removeConversation = PublishSubject<Void>()
    var removeConversation: Observable<Void> {
        return _removeConversation
            .asObservable()
    }

    fileprivate lazy var actionsCallbacks: OWViewActionsCallbacks = { [weak self] callbackType, sourceType, _ in
        guard let self = self else { return }

        switch (sourceType, callbackType) {
        case (.preConversation, .contentPressed):
            self.retrieveConversationComponent()
        case (.conversation, .closeConversationPressed):
            self._removeConversation.onNext()
        default:
            break
        }
    }

    init(postId: OWPostId,
         commonCreatorService: CommonCreatorServicing = CommonCreatorService()) {
        self.postId = postId
        self.commonCreatorService = commonCreatorService
        setupObservers()
        initialSetup()
    }
}

fileprivate extension ConversationBelowVideoViewModel {
    func initialSetup() {
        // We are going to retrieve pre conversation component as soon as the user entered the screen.
        // We even perform the API in the init of the VM to speed things up
        retrievePreConversationComponent()
    }
    func setupObservers() {}

    func retrievePreConversationComponent() {
        let uiViewsLayer = OpenWeb.manager.ui.views
        let article = self.commonCreatorService.mockArticle(for: OpenWeb.manager.spotId)

        let additionalSettings = OWAdditionalSettings(preConversationSettings: OWPreConversationSettings(style: .compact))

        uiViewsLayer.preConversation(postId: self.postId,
                                     article: article,
                                     additionalSettings: additionalSettings,
                                     callbacks: self.actionsCallbacks,
                                     completion: { [weak self] result in

            guard let self = self else { return }
            switch result {
            case .failure(let err):
                self._componentRetrievingError.onNext(err)
            case.success(let view):
                self._preConversationRetrieved.onNext(view)
            }
        })
    }

    func retrieveConversationComponent() {
        let uiViewsLayer = OpenWeb.manager.ui.views
        let article = self.commonCreatorService.mockArticle(for: OpenWeb.manager.spotId)

        let additionalSettings = OWAdditionalSettings(fullConversationSettings: OWConversationSettings(style: .compact))

        uiViewsLayer.conversation(postId: self.postId,
                                  article: article,
                                  additionalSettings: additionalSettings,
                                  callbacks: self.actionsCallbacks,
                                  completion: { [weak self] result in

            guard let self = self else { return }
            switch result {
            case .failure(let err):
                self._componentRetrievingError.onNext(err)
            case.success(let view):
                self._conversationRetrieved.onNext(view)
            }
        })
    }

    func retrieveCommentCreationComponent(type: OWCommentCreationType) {
        let uiViewsLayer = OpenWeb.manager.ui.views
        let article = self.commonCreatorService.mockArticle(for: OpenWeb.manager.spotId)

        // Always show accessory view in the floating keyboard for this example of conversation below video
        let floatingBottomToolbarTuple = commonCreatorService.commentCreationFloatingBottomToolbar()
        let toolbar = floatingBottomToolbarTuple.1
        let toolbarVM = floatingBottomToolbarTuple.0
        let accessoryViewStrategy = OWAccessoryViewStrategy.bottomToolbar(toolbar: toolbar)
        let commentCreationStyle: OWCommentCreationStyle = .floatingKeyboard(accessoryViewStrategy: accessoryViewStrategy)
        let commentCreationSettings = OWCommentCreationSettings(style: commentCreationStyle)
        // Inject the settings into the toolbar VM
        toolbarVM.inputs.setCommentCreationSettings(commentCreationSettings)
        let additionalSettings = OWAdditionalSettings(commentCreationSettings: commentCreationSettings)

        uiViewsLayer.commentCreation(postId: self.postId,
                                     article: article,
                                     commentCreationType: type,
                                     additionalSettings: additionalSettings,
                                     callbacks: self.actionsCallbacks,
                                     completion: { [weak self] result in

            guard let self = self else { return }
            switch result {
            case .failure(let err):
                self._componentRetrievingError.onNext(err)
            case.success(let view):
                self._commentCreationRetrieved.onNext(view)
            }
        })
    }

    func retrieveReportReasonsComponent(commentId: OWCommentId, parentId: OWCommentId) {
        let uiViewsLayer = OpenWeb.manager.ui.views
        let additionalSettings = OWAdditionalSettings()

        uiViewsLayer.reportReason(postId: self.postId,
                                  commentId: commentId,
                                  parentId: parentId,
                                  additionalSettings: additionalSettings,
                                  callbacks: self.actionsCallbacks,
                                  completion: { [weak self] result in

            guard let self = self else { return }
            switch result {
            case .failure(let err):
                self._componentRetrievingError.onNext(err)
            case.success(let view):
                self._reportReasonsRetrieved.onNext(view)
            }
        })
    }

    func retrieveWebPageComponent() {
        // TODO: To be completed in the SDK side
    }
}

#endif
