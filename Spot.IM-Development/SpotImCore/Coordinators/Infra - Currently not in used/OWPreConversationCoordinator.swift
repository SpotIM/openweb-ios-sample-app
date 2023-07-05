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

    fileprivate var reportReasonSubmittedChange = PublishSubject<OWCommentId>()
    lazy var reportReasonSubmitted: Observable<OWCommentId> = {
        return reportReasonSubmittedChange
            .asObservable()
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
                let commentCreationData = OWCommentCreationRequiredData(article: self.preConversationData.article,
                                                                        settings: self.preConversationData.settings,
                                                                        commentCreationType: type,
                                                                        presentationalStyle: self.preConversationData.presentationalStyle)
                return OWDeepLinkOptions.commentCreation(commentCreationData: commentCreationData)
            }

        let openReportReasonObservable: Observable<OWDeepLinkOptions?> = viewModel.outputs.openReportReason
            .map { [weak self] _ -> OWDeepLinkOptions? in
                guard let self = self else { return nil }
                return .reportReason(reportReasonSubmitted: self.reportReasonSubmitted)
            }

        reportReasonSubmitted
            .bind(to: viewModel.inputs.reportComment)
            .disposed(by: disposeBag)

        // Coordinate to full conversation
        Observable.merge(openFullConversationObservable,
                         openCommentCreationObservable,
                         openReportReasonObservable)
            .filter { [weak self] _ in
                guard let self = self else { return true }
                return self.viewableMode == .partOfFlow
            }
            .flatMap { [weak self] deepLink -> Observable<OWConversationCoordinatorResult> in
                guard let self = self else { return .empty() }
                let conversationData = OWConversationRequiredData(article: self.preConversationData.article,
                                                                  settings: self.preConversationData.settings,
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
        let reportReasonCoordinatorObserver = viewModel.outputs.openReportReason
            .filter { [weak self] _ in
                guard let self = self else { return true }
                return self.viewableMode == .partOfFlow
            }
            .map { [weak self] commentVM -> OWReportReasonCoordinator? in
                guard let self = self,
                      let commentId = commentVM.outputs.comment.id,
                      let parentId = commentVM.outputs.comment.parentId else { return nil }
                return OWReportReasonCoordinator(commentId: commentId,
                                                 parentId: parentId,
                                                 router: self.router,
                                                 actionsCallbacks: self.actionsCallbacks,
                                                 presentationalMode: self.preConversationData.presentationalStyle)

            }
            .unwrap()
            .asObservable()
            .share()

        reportReasonCoordinatorObserver
            .flatMap { [weak self] reportReasonCoordinator -> Observable<OWReportReasonCoordinatorResult> in
                guard let self = self else { return .empty() }
                return self.coordinate(to: reportReasonCoordinator)
            }
            .do(onNext: { [weak self] coordinatorResult in
                guard let self = self else { return }
                switch coordinatorResult {
                case .popped:
                    self._dissmissConversation.onNext()
                case .submitedReport(let commentId):
                    reportReasonSubmittedChange.onNext(commentId)
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
            .map { commentVM -> OWViewActionCallbackType in
                guard let commentId = commentVM.outputs.comment.id,
                      let parentId = commentVM.outputs.comment.parentId else { return .error(.reportReasonFlow) }
                return OWViewActionCallbackType.openReportReason(commentId: commentId, parentId: parentId)
            }

        Observable.merge(contentPressed,
                         openPublisherProfile,
                         openReportReason)
            .subscribe(onNext: { [weak self] viewActionType in
                self?.viewActionsService.append(viewAction: viewActionType)
            })
            .disposed(by: disposeBag)
    }

    func setupCustomizationElements(forViewModel viewModel: OWPreConversationViewViewModeling) {
        // Set customized pre conversation summary header
        let summaryHeaderCustomizeTitle = viewModel.outputs.preConversationSummaryVM
            .outputs.customizeTitleLabelUI
            .map { OWCustomizableElement.summaryHeader(element: .title(label: $0)) }

        let summaryHeaderCustomizeCounter = viewModel.outputs.preConversationSummaryVM
            .outputs.customizeCounterLabelUI
            .map { OWCustomizableElement.summaryHeader(element: .counter(label: $0)) }

        let summaryHeaderCustomizeOnlineUsersIcon = viewModel.outputs.preConversationSummaryVM
            .outputs.onlineViewingUsersVM
            .outputs.customizeIconImageUI
            .map { OWCustomizableElement.onlineUsers(element: .icon(image: $0)) }

        let summaryHeaderCustomizeOnlineUsersCounter = viewModel.outputs.preConversationSummaryVM
            .outputs.onlineViewingUsersVM
            .outputs.customizeCounterLabelUI
            .map { OWCustomizableElement.onlineUsers(element: .counter(label: $0)) }

        let summaryCustomizationElementsObservable = Observable.merge(summaryHeaderCustomizeTitle,
                                                                      summaryHeaderCustomizeCounter,
                                                                      summaryHeaderCustomizeOnlineUsersIcon,
                                                                      summaryHeaderCustomizeOnlineUsersCounter)

        // Set customized community question
        let communityQuestionCustomizeContainer = viewModel.outputs.communityQuestionViewModel
            .outputs.customizeQuestionContainerViewUI

        let communityQuestionCustomizeTitleLabel = viewModel.outputs.communityQuestionViewModel
            .outputs.customizeQuestionTitleLabelUI

        let communityQuestionCustomizeTitleTextView = viewModel.outputs.communityQuestionViewModel
            .outputs.customizeQuestionTitleTextViewUI

        let communityQuestionStyle = viewModel.outputs.communityQuestionViewModel
            .outputs.style

        let communityQuestionCustomizationElementObservable = Observable.combineLatest(communityQuestionCustomizeContainer,
                                                                                    communityQuestionCustomizeTitleLabel,
                                                                                    communityQuestionCustomizeTitleTextView)
            .flatMap { container, titleLabel, titleTextView in
                switch communityQuestionStyle {
                case .regular:
                    return Observable.just(OWCustomizableElement.communityQuestion(element: .regular(textView: titleTextView)))
                case .compact:
                    return Observable.just(OWCustomizableElement.communityQuestion(element: .compact(containerView: container, label: titleLabel)))
                case .none:
                    return .empty()
                }
            }

        // Set customized community guidelines
        let communityGuidelinesCustomizeContainer = viewModel.outputs.communityGuidelinesViewModel
            .outputs.customizeContainerViewUI

        let communityGuidelinesCustomizeTitle = viewModel.outputs.communityGuidelinesViewModel
            .outputs.customizeTitleTextViewUI

        let communityGuidelinesCustomizeIcon = viewModel.outputs.communityGuidelinesViewModel
            .outputs.customizeIconImageViewUI

        let communityGuidelinesStyle = viewModel.outputs.communityGuidelinesViewModel
            .outputs.style

        let communityGuidelinesCustomizationElementObservable = Observable.combineLatest(communityGuidelinesCustomizeContainer,
                                                                                      communityGuidelinesCustomizeIcon,
                                                                                      communityGuidelinesCustomizeTitle)
            .flatMap { container, icon, title in
                switch communityGuidelinesStyle {
                case .regular:
                    return Observable.just(OWCustomizableElement.communityGuidelines(element: .regular(textView: title)))
                case .compact:
                    return Observable.just(OWCustomizableElement.communityGuidelines(element: .compact(containerView: container, icon: icon, textView: title)))
                case .none:
                    return .empty()
                }
            }

        // Commenting CTA

        let commentingCTAViewModel = viewModel.outputs.commentingCTAViewModel

        // Set customized comment creation

        let commentCreationEntryCustomizeContainer = commentingCTAViewModel
            .outputs.commentCreationEntryViewModel
            .outputs.customizeContainerViewUI
            .map { OWCustomizableElement.commentCreationCTA(element: .container(view: $0)) }

        let commentCreationEntryCustomizeTitle = commentingCTAViewModel
            .outputs.commentCreationEntryViewModel
            .outputs.customizeTitleLabelUI
            .map { OWCustomizableElement.commentCreationCTA(element: .placeholder(label: $0)) }

        let commentCreationEntryCustomizationElementsObservable = Observable.merge(commentCreationEntryCustomizeContainer,
                                                                                   commentCreationEntryCustomizeTitle)

        // Set customized commenting read only

        let commentingReadOnlyCustomizeIcon = commentingCTAViewModel
            .outputs.commentingReadOnlyViewModel
            .outputs.customizeIconImageViewUI
            .map { OWCustomizableElement.commentingEnded(element: .icon(image: $0)) }

        let commentingReadOnlyCustomizeTitle = commentingCTAViewModel
            .outputs.commentingReadOnlyViewModel
            .outputs.customizeTitleLabelUI
            .map { OWCustomizableElement.commentingEnded(element: .title(label: $0)) }

        let commentingReadOnlyCustomizationElementsObservable = Observable.merge(commentingReadOnlyCustomizeIcon,
                                                                                 commentingReadOnlyCustomizeTitle)

        let customizationElementsObservables = Observable.merge(summaryCustomizationElementsObservable,
                                                                communityQuestionCustomizationElementObservable,
                                                                communityGuidelinesCustomizationElementObservable,
                                                                commentCreationEntryCustomizationElementsObservable,
                                                                commentingReadOnlyCustomizationElementsObservable)

        customizationElementsObservables
            .subscribe { [weak self] element in
                self?.customizationsService.trigger(customizableElement: element)
            }
            .disposed(by: disposeBag)
    }
}
