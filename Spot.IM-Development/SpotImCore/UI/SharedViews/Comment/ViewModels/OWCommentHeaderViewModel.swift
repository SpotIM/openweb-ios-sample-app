//
//  OWCommentHeaderViewModel.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 07/12/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import RxSwift
import RxCocoa
import UIKit

protocol OWCommentHeaderViewModelingInputs {
    func updateEditedCommentLocally(_ comment: OWComment)
    var tapUserName: PublishSubject<Void> { get }
    var tapMore: PublishSubject<OWUISource> { get }
    var shouldReportCommentLocally: BehaviorSubject<Bool> { get }
    var shouldDeleteCommentLocally: BehaviorSubject<Bool> { get }
    var shouldMuteCommentLocally: BehaviorSubject<Bool> { get }
}

protocol OWCommentHeaderViewModelingOutputs {
    var subscriberBadgeVM: OWSubscriberIconViewModeling { get }
    var avatarVM: OWAvatarViewModeling { get }

    var shouldShowSubtitleSeperator: Observable<Bool> { get }
    var shouldShowHiddenCommentMessage: Observable<Bool> { get }
    var nameText: Observable<String> { get }
    var subtitleText: Observable<String> { get }
    var dateText: Observable<String> { get }
    var badgeTitle: Observable<String> { get }
    var hiddenCommentReasonText: Observable<String> { get }

    var userNameTapped: Observable<Void> { get }
    var openMenu: Observable<([OWRxPresenterAction], OWUISource)> { get }
}

protocol OWCommentHeaderViewModeling {
    var inputs: OWCommentHeaderViewModelingInputs { get }
    var outputs: OWCommentHeaderViewModelingOutputs { get }
}

