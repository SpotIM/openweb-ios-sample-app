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

    fileprivate let _componentRetrievingError = PublishSubject<OWError>()
    var componentRetrievingError: Observable<OWError> {
        return _componentRetrievingError
            .asObservable()
    }

    fileprivate let _preConversationRetrieved = PublishSubject<UIView>()
    var preConversationRetrieved: Observable<UIView> {
        return _preConversationRetrieved
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

    fileprivate let actionsCallbacks: OWViewActionsCallbacks = { callbackType, sourceType, postId in

    }

    init(postId: OWPostId,
         commonCreatorService: CommonCreatorServicing = CommonCreatorService()) {
        self.postId = postId
        self.commonCreatorService = commonCreatorService
        setupObservers()
    }
}

fileprivate extension ConversationBelowVideoViewModel {
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
