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
}

protocol OWAvatarViewModelingOutputs {
    var imageType: Observable<OWImageType> { get }
    var showOnlineIndicator: Observable<Bool> { get }
    var openProfile: Observable<URL> { get }
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
    fileprivate let _isAvatartVisible = BehaviorSubject<Bool?>(value: nil)

    fileprivate let imageURLProvider: OWImageProviding
    fileprivate let sharedServicesProvider: OWSharedServicesProviding

    var tapAvatar = PublishSubject<Void>()

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
        self.user
            .flatMap { [weak self] user -> Observable<URL?> in
                guard let self = self,
                      let imageId = user.imageId,
                      !user.isMuted
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

    var showOnlineIndicator: Observable<Bool> {
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

    // TODO: handle tap in coordinator?
    fileprivate var _openAvatarProfile = PublishSubject<URL>()
    var openProfile: Observable<URL> {
        _openAvatarProfile
            .asObservable()
    }
}

fileprivate extension OWAvatarViewModel {
    func setupObservers() {
        // TODO: use profileEnabled from config, and call createSingleUseToken only if this is the loggedIn user
        tapAvatar
            .flatMap { [weak self] _ -> Observable<OWSingleUseTokenResponse> in
                guard let self = self else { return .empty() }
                return self.sharedServicesProvider.netwokAPI()
                    .profile
                    .createSingleUseToken()
                    .response
            }
            .observe(on: MainScheduler.instance)
            .withLatestFrom(user) { [weak self] response, user -> URL? in
                guard let self = self,
                      let token = response["single_use_token"],
                      let url = self.profileUrl(singleUseTicket: token, userId: user.id)
                else { return nil }
                return url
            }
            .unwrap()
            .subscribe(onNext: { [weak self] url in
                guard let self = self else { return }
                self._openAvatarProfile.onNext(url)
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
//        TODO
//        if Settings.helpers.shouldSuppressFinmbFilter {
//            // Current way for Yahoo internal testing for suppress finmb
//            // We will remove this noize from the code soon
//            url.appendQueryParam(name: Settings.tenantConfigCommentsFilter, value: "")
//        }

        return url
    }
}
