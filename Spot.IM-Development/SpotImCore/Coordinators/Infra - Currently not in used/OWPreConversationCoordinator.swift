//
//  OWPreConversationCoordinator.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 07/09/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift

enum OWPreConversationCoordinatorResult: OWCoordinatorResultProtocol {
    case never
    
    var loadedToScreen: Bool {
        return false
    }
}

class OWPreConversationCoordinator: OWBaseCoordinator<OWPreConversationCoordinatorResult> {
    
    fileprivate let router: OWRoutering
    fileprivate let preConversationData: OWPreConversationRequiredData
    fileprivate let actionsCallbacks: OWViewActionsCallbacks?

    init(router: OWRoutering, preConversationData: OWPreConversationRequiredData, actionsCallbacks: OWViewActionsCallbacks?) {
        self.router = router
        self.preConversationData = preConversationData
        self.actionsCallbacks = actionsCallbacks
    }
    
    override func start(deepLinkOptions: OWDeepLinkOptions? = nil) -> Observable<OWPreConversationCoordinatorResult> {
        // TODO: complete the flow
//        let conversationVM: OWConversationViewModeling = OWConversationViewModel()
//        let conversationVC = OWConversationVC(viewModel: conversationVM)
        return .empty()
    }
    
    override func showableComponentDynamicSize() -> Observable<OWViewDynamicSizeOption> {
        let preConversationViewVM: OWPreConversationViewViewModeling = OWPreConversationViewViewModel(preConversationData: preConversationData)
        let preConversationView = OWPreConversationView(viewModel: preConversationViewVM)
        
        setupObservers(forViewModel: preConversationViewVM)
        setupViewActionsCallbacks(forViewModel: preConversationViewVM)
        
        let viewDynamicSizeObservable: Observable<(UIView, CGSize)> = Observable.just(preConversationView)
            .flatMap { [weak preConversationViewVM] view -> Observable<(UIView, CGSize)> in
                guard let viewModel = preConversationViewVM else { return .never() }
                return viewModel.outputs.preConversationPreferredSize
                    .map { (view, $0) }
            }
            .share(replay: 1)
            .asObservable()
        
        let initial = viewDynamicSizeObservable
            .take(1)
            .map { OWViewDynamicSizeOption.viewInitialSize(view: $0.0, initialSize: $0.1) }

        let updateSize = viewDynamicSizeObservable
            .skip(1)
            .map { OWViewDynamicSizeOption.updateSize(view: $0.0, newSize: $0.1) }

        return Observable.merge(initial, updateSize)
    }
}

fileprivate extension OWPreConversationCoordinator {
    func setupObservers(forViewModel viewModel: OWPreConversationViewViewModeling) {
        
        let openFullConversationObservable: Observable<OWDeepLinkOptions?> = viewModel.outputs.openFullConversation
            .map { _ -> OWDeepLinkOptions? in
                return nil
            }
        
        let openCommentConversationObservable: Observable<OWDeepLinkOptions?> = viewModel.outputs.openCommentConversation
            .map { [weak self] _ -> OWDeepLinkOptions? in
                guard let self = self else { return nil }
                let commentCreationData = OWCommentCreationRequiredData(article: self.preConversationData.article)
                return OWDeepLinkOptions.commentCreation(commentCreationData: commentCreationData)
            }
        
        // Coordinate to full conversation
        Observable.merge(openFullConversationObservable, openCommentConversationObservable)
            .flatMap { [weak self] deepLink -> Observable<OWConversationCoordinatorResult> in
                guard let self = self else { return .empty() }
                let conversationData = OWConversationRequiredData(article: self.preConversationData.article,
                                                                  settings: nil)
                let conversationCoordinator = OWConversationCoordinator(router: self.router,
                                                                           conversationData: conversationData,
                                                                           actionsCallbacks: self.actionsCallbacks)
                return self.coordinate(to: conversationCoordinator, deepLinkOptions: deepLink)
            }
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    func setupViewActionsCallbacks(forViewModel viewModel: OWPreConversationViewViewModeling) {
        // TODO: complete binding VM to actions callbacks
    }
}
