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
    fileprivate var viewableMode: OWViewableMode!
    fileprivate let authenticationManager: OWAuthenticationManagerProtocol
    fileprivate lazy var viewActionsService: OWViewActionsServicing = {
        return OWViewActionsService(viewActionsCallbacks: actionsCallbacks, viewSourceType: .preConversation)
    }()
    fileprivate lazy var customizationsService: OWCustomizationsServicing = {
        return OWCustomizationsService(viewSourceType: .preConversation)
    }()

    init(router: OWRoutering! = nil,
         preConversationData: OWPreConversationRequiredData,
         actionsCallbacks: OWViewActionsCallbacks?,
         authenticationManager: OWAuthenticationManagerProtocol = OWSharedServicesProvider.shared.authenticationManager(),
         viewableMode: OWViewableMode) {
        self.router = router
        self.preConversationData = preConversationData
        self.actionsCallbacks = actionsCallbacks
        self.authenticationManager = authenticationManager
        self.viewableMode = viewableMode
    }

    override func start(deepLinkOptions: OWDeepLinkOptions? = nil) -> Observable<OWPreConversationCoordinatorResult> {
        // Pre conversation never will be a full screen
        return .empty()
    }

    override func showableComponent() -> Observable<OWShowable> {
        let preConversationViewVM: OWPreConversationViewViewModeling = OWPreConversationViewViewModel(preConversationData: preConversationData,
                                                                                                      viewableMode: .independent)
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
    // swiftlint:disable function_body_length
    func setupObservers(forViewModel viewModel: OWPreConversationViewViewModeling) {
    // swiftlint:enable function_body_length
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
            .filter { [weak self] _ in
                guard let self = self else { return true }
                return self.viewableMode == .partOfFlow
            }
            .flatMap { [weak self] deepLink -> Observable<OWConversationCoordinatorResult> in
                guard let self = self else { return .empty() }
                let conversationData = OWConversationRequiredData(article: self.preConversationData.article,
                                                                  settings: self.preConversationData.settings?.fullConversationSettings,
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
            .filter { [weak self] _ in
                guard let self = self else { return true }
                return self.viewableMode == .partOfFlow
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

        setupCustomizationElements(forViewModel: viewModel)

        // Coordinate to report reasons - Flow
        viewModel.outputs.openReportReason
            .filter { [weak self] _ in
                guard let self = self else { return true }
                return self.viewableMode == .partOfFlow
            }
            .flatMap { commentId -> Observable<OWReportReasonCoordinatorResult> in
                let reportReasonCoordinator = OWReportReasonCoordinator(commentId: commentId,
                                                                        router: self.router,
                                                                        actionsCallbacks: self.actionsCallbacks,
                                                                        presentationalMode: self.preConversationData.presentationalStyle)

                return self.coordinate(to: reportReasonCoordinator)
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
    }

    func setupViewActionsCallbacks(forViewModel viewModel: OWPreConversationViewViewModeling) {
        guard actionsCallbacks != nil else { return } // Make sure actions callbacks are available/provided

        let contentPressed = viewModel.outputs.openFullConversation
            .map { OWViewActionCallbackType.contentPressed }

        let openPublisherProfile = viewModel.outputs.openPublisherProfile
            .map { OWViewActionCallbackType.openPublisherProfile(userId: $0) }

        let openReportReason = viewModel.outputs.openReportReason
            .map { OWViewActionCallbackType.openReportReason(commentId: $0) }

        Observable.merge(contentPressed, openPublisherProfile, openReportReason)
            .subscribe { [weak self] viewActionType in
                self?.viewActionsService.append(viewAction: viewActionType)
            }
            .disposed(by: disposeBag)
    }

    func setupCustomizationElements(forViewModel viewModel: OWPreConversationViewViewModeling) {
        // TODO: need to complete all the customize elements

        let customizationElementsObservables = Observable.merge(
            viewModel.outputs.preConversationSummaryVM
                .outputs.customizeTitleLabelUI
                .map { OWCustomizableElement.summeryHeader(element: .title(label: $0)) },

            viewModel.outputs.preConversationSummaryVM
                .outputs.customizeCounterLabelUI
                .map { OWCustomizableElement.summeryHeader(element: .counter(label: $0)) },

            viewModel.outputs.preConversationSummaryVM
                .outputs.onlineViewingUsersVM
                .outputs.customizeIconImageUI
                .map { OWCustomizableElement.onlineUsers(element: .icon(image: $0)) },

            viewModel.outputs.preConversationSummaryVM
                .outputs.onlineViewingUsersVM
                .outputs.customizeCounterLabelUI
                .map { OWCustomizableElement.onlineUsers(element: .counter(label: $0)) },

            viewModel.outputs.commentingCTAViewModel
                .outputs.commentCreationEntryViewModel
                .outputs.customizeTitleLabelUI
                .map { OWCustomizableElement.commentCreationCTA(element: .placeholder(label: $0)) },

            viewModel.outputs.commentingCTAViewModel
                .outputs.commentCreationEntryViewModel
                .outputs.customizeContainerViewUI
                .map { OWCustomizableElement.commentCreationCTA(element: .container(view: $0)) },

//            viewModel.outputs.communityQuestionViewModel
//                .outputs.customizeQuestionLabelUI
//                .map { OWCustomizableElement.communityQuestionTitle(label: $0) },

            viewModel.outputs.communityGuidelinesViewModel
                .outputs.customizeTitleTextViewUI
                .map { OWCustomizableElement.communityGuidelines(element: .regular(textView: $0)) }

        )

        customizationElementsObservables
            .subscribe { [weak self] element in
                self?.customizationsService.trigger(customizableElement: element)
            }
            .disposed(by: disposeBag)
    }
}
