//
//  OWAvatarViewModel.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 11/04/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//
import Foundation
import RxSwift
import RxCocoa
import UIKit

protocol OWAvatarViewModelingInputs {
    var tapAvatar: PublishSubject<Void> { get }
    var userInput: BehaviorSubject<SPUser?> { get }
    var shouldBlockAvatar: BehaviorSubject<Bool> { get } // showing default avatar image and disable tap
}

protocol OWAvatarViewModelingOutputs {
    var imageType: Observable<OWImageType> { get }
    var shouldShowOnlineIndicator: Observable<Bool> { get }
    var openProfile: Observable<URL> { get }
    var openPublisherProfile: Observable<String> { get }
}

protocol OWAvatarViewModeling {
    var inputs: OWAvatarViewModelingInputs { get }
    var outputs: OWAvatarViewModelingOutputs { get }
}

class OWAvatarViewModel: OWAvatarViewModeling,
                         OWAvatarViewModelingInputs,
                         OWAvatarViewModelingOutputs {

    var inputs: OWAvatarViewModelingInputs { return self }
    var outputs: OWAvatarViewModelingOutputs { return self }

    var userInput = BehaviorSubject<SPUser?>(value: nil)

    var shouldBlockAvatar = BehaviorSubject<Bool>(value: false)

    var tapAvatar = PublishSubject<Void>()
    var avatarTapped: Observable<Void> {
        Observable.combineLatest(tapAvatar, shouldBlockAvatar)
            .filter { !$1 }
            .voidify()
    }

    fileprivate let imageURLProvider: OWImageProviding
    fileprivate let sharedServicesProvider: OWSharedServicesProviding

    fileprivate let disposeBag = DisposeBag()

    init (
        user: SPUser? = nil,
        imageURLProvider: OWImageProviding = OWCloudinaryImageProvider(),
        sharedServicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.imageURLProvider = imageURLProvider
        self.sharedServicesProvider = sharedServicesProvider
        if let user = user {
            self.userInput.onNext(user)
        }
        setupObservers()
    }

    fileprivate lazy var user: Observable<SPUser> = {
        self.userInput
            .unwrap()
    }()

    var imageType: Observable<OWImageType> {
        Observable.combineLatest(self.user, self.shouldBlockAvatar.asObserver())
            .flatMap { [weak self] (user, shouldBlockAvatar) -> Observable<URL?> in
                guard let self = self,
                      let imageId = user.imageId,
                      !shouldBlockAvatar
                else { return .empty() }

                return self.imageURLProvider.imageURL(with: imageId, size: nil)
            }
            .map { url in
                guard let url = url else { return .defaultImage }
                return .custom(url: url)
            }
            .asObservable()
            .startWith(.defaultImage)
    }

    var shouldShowOnlineIndicator: Observable<Bool> {
        return Observable.combineLatest(
            user,
            sharedServicesProvider.authenticationManager().activeUserAvailability,
            sharedServicesProvider.spotConfigurationService().config(spotId: OWManager.manager.spotId)
        ) { user, availability, config in
            guard config.conversation?.disableOnlineDotIndicator != true else { return false }

            if (user.online == true) {
                return true
            }
            switch availability {
            case .user(let sessionUser):
                return user.id == sessionUser.id
            case .notAvailable:
                return false
            }
        }
    }

    fileprivate var _openAvatarProfile = PublishSubject<URL>()
    var openProfile: Observable<URL> {
        _openAvatarProfile
            .asObservable()
    }

    fileprivate var _openPublisherProfile = PublishSubject<String>()
    var openPublisherProfile: Observable<String> {
        _openPublisherProfile
            .asObservable()
    }
}

