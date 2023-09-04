//
//  OWProfileService.swift
//  SpotImCore
//
//  Created by Refael Sommer on 04/09/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import RxSwift
import Foundation

protocol OWProfileServicing {
    var openProfileTapped: PublishSubject<SPUser> { get }
    var openProfile: Observable<OWOpenProfileData> { get }
}

class OWProfileService: OWProfileServicing {
    fileprivate let disposeBag = DisposeBag()
    fileprivate let sharedServicesProvider: OWSharedServicesProviding

    init(sharedServicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.sharedServicesProvider = sharedServicesProvider
        setupObservers()
    }

    var shouldBlockOpenProfile = BehaviorSubject<Bool>(value: false)
    lazy var openProfileTapped = PublishSubject<SPUser>()

    fileprivate lazy var user: Observable<SPUser> = {
        return self.openProfileTapped
            .asObservable()
            .share()
    }()

    fileprivate var _openProfile = PublishSubject<OWOpenProfileData>()
    var openProfile: Observable<OWOpenProfileData> {
        _openProfile
            .asObservable()
    }
}

fileprivate extension OWProfileService {
    func setupObservers() {
        let profileOptionToUse = profileOptionToUse()

        // Check if sdk profile should be opened
        let shouldOpenSDKProfile: Observable<Void> = openProfileTapped
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
            .withLatestFrom(user) { sessionUser, user in
                guard let sessionUser = sessionUser,
                      sessionUser.id == user.id
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
            .filter { !$0 } // Do not continue if authentication needed
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

        userProfileWithToken
            .withLatestFrom(openProfileTapped) { ($0, $1) }
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] (url, user) in
                guard let self = self,
                      let userId = user.id else { return }
                self._openProfile.onNext(OWOpenProfileData(url: url, userProfileType: .currentUser, userId: userId))
            })
            .disposed(by: disposeBag)

        userProfileWithoutToken
            .withLatestFrom(openProfileTapped) { ($0, $1) }
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] (url, user) in
                guard let self = self,
                      let userId = user.id else { return }
                self._openProfile.onNext(OWOpenProfileData(url: url, userProfileType: .currentUser, userId: userId))
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
