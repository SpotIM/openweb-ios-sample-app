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
    fileprivate var _dissmissConversation = PublishSubject<Void>()
    var dissmissConversation: Observable<Void> {
        return _dissmissConversation.asObservable()
    }

    // Router is being used only for `Flows` mode. Intentionally defined as force unwrap for easy access.
    // Trying to use that in `Standalone Views` mode will cause a crash immediately.
    fileprivate var router: OWRoutering!
    fileprivate let preConversationData: OWPreConversationRequiredData
    fileprivate let actionsCallbacks: OWViewActionsCallbacks?
    fileprivate let authenticationManager: OWAuthenticationManagerProtocol
    fileprivate lazy var viewActionsService: OWViewActionsServicing = {
        return OWViewActionsService(viewActionsCallbacks: actionsCallbacks, viewSourceType: .preConversation)
    }()
    fileprivate lazy var customizationsService: OWCustomizationsServicing = {
        return OWCustomizationsService(viewSourceType: .preConversation)
    }()

    // TODO: Remove this temporarily easy soultion once Revital merge her PR with `ViewableMode`
    fileprivate var isStandaloneMode: Bool

    init(router: OWRoutering! = nil,
         preConversationData: OWPreConversationRequiredData,
         actionsCallbacks: OWViewActionsCallbacks?,
         authenticationManager: OWAuthenticationManagerProtocol = OWSharedServicesProvider.shared.authenticationManager()) {
        self.router = router

        // TODO: An easy soultion just to prevent crashes in standalone mode until Revital will merge the `ViewableMode` enum in the branch she's working on
        isStandaloneMode = router == nil

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
        let preConversationViewVM: OWPreConversationViewViewModeling = OWPreConversationViewViewModel(preConversationData: preConversationData,
                                                                                                      viewableMode: .independent)
        let preConversationView = OWPreConversationView(viewModel: preConversationViewVM)

        // TODO: Remove this temporarily easy soultion once Revital merge her PR with `ViewableMode`
//        if !isStandaloneMode {
            setupObservers(forViewModel: preConversationViewVM)
//        }

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

        let openCommentCreationObservable: Observable<OWDeepLinkOptions?> = viewModel.outputs.openCommentCreation
            .observe(on: MainScheduler.instance)
            .map { [weak self] type -> OWDeepLinkOptions? in
                // 3. Perform deeplink to comment creation screen
                guard let self = self else { return nil }
                let commentCreationData = OWCommentCreationRequiredData(article: self.preConversationData.article, commentCreationType: type)
                return OWDeepLinkOptions.commentCreation(commentCreationData: commentCreationData)
            }

        // Coordinate to full conversation
        Observable.merge(openFullConversationObservable, openCommentCreationObservable)
            .filter { [weak self] _ in // TODO: change to viewable mode
                guard let self = self else { return true }
                return !self.isStandaloneMode
            }
            .flatMap { [weak self] deepLink -> Observable<OWConversationCoordinatorResult> in
                guard let self = self else { return .empty() }
                let conversationData = OWConversationRequiredData(article: self.preConversationData.article,
                                                                  settings: nil,
                                                                  presentationalStyle: self.preConversationData.presentationalStyle)
                let conversationCoordinator = OWConversationCoordinator(router: self.router,
                                                                           conversationData: conversationData,
                                                                           actionsCallbacks: self.actionsCallbacks)
                return self.coordinate(to: conversationCoordinator, deepLinkOptions: deepLink)
            }
            .do(onNext: { [weak self] coordinatorResult in
                guard let self = self else { return }
                switch coordinatorResult {
                case .popped:
                    self._dissmissConversation.onNext()
                default:
                    break
                }
            })
            .subscribe()
            .disposed(by: disposeBag)

        // Coordinate to safari tab
        let coordinateToSafariObservables = Observable.merge(
            viewModel.outputs.communityGuidelinesViewModel.outputs.urlClickedOutput,
            viewModel.outputs.urlClickedOutput,
            viewModel.outputs.footerViewViewModel.outputs.urlClickedOutput,
            viewModel.outputs.openProfile
        )

        coordinateToSafariObservables
            .filter { [weak self] _ in // TODO: change to viewable mode
                guard let self = self else { return true }
                return !self.isStandaloneMode
            }
            .flatMap { [weak self] url -> Observable<OWSafariTabCoordinatorResult> in
                guard let self = self else { return .empty() }
                    let safariCoordinator = OWSafariTabCoordinator(router: self.router,
                                                                   url: url,
                                                                   actionsCallbacks: self.actionsCallbacks)
                return self.coordinate(to: safariCoordinator, deepLinkOptions: .none)
            }
            .subscribe()
            .disposed(by: disposeBag)

        let customizationElementsObservables = Observable.merge(
            viewModel.outputs.preConversationSummaryVM
                .outputs.customizeTitleLabelUI
                .map { OWCustomizableElement.headerTitle(label: $0) },
            viewModel.outputs.preConversationSummaryVM
                .outputs.customizeCounterLabelUI
                .map { OWCustomizableElement.headerCounter(label: $0) }
        )

        customizationElementsObservables
            .subscribe { [weak self] element in
                self?.customizationsService.trigger(customizableElement: element)
            }
            .disposed(by: disposeBag)
    }

    func setupViewActionsCallbacks(forViewModel viewModel: OWPreConversationViewViewModeling) {
        guard actionsCallbacks != nil else { return } // Make sure actions callbacks are available/provided

        let contentPressed = viewModel.outputs.openFullConversation
            .map { OWViewActionCallbackType.contentPressed }

        let openPublisherProfile = viewModel.outputs.openPublisherProfile
            .map { OWViewActionCallbackType.openPublisherProfile(userId: $0) }

        Observable.merge(contentPressed, openPublisherProfile)
            .subscribe { [weak self] viewActionType in
                self?.viewActionsService.append(viewAction: viewActionType)
            }
            .disposed(by: disposeBag)
    }
}