fileprivate extension OWAvatarViewModel {
    func setupObservers() {
        let profileOptionToUse = profileOptionToUse()

        // Check if sdk profile should be opened
        let shouldOpenSDKProfile: Observable<Void> = avatarTapped
            .withLatestFrom(profileOptionToUse) { _, profileOptionToUse -> Bool in
                if case .SDKProfile = profileOptionToUse {
                    return true
                } else {
                    return false
                }
            }
            .filter { $0 }
            .voidify()

        // Check if this is current user and token is needed
        let shouldOpenUserProfileWithToken: Observable<Bool> = shouldOpenSDKProfile
            .withLatestFrom(
                sharedServicesProvider.authenticationManager()
                    .activeUserAvailability
            ) { _, availability -> SPUser? in
                switch availability {
                case .notAvailable:
                    return nil
                case .user(let user):
                    return user
                }
            }
            .withLatestFrom(user) { sessionUser, avatarUser in
                guard let sessionUser = sessionUser,
                      sessionUser.id == avatarUser.id
                else { return false }
                return true
            }

        // Create URL for user profie with token
        let userProfileWithToken: Observable<URL> = shouldOpenUserProfileWithToken
            .filter { $0 }
            .flatMapLatest { [weak self] _ -> Observable<Bool> in
                // Triggering authentication UI if needed
                guard let self = self else { return .empty() }
                return self.sharedServicesProvider.authenticationManager().ifNeededTriggerAuthenticationUI(for: .viewingSelfProfile)
            }
            .filter { !$0 } // Do not continue if needed to authenticate
            .flatMap { [weak self] _ -> Observable<OWSingleUseTokenResponse> in
                guard let self = self else { return .empty() }
                return self.sharedServicesProvider.netwokAPI()
                    .profile
                    .createSingleUseToken()
                    .response
            }
            .withLatestFrom(user) { [weak self] response, user -> URL? in
                guard let self = self,
                      let token = response["single_use_token"],
                      let url = self.profileUrl(singleUseTicket: token, userId: user.id)
                else { return nil }
                return url
            }
            .unwrap()

        // Create URL for user profile without token
        let userProfileWithoutToken: Observable<URL> = shouldOpenUserProfileWithToken
            .filter { !$0 }
            .withLatestFrom(user) { [weak self] _, user -> URL? in
                guard let self = self,
                      let url = self.profileUrl(singleUseTicket: nil, userId: user.id)
                else { return nil }
                return url
            }
            .unwrap()

        Observable.merge(userProfileWithToken, userProfileWithoutToken)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] url in
                guard let self = self else { return }
                self._openAvatarProfile.onNext(url)
            })
            .disposed(by: disposeBag)

        // Open publisher profile if needed
        avatarTapped
            .withLatestFrom(profileOptionToUse) { _, profileOptionToUse -> String? in
                switch (profileOptionToUse) {
                case .publisherProfile(let ssoPublisherId):
                    return ssoPublisherId
                default:
                    return nil
                }
            }
            .unwrap()
            .subscribe(onNext: { [weak self] ssoPublisherId in
                guard let self = self else { return }
                self._openPublisherProfile.onNext(ssoPublisherId)
            })
            .disposed(by: disposeBag)

    }

    func profileUrl(singleUseTicket: String?, userId: String?) -> URL? {
        let baseUrl = URL(string: "https://sdk.openweb.com/index.html")
        guard var url = baseUrl,
              let postId = OWManager.manager.postId
        else { return nil }

        url.appendQueryParam(name: "module_name", value: "user-profile")
        url.appendQueryParam(name: "spot_id", value: OWManager.manager.spotId)
        url.appendQueryParam(name: "post_id", value: postId)
        url.appendQueryParam(name: "single_use_ticket", value: singleUseTicket)
        if let userId = userId {
            url.appendQueryParam(name: "user_id", value: userId)
        }
        url = SPWebSDKProvider.urlWithDarkModeParam(url: url)

        return url
    }

    func profileOptionToUse() -> Observable<OWProfileOption> {
        return Observable.combineLatest(sharedServicesProvider
            .spotConfigurationService()
            .config(spotId: OWManager.manager.spotId), user) { config, user -> OWProfileOption in
                guard config.mobileSdk.profileEnabled == true else { return .none }
                if config.shared?.usePublisherUserProfile == true,
                   let ssoPublisherId = user.ssoPublisherId,
                   !ssoPublisherId.isEmpty {
                    return .publisherProfile(ssoPublisherId: ssoPublisherId)
                } else {
                    return .SDKProfile
                }
            }
            .share(replay: 1)
    }
}
