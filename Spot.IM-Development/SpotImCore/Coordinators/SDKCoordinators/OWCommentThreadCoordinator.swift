//
//  OWCommentThreadCoordinator.swift
//  SpotImCore
//
//  Created by Alon Shprung on 27/02/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
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
    fileprivate let router: OWRoutering!
    fileprivate let commentThreadData: OWCommentThreadRequiredData
    fileprivate let actionsCallbacks: OWViewActionsCallbacks?
    fileprivate var viewableMode: OWViewableMode!
    fileprivate lazy var viewActionsService: OWViewActionsServicing = {
        return OWViewActionsService(viewActionsCallbacks: actionsCallbacks, viewSourceType: .commentThread)
    }()
    fileprivate lazy var customizationsService: OWCustomizationsServicing = {
        return OWCustomizationsService(viewSourceType: .commentThread)
    }()

    init(router: OWRoutering! = nil, commentThreadData: OWCommentThreadRequiredData, actionsCallbacks: OWViewActionsCallbacks?) {
        self.router = router
        self.commentThreadData = commentThreadData
        self.actionsCallbacks = actionsCallbacks
    }

    // swiftlint:disable function_body_length
    override func start(deepLinkOptions: OWDeepLinkOptions? = nil) -> Observable<OWCommentThreadCoordinatorResult> {
        viewableMode = .partOfFlow
        let commentThreadVM: OWCommentThreadViewModeling = OWCommentThreadViewModel(commentThreadData: commentThreadData, viewableMode: viewableMode)
        let commentThreadVC = OWCommentThreadVC(viewModel: commentThreadVM)

        let commentThreadPopped = PublishSubject<Void>()

        router.push(commentThreadVC,
                    pushStyle: .present,
                    animated: true,
                    popCompletion: commentThreadPopped)

        setupObservers(forViewModel: commentThreadVM)
        setupViewActionsCallbacks(forViewModel: commentThreadVM)

        let commentThreadPoppedObservable = commentThreadPopped
            .map { OWCommentThreadCoordinatorResult.popped }
            .asObservable()

        let commentThreadLoadedToScreenObservable = commentThreadVM.outputs.loadedToScreen
            .map { OWCommentThreadCoordinatorResult.loadedToScreen }
            .asObservable()

        // Coordinate to comment creation
        let coordinateCommentCreationObservable = commentThreadVM.outputs.commentThreadViewVM.outputs.openCommentCreation
            .flatMap { [weak self] commentCreationType -> Observable<OWCommentCreationCoordinatorResult> in
                guard let self = self else { return .empty() }
                let commentCreationData = OWCommentCreationRequiredData(article: self.commentThreadData.article,
                                                                        settings: self.commentThreadData.settings,
                                                                        commentCreationType: commentCreationType,
                                                                        presentationalStyle: self.commentThreadData.presentationalStyle)
                let commentCreationCoordinator = OWCommentCreationCoordinator(router: self.router,
                                                                              commentCreationData: commentCreationData,
                                                                              actionsCallbacks: self.actionsCallbacks)
                return self.coordinate(to: commentCreationCoordinator)
            }
            .do(onNext: { result in
                switch result {
                case .commentCreated(_):
                    // TODO: We will probably would like to push this comment to the table view with a nice highlight animation
                    break
                case .loadedToScreen:
                    break
                    // Nothing
                case .popped:
                    break
                case .userLoggedInWhileWritingReplyToComment:
                    break
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
                                                                        actionsCallbacks: self.actionsCallbacks,
                                                                        presentationalMode: self.commentThreadData.presentationalStyle)
                return self.coordinate(to: reportReasonCoordinator)
            }
            .do(onNext: { coordinatorResult in
                switch coordinatorResult {
                case .popped:
                    // Nothing
                    break
                case .submitedReport(_):
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
            .flatMap { [weak self] type -> Observable<OWClarityDetailsCoordinatorResult> in
                guard let self = self else { return .empty() }
                let clarityDetailsCoordinator = OWClarityDetailsCoordinator(type: type,
                                                                            router: self.router,
                                                                            actionsCallbacks: self.actionsCallbacks,
                                                                            presentationalMode: self.commentThreadData.presentationalStyle)
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
                                                                   actionsCallbacks: self.actionsCallbacks)
                return self.coordinate(to: safariCoordinator, deepLinkOptions: .none)
            }
            .flatMap { _ -> Observable<OWCommentThreadCoordinatorResult> in
                return Observable.never()
            }

        return Observable.merge(commentThreadPoppedObservable,
                                commentThreadLoadedToScreenObservable,
                                coordinateCommentCreationObservable, coordinateToSafariObservables,
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

fileprivate extension OWCommentThreadCoordinator {
    func setupObservers(forViewModel viewModel: OWCommentThreadViewModeling) {
        // Setting up general observers which affect app flow however not entirely inside the SDK
    }

    func setupViewActionsCallbacks(forViewModel viewModel: OWCommentThreadViewModeling) {
        guard actionsCallbacks != nil else { return } // Make sure actions callbacks are available/provided
    }

    func setupObservers(forViewModel viewModel: OWCommentThreadViewViewModeling) {
        // TODO: Setting up general observers which affect app flow however not entirely inside the SDK
    }

    func setupViewActionsCallbacks(forViewModel viewModel: OWCommentThreadViewViewModeling) {
        guard actionsCallbacks != nil else { return } // Make sure actions callbacks are available/provided

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
            .map { OWViewActionCallbackType.openClarityDetails(type: $0) }

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
