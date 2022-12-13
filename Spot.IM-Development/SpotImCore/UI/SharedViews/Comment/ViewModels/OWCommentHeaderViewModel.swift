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
//    func configure(with model: CommentViewModel)
    
    var tapUserName: PublishSubject<Void> { get }
    var tapMore: PublishSubject<OWUISource> { get }
}

protocol OWCommentHeaderViewModelingOutputs {
    var subscriberBadgeVM: OWUserSubscriberBadgeViewModeling { get }
    var avatarVM: OWAvatarViewModeling { get }
    
    var shouldShowDeletedOrReportedMessage: Observable<Bool> { get }
    var nameText: Observable<String> { get }
    var nameTextStyle: Observable<SPFontStyle> { get }
    var subtitleText: Observable<String> { get }
    var dateText: Observable<String> { get }
    var badgeTitle: Observable<String> { get }
    var isUsernameOneRow: Observable<Bool> { get }
    var hiddenCommentReasonText: Observable<String> { get }
    
    var userNameTapped: Observable<Void> { get }
    var moreTapped: Observable<OWUISource> { get }
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
    
    fileprivate let disposeBag = DisposeBag()
    
    fileprivate let _model = BehaviorSubject<SPComment?>(value: nil)

    fileprivate let _user = BehaviorSubject<SPUser?>(value: nil)
    
    fileprivate let _replyToUser = BehaviorSubject<SPUser?>(value: nil)
    
    // TODO: image provider
    init(user: SPUser, replyTo: SPUser?, model: SPComment, imageProvider: SPImageProvider? = nil) {
        avatarVM = OWAvatarViewModel(user: user, imageURLProvider: imageProvider)
        subscriberBadgeVM.inputs.configureUser(user: user)
        _model.onNext(model)
        _user.onNext(user)
        _replyToUser.onNext(replyTo)
    }
    
    let avatarVM: OWAvatarViewModeling
    
    var tapUserName = PublishSubject<Void>()
    var tapMore = PublishSubject<OWUISource>()
    
    let subscriberBadgeVM: OWUserSubscriberBadgeViewModeling = OWUserSubscriberBadgeViewModel()
    
    var subtitleText: Observable<String> {
        _replyToUser
            .unwrap()
            .map({ user -> String? in
                return user.displayName
            })
            .unwrap()
            .map({ $0.isEmpty ? ""
                : LocalizationManager.localizedString(key: "To") + " \($0)"
            })
    }
    
    var dateText: Observable<String> {
        _model
            .unwrap()
            .map({ model in
                guard let writtenAt = model.writtenAt else { return ""}
                let timestamp = Date(timeIntervalSince1970: writtenAt).timeAgo()
                return model.isReply ? " · ".appending(timestamp) : timestamp
            })
    }
    
    
    fileprivate var conversationConfig: Observable<SPConfigurationConversation> {
        OWSharedServicesProvider.shared.spotConfigurationService()
            .config(spotId: OWManager.manager.spotId)
            .map { config -> SPConfigurationConversation? in
                return config.conversation
            }
            .unwrap()
    }
    var badgeTitle: Observable<String> {
        Observable.combineLatest(_user, conversationConfig) { [weak self] user, conversationConfig in
                guard let self = self,
                      let user = user else { return "" }
            return self.getUserBadgeUsingConfig(user: user, conversationConfig: conversationConfig)?.uppercased() ?? ""
        }
    }
    
    var nameText: Observable<String> {
        _user
            .unwrap()
            .map({ user -> String in
                return user.displayName ?? ""
            })
    }
    
    var nameTextStyle: Observable<SPFontStyle> {
        _model
            .unwrap()
            .map { $0.isReply ? .medium : .bold}
    }
    
    var isUsernameOneRow: Observable<Bool> {
        _model
            .unwrap()
            .map { _ in
//                $0.isUsernameOneRow()
                false // TODO
            }
    }
    
    var hiddenCommentReasonText: Observable<String> {
        Observable.combineLatest(_model, _user) { model, user in
                guard let model = model,
                      let user = user else { return "" }
            let localizationKey: String
            if user.isMuted {
                localizationKey = "This user is muted."
            } else if let id = model.id,
                      let _ = SPUserSessionHolder.session.reportedComments[id] { // TODO: is reported - should be in new infra?
                localizationKey = "This message was reported."
            } else if model.deleted {
                localizationKey = "This message was deleted."
            } else {
                return "This message was deleted."
            }
            return LocalizationManager.localizedString(key: localizationKey)
        }
    }
    
    var shouldShowDeletedOrReportedMessage: Observable<Bool> {
        hiddenCommentReasonText
            .map { !$0.isEmpty }
    }
    
    var userNameTapped: Observable<Void> {
        tapUserName
            .asObservable()
    }
    
    var moreTapped: Observable<OWUISource> {
        tapMore
            .asObservable()
    }
    
//    func configure(with model: CommentViewModel) {
//        _model.onNext(model)
//    }
}

fileprivate extension OWCommentHeaderViewModel {
    func getUserBadgeUsingConfig(user: SPUser, conversationConfig: SPConfigurationConversation) -> String? {
        guard user.isStaff else { return nil }
        
        if let translations = conversationConfig.translationTextOverrides,
           let currentTranslation = LocalizationManager.currentLanguage == .spanish ? translations["es-ES"] : translations[LocalizationManager.getLanguageCode()]
        {
            if user.isAdmin, let adminBadge = currentTranslation[BadgesOverrideKeys.admin.rawValue] {
                return adminBadge
            } else if user.isJournalist, let jurnalistBadge = currentTranslation[BadgesOverrideKeys.journalist.rawValue] {
                return jurnalistBadge
            } else if user.isModerator, let moderatorBadge = currentTranslation[BadgesOverrideKeys.moderator.rawValue] {
                return moderatorBadge
            } else if user.isCommunityModerator, let communityModeratorBadge = currentTranslation[BadgesOverrideKeys.communityModerator.rawValue]  {
                return communityModeratorBadge
            }
        }
        return user.authorityTitle
    }
}
