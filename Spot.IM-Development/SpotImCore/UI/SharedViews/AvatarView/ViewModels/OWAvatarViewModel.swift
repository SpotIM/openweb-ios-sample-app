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
    var openProfile: Observable<OWOpenProfileData> { get }
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
    var avatarTapped: Observable<SPUser> {
        return Observable.combineLatest(tapAvatar, shouldBlockAvatar)
            .filter { !$1 }
            .voidify()
            .flatMap { [weak self] _ -> Observable<SPUser> in
                guard let self = self else { return .empty() }
                return self.user
            }
    }

    fileprivate var _openProfile = PublishSubject<OWOpenProfileData>()
    var openProfile: Observable<OWOpenProfileData> {
        _openProfile
            .asObservable()
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
            .flatMapLatest { [weak self] (user, shouldBlockAvatar) -> Observable<URL?> in
                guard let self = self,
                      let imageId = user.imageId,
                      !shouldBlockAvatar
                else { return Observable.just(nil) }

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
            sharedServicesProvider.spotConfigurationService().config(spotId: OWManager.manager.spotId),
            sharedServicesProvider.realtimeService().realtimeData
        ) { [weak self] user, availability, config, realtimeData in
            guard config.conversation?.disableOnlineDotIndicator != true else { return false }

            if (user.online == true) {
                return true
            }

            if let userId = user.id,
               let postId = OWManager.manager.postId,
               let realtimeData = realtimeData.data,
               let usersService = self?.sharedServicesProvider.usersService(),
               usersService.isUserOnline(userId, perPostId: postId, realtimeData: realtimeData) == true {
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
}

fileprivate extension OWAvatarViewModel {
    func setupObservers() {
        avatarTapped
            .flatMap { [weak self] user -> Observable<OWOpenProfileData> in
                guard let self = self else { return .empty() }
                return self.sharedServicesProvider.profileService().openProfileTapped(user: user)
            }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] profileData in
                self?._openProfile.onNext(profileData)
            })
            .disposed(by: disposeBag)
    }
}
