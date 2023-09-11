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
    func openProfileTapped(user: SPUser) -> Observable<OWOpenProfileData>
}

class OWProfileService: OWProfileServicing {
    fileprivate let disposeBag = DisposeBag()
    fileprivate unowned let sharedServicesProvider: OWSharedServicesProviding

    init(sharedServicesProvider: OWSharedServicesProviding) {
        self.sharedServicesProvider = sharedServicesProvider
    }

    func openProfileTapped(user: SPUser) -> Observable<OWOpenProfileData> {
        let profileOptionToUse = profileOptionToUse(user: user)

        // Check if sdk profile should be opened
        let shouldOpenSDKProfile: Observable<Void> = profileOptionToUse
            .map { profileOptionToUse -> Bool in
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
            .withLatestFrom(self.sharedServicesProvider.authenticationManager()
                .activeUserAvailability) { _, availability -> Bool in
                    switch availability {
                    case .notAvailable:
                        return false
                    case .user(let sessionUser):
                        guard sessionUser.id == user.id else { return false }
                        return true
                    }
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
            .flatMap { [weak self] _ -> Observable<URL?> in
                guard let self = self else { return .empty() }
                return self.sharedServicesProvider.netwokAPI()
                    .profile
                    .createSingleUseToken()
                    .response
                    .map { response -> URL? in
                        guard let token = response["single_use_token"],
                              let url = self.profileUrl(singleUseTicket: token, userId: user.id)
                        else { return nil }
                        return url
                    }
            }
            .unwrap()

        // Create URL for user profile without token
        let userProfileWithoutToken: Observable<URL> = shouldOpenUserProfileWithToken
            .filter { !$0 }
            .map { [weak self] _ -> URL? in
                guard let self = self,
                      let url = self.profileUrl(singleUseTicket: nil, userId: user.id)
                else { return nil }
                return url
            }
            .unwrap()

        let userProfileWithTokenObservable = userProfileWithToken
            .map { url -> OWOpenProfileData? in
                guard let userId = user.id else { return nil }
                return OWOpenProfileData(url: url, userProfileType: .currentUser, userId: userId)
            }
            .unwrap()

        let userProfileWithoutTokenObservable = userProfileWithoutToken
            .map { url -> OWOpenProfileData? in
                guard let userId = user.id else { return nil }
                return OWOpenProfileData(url: url, userProfileType: .otherUser, userId: userId)
            }
            .unwrap()

        return Observable.merge(userProfileWithTokenObservable, userProfileWithoutTokenObservable)
    }
}

fileprivate extension OWProfileService {
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

    func profileOptionToUse(user: SPUser) -> Observable<OWProfileOption> {
        return sharedServicesProvider
            .spotConfigurationService()
            .config(spotId: OWManager.manager.spotId)
            .map { config -> OWProfileOption in
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
