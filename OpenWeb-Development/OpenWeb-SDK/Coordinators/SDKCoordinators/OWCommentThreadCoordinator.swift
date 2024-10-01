//
//  OWCommentThreadCoordinator.swift
//  OpenWebSDK
//
//  Created by Alon Shprung on 27/02/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation
import RxSwift

enum OWCommentThreadCoordinatorResult: OWCoordinatorResultProtocol {
    case popped
    case loadedToScreen

    var loadedToScreen: Bool {
        switch self {
        case .loadedToScreen:
            return true
        default:
            return false
        }
    }
}

class OWCommentThreadCoordinator: OWBaseCoordinator<OWCommentThreadCoordinatorResult> {

    // Router is being used only for `Flows` mode. Intentionally defined as force unwrap for easy access.
    // Trying to use that in `Standalone Views` mode will cause a crash immediately.
    private let router: OWRoutering!
    private let commentThreadData: OWCommentThreadRequiredData
    private let viewActionsCallbacks: OWViewActionsCallbacks?
    private let flowActionsCallbacks: OWFlowActionsCallbacks?
    private let servicesProvider: OWSharedServicesProviding
    private var viewableMode: OWViewableMode!
    private lazy var viewActionsService: OWViewActionsServicing = {
        return OWViewActionsService(viewActionsCallbacks: viewActionsCallbacks, viewSourceType: .commentThread)
    }()
    private lazy var flowActionsService: OWFlowActionsServicing = {
        return OWFlowActionsService(flowActionsCallbacks: flowActionsCallbacks, viewSourceType: .commentThread)
    }()
    private lazy var customizationsService: OWCustomizationsServicing = {
        return OWCustomizationsService(viewSourceType: .commentThread)
    }()

    private var commentThreadVC: OWCommentThreadVC?

    init(router: OWRoutering! = nil,
         commentThreadData: OWCommentThreadRequiredData,
         viewActionsCallbacks: OWViewActionsCallbacks?,
         flowActionsCallbacks: OWFlowActionsCallbacks?,
         servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.router = router
        self.commentThreadData = commentThreadData
        self.viewActionsCallbacks = viewActionsCallbacks
        self.flowActionsCallbacks = flowActionsCallbacks
        self.servicesProvider = servicesProvider
    }

