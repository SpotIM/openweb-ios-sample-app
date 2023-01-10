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
    var tapUserName: PublishSubject<Void> { get }
    var tapMore: PublishSubject<OWUISource> { get }
}

protocol OWCommentHeaderViewModelingOutputs {
    var subscriberBadgeVM: OWUserSubscriberBadgeViewModeling { get }
    var avatarVM: OWAvatarViewModeling { get }
    
    var shouldShowHiddenCommentMessage: Observable<Bool> { get }
    var nameText: Observable<String> { get }
    var nameTextStyle: Observable<SPFontStyle> { get }
    var subtitleText: Observable<String> { get }
    var dateText: Observable<String> { get }
    var badgeTitle: Observable<String> { get }
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
    fileprivate let servicesProvider: OWSharedServicesProviding
    fileprivate let userBadgeService: OWUserBadgeServicing
    
    fileprivate let _model = BehaviorSubject<SPComment?>(value: nil)
    fileprivate var _unwrappedModel: Observable<SPComment>  {
        _model.unwrap()
    }

    fileprivate let _user = BehaviorSubject<SPUser?>(value: nil)
    fileprivate var _unwrappedUser: Observable<SPUser>  {
        _user.unwrap()
    }
    
    fileprivate let _replyToUser = BehaviorSubject<SPUser?>(value: nil)
    
    init(user: SPUser, replyTo: SPUser?, model: SPComment,
         imageProvider: OWImageProvider = OWCloudinaryImageProvider(),
         servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared,
         userBadgeService: OWUserBadgeServicing = OWUserBadgeService()
    ) {
        self.servicesProvider = servicesProvider
        self.userBadgeService = userBadgeService
        avatarVM = OWAvatarViewModelV2(user: user, imageURLProvider: imageProvider)
        subscriberBadgeVM.inputs.configureUser(user: user)
        _model.onNext(model)
        _user.onNext(user)
        _replyToUser.onNext(replyTo)
    }
    
    init() {
        servicesProvider = OWSharedServicesProvider.shared
        userBadgeService = OWUserBadgeService()
    }
    
    var avatarVM: OWAvatarViewModeling = {
       return OWAvatarViewModel()
    }()
    
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
        _unwrappedModel
            .map({ model in
                guard let writtenAt = model.writtenAt else { return "" }
                let timestamp = Date(timeIntervalSince1970: writtenAt).timeAgo()
                return model.isReply ? " · ".appending(timestamp) : timestamp
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
    var badgeTitle: Observable<String> {
        Observable.combineLatest(_unwrappedUser, conversationConfig) { [weak self] user, conversationConfig in
                guard let self = self else { return "" }
            return self.userBadgeService.userBadgeText(user: user, conversationConfig: conversationConfig)?.uppercased() ?? ""
        }
    }
    
    var nameText: Observable<String> {
        _unwrappedUser
            .map({ user -> String in
                return user.displayName ?? ""
            })
    }
    
    var nameTextStyle: Observable<SPFontStyle> {
        _unwrappedModel
            .map { $0.isReply ? .medium : .bold }
    }
    
    var hiddenCommentReasonText: Observable<String> {
        Observable.combineLatest(_unwrappedModel, _unwrappedUser) { model, user in
            let localizationKey: String
            if user.isMuted {
                localizationKey = "This user is muted."
            } else if let id = model.id,
                      let _ = SPUserSessionHolder.session.reportedComments[id] { // TODO: is reported - should be in new infra?
                localizationKey = "This message was reported."
            } else if model.deleted {
                localizationKey = "This message was deleted."
            } else {
                return ""
            }
            return LocalizationManager.localizedString(key: localizationKey)
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
    
    var moreTapped: Observable<OWUISource> {
        tapMore
            .asObservable()
    }
}
