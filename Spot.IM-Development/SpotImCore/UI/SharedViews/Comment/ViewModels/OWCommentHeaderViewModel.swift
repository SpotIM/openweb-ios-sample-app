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
    var subscriberBadgeVM: OWSubscriberIconViewModeling { get }
    var avatarVM: OWAvatarViewModeling { get }

    var shouldShowHiddenCommentMessage: Observable<Bool> { get }
    var nameText: Observable<String> { get }
    var subtitleText: Observable<String> { get }
    var dateText: Observable<String> { get }
    var badgeTitle: Observable<String> { get }
    var hiddenCommentReasonText: Observable<String> { get }

    var userNameTapped: Observable<Void> { get }
    var openMenu: Observable<[UIRxPresenterAction]> { get }
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

    var dateText: Observable<String> {
        _unwrappedModel
            .map({ model in
                guard let writtenAt = model.writtenAt else { return "" }
                let timestamp = Date(timeIntervalSince1970: writtenAt).owTimeAgo()
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
        Observable.combineLatest(_unwrappedModel, _unwrappedUser) { model, user in
            let localizationKey: String
            if user.isMuted {
                localizationKey = "This user is muted."
            } else if let id = model.id,
                        SPUserSessionHolder.session.reportedComments[id] != nil { // TODO: is reported - should be in new infra?
                localizationKey = "This message was reported."
            } else if model.deleted {
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

    var openMenu: Observable<[UIRxPresenterAction]> {
        tapMore
            .map { [weak self] _ in
                guard let self = self else { return nil}
                return self.optionsActions
            }
            .unwrap()
            .asObservable()
    }

    // TODO: properly get the relevant actions
    fileprivate lazy var optionsActions: [UIRxPresenterAction] = {
        return [
            UIRxPresenterAction(title: OWLocalizationManager.shared.localizedString(key: "Report"), type: .reportComment),
            UIRxPresenterAction(title: OWLocalizationManager.shared.localizedString(key: "Cancel"), type: .cancel, style: .cancel)
        ]
    }()
}

fileprivate extension OWCommentHeaderViewModel {
    func setupObservers() {
        shouldShowHiddenCommentMessage
            .bind(to: avatarVM.inputs.shouldBlockAvatar)
            .disposed(by: disposedBag)
    }
}
