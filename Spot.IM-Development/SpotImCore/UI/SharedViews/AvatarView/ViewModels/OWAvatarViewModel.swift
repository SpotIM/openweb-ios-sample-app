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
    var openProfile: Observable<OWOpenProfileType> { get }
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
        return tapAvatar
            .withLatestFrom(self.shouldBlockAvatar)
            .filter { !$0 }
            .voidify()
            .flatMapLatest { [weak self] _ -> Observable<SPUser> in
                guard let self = self else { return .empty() }
                return self.user
                    .take(1)
            }
    }

    fileprivate var _openProfile = PublishSubject<OWOpenProfileType>()
    var openProfile: Observable<OWOpenProfileType> {
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
        Observable.combineLatest(
            self.userInput,
            self.shouldBlockAvatar.asObservable()
        )
            .flatMapLatest { [weak self] (user, shouldBlockAvatar) -> Observable<URL?> in
                guard let self = self,
                      let user = user,
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
            sharedServicesProvider.realtimeService().realtimeData,
            shouldBlockAvatar
        ) { [weak self] user, availability, config, realtimeData, avatarBlocked in
            guard config.conversation?.disableOnlineDotIndicator != true,
                  avatarBlocked == false
            else { return false }

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
            .flatMapLatest { [weak self] user -> Observable<OWOpenProfileType> in
                guard let self = self else { return .empty() }
                return self.sharedServicesProvider.profileService().openProfileTapped(user: user)
            }
            .observe(on: MainScheduler.instance)
            .bind(to: _openProfile)
            .disposed(by: disposeBag)
    }
}
