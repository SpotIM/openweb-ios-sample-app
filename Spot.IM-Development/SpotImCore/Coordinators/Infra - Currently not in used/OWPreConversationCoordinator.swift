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
    fileprivate let authenticationManager: OWAuthenticationManagerProtocol

    init(router: OWRoutering,
         preConversationData: OWPreConversationRequiredData,
         actionsCallbacks: OWViewActionsCallbacks?,
         authenticationManager: OWAuthenticationManagerProtocol = OWSharedServicesProvider.shared.authenticationManager()) {
        self.router = router
        self.preConversationData = preConversationData
        self.actionsCallbacks = actionsCallbacks
        self.authenticationManager = authenticationManager
    }

    override func start(deepLinkOptions: OWDeepLinkOptions? = nil) -> Observable<OWPreConversationCoordinatorResult> {
        // TODO: complete the flow
//        let conversationVM: OWConversationViewModeling = OWConversationViewModel()
//        let conversationVC = OWConversationVC(viewModel: conversationVM)
        return .empty()
    }

    override func showableComponent() -> Observable<OWShowable> {
        let preConversationViewVM: OWPreConversationViewViewModeling = OWPreConversationViewViewModel(preConversationData: preConversationData)
        let preConversationView = OWPreConversationView(viewModel: preConversationViewVM)

        setupObservers(forViewModel: preConversationViewVM)
        setupViewActionsCallbacks(forViewModel: preConversationViewVM)

        let viewObservable: Observable<OWShowable> = Observable.just(preConversationView)
            .map { $0 as OWShowable}
            .asObservable()

        return viewObservable
    }
}

fileprivate extension OWPreConversationCoordinator {
    func setupObservers(forViewModel viewModel: OWPreConversationViewViewModeling) {

        let openFullConversationObservable: Observable<OWDeepLinkOptions?> = viewModel.outputs.openFullConversation
            .map { _ -> OWDeepLinkOptions? in
                return nil
            }

        let openCommentConversationObservable: Observable<OWDeepLinkOptions?> = viewModel.outputs.openCommentConversation
            .flatMapLatest { [weak self] type -> Observable<OWCommentCreationType> in
                // 1. Triggering authentication UI if needed
                guard let self = self else { return .empty() }
                return self.authenticationManager.ifNeededTriggerAuthenticationUI(for: .commenting)
                    .map { _ in type }
            }
            .flatMapLatest { [weak self] type -> Observable<OWCommentCreationType> in
                // 2. Waiting for authentication required for commenting
                // Can be immediately if anyone can comment in the active spotId, or the user already connected
                guard let self = self else { return .empty() }
                return self.authenticationManager.waitForAuthentication(for: .commenting)
                    .map { _ in type }
            }
            .observe(on: MainScheduler.instance)
            .map { [weak self] type -> OWDeepLinkOptions? in
                // 3. Perform deeplink to comment creation screen
                guard let self = self else { return nil }
                let commentCreationData = OWCommentCreationRequiredData(article: self.preConversationData.article, commentCreationType: type)
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

        let openSafariViewControllerObservable: Observable<URL> = viewModel.outputs.communityGuidelinesViewModel
            .outputs.urlClickedOutput

        // Coordinate to safari tab
        Observable.merge(
            viewModel.outputs.communityGuidelinesViewModel.outputs.urlClickedOutput,
            viewModel.outputs.urlClickedOutput,
            viewModel.outputs.footerViewViewModel.outputs.urlClickedOutput
        )
            .flatMap { [weak self] url -> Observable<OWSafariTabCoordinatorResult> in
                guard let self = self else { return .empty() }
                    let safariCoordinator = OWSafariTabCoordinator(router: self.router,
                                                                   url: url,
                                                                   actionsCallbacks: self.actionsCallbacks)
                return self.coordinate(to: safariCoordinator, deepLinkOptions: .none)
            }
            .subscribe()
            .disposed(by: disposeBag)
    }

    func setupViewActionsCallbacks(forViewModel viewModel: OWPreConversationViewViewModeling) {
        // TODO: complete binding VM to actions callbacks
    }
}