    // swiftlint:disable function_body_length
    override func start(coordinatorData: OWCoordinatorData? = nil) -> Observable<OWCommentThreadCoordinatorResult> {
        viewableMode = .partOfFlow
        let commentThreadVM: OWCommentThreadViewModeling = OWCommentThreadViewModel(commentThreadData: commentThreadData, viewableMode: viewableMode)
        let commentThreadVC = OWCommentThreadVC(viewModel: commentThreadVM)
        self.commentThreadVC = commentThreadVC

        let commentThreadPopped = PublishSubject<Void>()

        router.push(commentThreadVC,
                    pushStyle: .present,
                    animated: true,
                    popCompletion: commentThreadPopped)

        setupObservers(forViewModel: commentThreadVM)
        setupFlowActionsCallbacks(forViewModel: commentThreadVM)

        let commentThreadPoppedObservable = commentThreadPopped
            .map { OWCommentThreadCoordinatorResult.popped }
            .asObservable()

        let commentThreadLoadedToScreenObservable = commentThreadVM.outputs.loadedToScreen
            .map { OWCommentThreadCoordinatorResult.loadedToScreen }
            .asObservable()

        // Coordinate to comment creation
        let coordinateCommentCreationObservable = commentThreadVM.outputs.commentThreadViewVM.outputs.openCommentCreation
            .flatMapLatest { [weak self] commentCreationType -> Observable<OWCommentCreationCoordinatorResult> in
                guard let self = self else { return .empty() }
                let commentCreationData = OWCommentCreationRequiredData(article: self.commentThreadData.article,
                                                                        settings: self.commentThreadData.settings,
                                                                        commentCreationType: commentCreationType,
                                                                        presentationalStyle: self.commentThreadData.presentationalMode)
                let commentCreationCoordinator = OWCommentCreationCoordinator(router: self.router,
                                                                              commentCreationData: commentCreationData,
                                                                              viewActionsCallbacks: self.viewActionsCallbacks)
                return self.coordinate(to: commentCreationCoordinator)
            }
            .do(onNext: { result in
                switch result {
                case .commentCreated:
                    // TODO: We will probably would like to push this comment to the table view with a nice highlight animation
                    break
                case .loadedToScreen:
                    break
                    // Nothing
                case .popped:
                    break
                case .userLoggedInWhileWritingReplyToComment(let commentId):
                    commentThreadVM.outputs.commentThreadViewVM.inputs.performAction.onNext((commentId, .reply))
                }
            })
            .flatMap { _ -> Observable<OWCommentThreadCoordinatorResult> in
                return Observable.never()
            }

        let reportReasonFromCommentThreadObservable = commentThreadVM.outputs.commentThreadViewVM
            .outputs.openReportReason
            .map { commentVM -> OWReportReasonsRequiredData? in
                guard let commentId = commentVM.outputs.comment.id,
                    let parentId = commentVM.outputs.comment.parentId else {
                    return nil
                }

                return OWReportReasonsRequiredData(commentId: commentId, parentId: parentId)
            }
            .unwrap()

        // Coordinate to report reason
        let coordinateReportReasonObservable = reportReasonFromCommentThreadObservable
            .asObservable()
            .filter { [weak self] _ in
                guard let self = self else { return false }
                return self.viewableMode == .partOfFlow
            }
            .flatMap { [weak self] reportData -> Observable<OWReportReasonCoordinatorResult> in
                guard let self = self else { return .empty() }
                let reportReasonCoordinator = OWReportReasonCoordinator(reportData: reportData,
                                                                        router: self.router,
                                                                        viewActionsCallbacks: self.viewActionsCallbacks,
                                                                        presentationalMode: self.commentThreadData.presentationalMode)
                return self.coordinate(to: reportReasonCoordinator)
            }
            .do(onNext: { coordinatorResult in
                switch coordinatorResult {
                case .popped:
                    // Nothing
                    break
                case .submitedReport:
                    // Nothing - already taken care in report VM in which we update the report service
                    break
                default:
                    break
                }
            })
            .flatMap { _ -> Observable<OWCommentThreadCoordinatorResult> in
                return Observable.never()
            }

        let clarityDetailsFromCommentThreadObservable = commentThreadVM.outputs.commentThreadViewVM.outputs.openClarityDetails

        // Coordinate to clarity details
        let coordinateClarityDetailsObservable = clarityDetailsFromCommentThreadObservable
            .asObservable()
            .filter { [weak self] _ in
                guard let self = self else { return false }
                return self.viewableMode == .partOfFlow
            }
            .flatMap { [weak self] data -> Observable<OWClarityDetailsCoordinatorResult> in
                guard let self = self else { return .empty() }
                let clarityDetailsCoordinator = OWClarityDetailsCoordinator(data: data,
                                                                            router: self.router,
                                                                            viewActionsCallbacks: self.viewActionsCallbacks,
                                                                            presentationalMode: self.commentThreadData.presentationalMode)
                return self.coordinate(to: clarityDetailsCoordinator)
            }
            .do(onNext: { coordinatorResult in
                switch coordinatorResult {
                case .popped:
                    // Nothing
                    break
                default:
                    break
                }
            })
            .flatMap { _ -> Observable<OWCommentThreadCoordinatorResult> in
                return Observable.never()
            }

        // Coordinate to safari tab
        let coordinateToSafariObservables = Observable.merge(
            commentThreadVM.outputs.commentThreadViewVM.outputs.urlClickedOutput.map { ($0, "") },
            commentThreadVM.outputs.commentThreadViewVM.outputs.openProfile.map {
                if case .OWProfile(let data) = $0 {
                    return (data.url, OWLocalizationManager.shared.localizedString(key: "ProfileTitle"))
                } else {
                    return nil
                }
            }
                .unwrap()
        )
            .flatMap { [weak self] tuple -> Observable<OWWebTabCoordinatorResult> in
                guard let self = self else { return .empty() }
                let url = tuple.0
                let title = tuple.1
                let options = OWWebTabOptions(url: url,
                                                 title: title)
                let safariCoordinator = OWWebTabCoordinator(router: self.router,
                                                                   options: options,
                                                                   viewActionsCallbacks: self.viewActionsCallbacks)
                return self.coordinate(to: safariCoordinator, coordinatorData: nil)
            }
            .flatMap { _ -> Observable<OWCommentThreadCoordinatorResult> in
                return Observable.never()
            }

        return Observable.merge(commentThreadPoppedObservable,
                                commentThreadLoadedToScreenObservable,
                                coordinateCommentCreationObservable,
                                coordinateToSafariObservables,
                                coordinateReportReasonObservable,
                                coordinateClarityDetailsObservable)
    }
    // swiftlint:enable function_body_length