class OWCommentHeaderViewModel: OWCommentHeaderViewModeling,
                                OWCommentHeaderViewModelingInputs,
                                OWCommentHeaderViewModelingOutputs {

    var inputs: OWCommentHeaderViewModelingInputs { return self }
    var outputs: OWCommentHeaderViewModelingOutputs { return self }

    fileprivate let disposedBag = DisposeBag()
    fileprivate let servicesProvider: OWSharedServicesProviding
    fileprivate let userBadgeService: OWUserBadgeServicing

    fileprivate let _model = BehaviorSubject<OWComment?>(value: nil)
    fileprivate var _unwrappedModel: Observable<OWComment> {
        _model.unwrap()
    }

    fileprivate var user: SPUser? = nil
    fileprivate let _user = BehaviorSubject<SPUser?>(value: nil)
    fileprivate var _unwrappedUser: Observable<SPUser> {
        _user.unwrap()
    }

    fileprivate let _replyToUser = BehaviorSubject<SPUser?>(value: nil)

    var shouldReportCommentLocally = BehaviorSubject<Bool>(value: false)
    var shouldDeleteCommentLocally = BehaviorSubject<Bool>(value: false)
    var shouldMuteCommentLocally = BehaviorSubject<Bool>(value: false)

    init(data: OWCommentRequiredData,
         imageProvider: OWImageProviding = OWCloudinaryImageProvider(),
         servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared,
         userBadgeService: OWUserBadgeServicing = OWUserBadgeService()
    ) {
        self.servicesProvider = servicesProvider
        self.userBadgeService = userBadgeService
        self.user = data.user
        avatarVM = OWAvatarViewModel(user: data.user, imageURLProvider: imageProvider)
        _model.onNext(data.comment)
        _user.onNext(data.user)
        _replyToUser.onNext(data.replyToUser)
        setupObservers()
    }

    init() {
        servicesProvider = OWSharedServicesProvider.shared
        userBadgeService = OWUserBadgeService()
        setupObservers()
    }

    func updateEditedCommentLocally(_ comment: OWComment) {
        _model.onNext(comment)
    }

    var avatarVM: OWAvatarViewModeling = {
        return OWAvatarViewModel()
    }()

    var tapUserName = PublishSubject<Void>()
    var tapMore = PublishSubject<OWUISource>()

    lazy var subscriberBadgeVM: OWSubscriberIconViewModeling = {
        return OWSubscriberIconViewModel(user: user!, servicesProvider: servicesProvider, subscriberBadgeService: OWSubscriberBadgeService())
    }()

    var subtitleText: Observable<String> {
        _replyToUser
            .map({ user -> String? in
                return user?.displayName
            })
            .map({
                guard let displayName = $0, !displayName.isEmpty else {
                    return ""
                }
                return OWLocalizationManager.shared.localizedString(key: "To") + " \(displayName)"
            })
    }

    var shouldShowSubtitleSeperator: Observable<Bool> {
        _unwrappedModel
            .map { $0.isReply }
    }

    var dateText: Observable<String> {
        _unwrappedModel
            .map({ model in
                guard let writtenAt = model.writtenAt else { return "" }
                let timestamp = Date(timeIntervalSince1970: writtenAt).owTimeAgo()
                return timestamp
            })
    }

    fileprivate var conversationConfig: Observable<SPConfigurationConversation> {
        servicesProvider.spotConfigurationService()
            .config(spotId: OWManager.manager.spotId)
            .map { config -> SPConfigurationConversation? in
                return config.conversation
            }
            .unwrap()
    }

    fileprivate var _badgeType: Observable<OWUserBadgeType> {
        _unwrappedUser
            .flatMap { [weak self] user -> Observable<OWUserBadgeType> in
                guard let self = self else { return .empty() }
                return self.userBadgeService.userBadgeText(user: user)
            }
    }

    var badgeTitle: Observable<String> {
        _badgeType
            .map { badgeType in
                if case .badge(let title) = badgeType {
                    return title.uppercased()
                }
                return ""
            }
    }

    var nameText: Observable<String> {
        _unwrappedUser
            .map({ user -> String in
                return user.displayName ?? ""
            })
    }

    var hiddenCommentReasonText: Observable<String> {
        Observable.combineLatest(_unwrappedModel,
                                 _unwrappedUser,
                                 shouldDeleteCommentLocally,
                                 shouldMuteCommentLocally,
                                 shouldReportCommentLocally) { model, user, shouldDeleteCommentLocally, shouldMuteCommentLocally, shouldReportCommentLocally in
            let localizationKey: String
            if user.isMuted || shouldMuteCommentLocally {
                localizationKey = "This user is muted."
            } else if model.reported || shouldReportCommentLocally {
                localizationKey = "This message was reported."
            } else if (model.status == .block || model.status == .reject) {
                localizationKey = "This comment violated our policy."
            } else if model.deleted || shouldDeleteCommentLocally {
                localizationKey = "This message was deleted."
            } else {
                return ""
            }
            return OWLocalizationManager.shared.localizedString(key: localizationKey)
        }
    }

    var shouldShowHiddenCommentMessage: Observable<Bool> {
        hiddenCommentReasonText
            .map { !$0.isEmpty }
    }

    var userNameTapped: Observable<Void> {
        tapUserName
            .asObservable()
    }

    fileprivate var isLoggedInUserComment: Observable<Bool> {
        _unwrappedModel
            .map { $0.userId }
            .unwrap()
            .flatMapLatest { [weak self] userId -> Observable<(String, OWUserAvailability)> in
                guard let self = self else { return .empty() }
                return self.servicesProvider
                    .authenticationManager()
                    .activeUserAvailability
                    .map { (userId, $0) }
            }
            .map { commentUserId, userAvailability in
                switch userAvailability {
                case .user(let user):
                    return user.userId == commentUserId
                case .notAvailable:
                    return false
                }
            }
    }

    var openMenu: Observable<([OWRxPresenterAction], OWUISource)> {
        tapMore
            .flatMapLatest { [weak self] view -> Observable<([OWUserAction: Bool], UIView)> in
                guard let self = self else { return .empty() }
                let actions: [OWUserAction] = [.reportingComment, .deletingComment, .editingComment, .mutingUser]
                let authentication = self.servicesProvider.authenticationManager()

                return authentication.userHasAuthenticationLevel(for: actions)
                    .take(1)
                    .map { ($0, view) }
            }
            .withLatestFrom(isLoggedInUserComment) { ($0.0, $0.1, $1) }
            .withLatestFrom(_unwrappedUser) { ($0.0, $0.1, $0.2, $1) }
            .map { actionsAuthenticationLevel, view, isLoggedInUserComment, user in
                let allowReportingComment = actionsAuthenticationLevel[.reportingComment] ?? false
                let allowDeletingComment = actionsAuthenticationLevel[.deletingComment] ?? false
                let allowEditingComment = actionsAuthenticationLevel[.editingComment] ?? false
                let allowMuteUser = actionsAuthenticationLevel[.mutingUser] ?? false

                var optionsActions: [OWRxPresenterAction] = []
                if (allowReportingComment && !isLoggedInUserComment) {
                    optionsActions.append(OWRxPresenterAction(
                        title: OWLocalizationManager.shared.localizedString(key: "Report"),
                        type: OWCommentOptionsMenu.reportComment)
                    )
                }
                if (allowEditingComment && isLoggedInUserComment) {
                    optionsActions.append(OWRxPresenterAction(
                        title: OWLocalizationManager.shared.localizedString(key: "Edit"),
                        type: OWCommentOptionsMenu.editComment)
                    )
                }
                if (allowDeletingComment && isLoggedInUserComment) {
                    optionsActions.append(OWRxPresenterAction(
                        title: OWLocalizationManager.shared.localizedString(key: "Delete"),
                        type: OWCommentOptionsMenu.deleteComment)
                    )
                }
                if (allowMuteUser && !isLoggedInUserComment && !user.isAdmin) {
                    optionsActions.append(OWRxPresenterAction(
                        title: OWLocalizationManager.shared.localizedString(key: "Mute"),
                        type: OWCommentOptionsMenu.muteUser)
                    )
                }
                return (optionsActions, view)
            }
            .unwrap()
            .asObservable()
    }
}

fileprivate extension OWCommentHeaderViewModel {
    func setupObservers() {
        shouldShowHiddenCommentMessage
            .bind(to: avatarVM.inputs.shouldBlockAvatar)
            .disposed(by: disposedBag)
    }
}
