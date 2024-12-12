//
//  OWCommentHeaderViewModel.swift
//  OpenWebSDK
//
//  Created by  Nogah Melamed on 07/12/2022.
//  Copyright © 2022 OpenWeb. All rights reserved.
//

import RxSwift
import RxCocoa
import UIKit

protocol OWCommentHeaderViewModelingInputs {
    func update(comment: OWComment)
    func update(user: SPUser)
    var isCommentOfActiveUser: BehaviorSubject<Bool> { get }
    var tapUserName: PublishSubject<Void> { get }
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
    var openProfile: Observable<OWOpenProfileType> { get }
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

    private let disposedBag = DisposeBag()
    private let servicesProvider: OWSharedServicesProviding
    private let userBadgeService: OWUserBadgeServicing

    private let _model = BehaviorSubject<OWComment?>(value: nil)
    private var _unwrappedModel: Observable<OWComment> {
        _model.unwrap()
    }

    private var user: SPUser?
    private let _user = BehaviorSubject<SPUser?>(value: nil)
    private var _unwrappedUser: Observable<SPUser> {
        _user.unwrap()
    }

    private var _openProfile = PublishSubject<OWOpenProfileType>()
    var openProfile: Observable<OWOpenProfileType> {
        _openProfile
            .asObservable()
    }

    private let _replyToUser = BehaviorSubject<SPUser?>(value: nil)

    var isCommentOfActiveUser = BehaviorSubject<Bool>(value: false)

    init(data: OWCommentRequiredData,
         imageProvider: OWImageProviding = OWCloudinaryImageProvider(),
         servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared,
         userBadgeService: OWUserBadgeServicing = OWUserBadgeService()) {
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

    func update(comment: OWComment) {
        _model.onNext(comment)
    }

    func update(user: SPUser) {
        self.user = user
        _user.onNext(user)
    }

    func updateEditedCommentLocally(_ comment: OWComment) {
        _model.onNext(comment)
    }

    var avatarVM: OWAvatarViewModeling = {
        return OWAvatarViewModel()
    }()

    var tapUserName = PublishSubject<Void>()

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
                return OWLocalize.string("To") + " \(displayName)"
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

    private var conversationConfig: Observable<SPConfigurationConversation> {
        servicesProvider.spotConfigurationService()
            .config(spotId: OWManager.manager.spotId)
            .map { config -> SPConfigurationConversation? in
                return config.conversation
            }
            .unwrap()
    }

    private var _badgeType: Observable<OWUserBadgeType> {
        _unwrappedUser
            .flatMap { [weak self] user -> Observable<OWUserBadgeType> in
                guard let self else { return .empty() }
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
        Observable.combineLatest(_unwrappedModel, _unwrappedUser, isCommentOfActiveUser) { model, user, isCommentOfActiveUser in
            let localizationKey: String
            if user.isMuted {
                localizationKey = "MutedCommentMessage"
            } else if model.reported && !isCommentOfActiveUser {
                localizationKey = "ReportedCommentMessage"
            } else if model.status == .block || model.status == .reject {
                localizationKey = isCommentOfActiveUser ? "AuthorViolatedPolicyCommentMessage" : "ViolatedPolicyCommentMessage"
            } else if model.deleted {
                localizationKey = "DeletedCommentMessage"
            } else {
                return ""
            }

            return OWLocalize.string(localizationKey)
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
}

private extension OWCommentHeaderViewModel {
    func setupObservers() {
        shouldShowHiddenCommentMessage
            .bind(to: avatarVM.inputs.shouldBlockAvatar)
            .disposed(by: disposedBag)

        userNameTapped
            .flatMapLatest { [weak self] _ -> Observable<Bool> in
                guard let self else { return .empty() }
                return self.shouldShowHiddenCommentMessage
                    .take(1)
            }
            .filter { !$0 }
            .map { [weak self] _ -> SPUser? in
                guard let self else { return nil }
                return self.user
            }
            .unwrap()
            .flatMapLatest { [weak self] user -> Observable<OWOpenProfileResult> in
                guard let self else { return .empty() }
                return self.servicesProvider.profileService().openProfileTapped(user: user)
            }
            .map { result -> OWOpenProfileType? in
                switch result {
                case .openProfile(type: let type):
                    return type
                case .authenticationTriggered:
                    return nil
                }
            }
            .unwrap()
            .observe(on: MainScheduler.instance)
            .bind(to: _openProfile)
            .disposed(by: disposedBag)
    }
}