    override func showableComponent() -> Observable<OWShowable> {
        viewableMode = .independent
        let commentThreadViewVM: OWCommentThreadViewViewModeling = OWCommentThreadViewViewModel(commentThreadData: commentThreadData, viewableMode: viewableMode)
        let commentThreadView = OWCommentThreadView(viewModel: commentThreadViewVM)
        setupObservers(forViewModel: commentThreadViewVM)
        setupViewActionsCallbacks(forViewModel: commentThreadViewVM)
        return .just(commentThreadView)
    }
}

private extension OWCommentThreadCoordinator {
    func setupObservers(forViewModel viewModel: OWCommentThreadViewModeling) {
        // Setting up general observers which affect app flow however not entirely inside the SDK
        setupObservers(forViewModel: viewModel.outputs.commentThreadViewVM)
    }

    func setupFlowActionsCallbacks(forViewModel viewModel: OWCommentThreadViewModeling) {
        guard flowActionsCallbacks != nil else { return } // Make sure actions callbacks are available/provided

        let openPublisherProfile = viewModel.outputs.commentThreadViewVM.outputs.openProfile
            .map { [weak self] openProfileType -> OWFlowActionCallbackType? in
                guard let self = self else { return nil }
                return self.flowActionsService.getOpenProfileActionCallback(for: self.commentThreadVC?.navigationController,
                                                                            openProfileType: openProfileType,
                                                                            presentationalModeCompact: self.commentThreadData.presentationalMode)
            }
            .unwrap()
            .asObservable()

        Observable.merge(openPublisherProfile)
            .subscribe { [weak self] flowActionType in
                self?.flowActionsService.append(flowAction: flowActionType)
            }
            .disposed(by: disposeBag)
    }

    func setupObservers(forViewModel viewModel: OWCommentThreadViewViewModeling) {
        let actionsCallbacksNotifier = self.servicesProvider.actionsCallbacksNotifier()

        actionsCallbacksNotifier.openCommentThread
            .filter { [weak self] _ in
                guard let self = self else { return false }
                return self.viewableMode == .partOfFlow
            }
            .subscribe(onNext: { commentId, performActionType in
                viewModel.inputs.performAction.onNext((commentId, performActionType))
            })
            .disposed(by: disposeBag)
    }

    func setupViewActionsCallbacks(forViewModel viewModel: OWCommentThreadViewViewModeling) {
        guard viewActionsCallbacks != nil else { return } // Make sure actions callbacks are available/provided

        // Close Comment Thread
        let closeCommentThread = viewModel
            .outputs.closeCommentThread
            .map { OWViewActionCallbackType.closeCommentThread }

        let openPublisherProfile = viewModel.outputs.openProfile
            .map { openProfileType in
                switch openProfileType {
                case .OWProfile(let data):
                    return OWViewActionCallbackType.openOWProfile(data: data)
                case .publisherProfile(let ssoPublisherId, let type):
                    return OWViewActionCallbackType.openPublisherProfile(ssoPublisherId: ssoPublisherId, type: type)
                }
            }
            .asObservable()

        // Open comment creation
        let openCommentCreation = viewModel.outputs.openCommentCreation
            .map { internalType -> OWCommentCreationType in
                switch internalType {
                case .comment:
                    return OWCommentCreationType.comment
                case .replyToComment(let originComment):
                    return .replyTo(commentId: originComment.id ?? "")
                case .edit(let comment):
                    return .edit(commentId: comment.id ?? "")
                }
            }
            .map { OWViewActionCallbackType.openCommentCreation(type: $0) }

        // Open clarity details
        let openClarityDetails = viewModel.outputs.openClarityDetails
            .map { OWViewActionCallbackType.openClarityDetails(data: $0) }

        // Open report reason
        let openReportReason = viewModel.outputs.openReportReason
            .map { commentVM -> OWViewActionCallbackType in
                guard let commentId = commentVM.outputs.comment.id,
                      let parentId = commentVM.outputs.comment.parentId else { return .error(.reportReasonFlow) }
                return OWViewActionCallbackType.openReportReason(commentId: commentId, parentId: parentId)
            }

        // Open URL in comment
        let openUrlInComment = viewModel.outputs.urlClickedOutput
            .map { OWViewActionCallbackType.openLinkInComment(url: $0) }

        Observable.merge(closeCommentThread,
                         openPublisherProfile,
                         openCommentCreation,
                         openClarityDetails,
                         openReportReason,
                         openUrlInComment)
            .subscribe { [weak self] viewActionType in
                self?.viewActionsService.append(viewAction: viewActionType)
            }
            .disposed(by: disposeBag)
    }
}
