//
//  OWAvatarViewModel.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 24/03/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

protocol OWAvatarViewModelingInputs {
    func configureUser(user: SPUser)
    func changeAvatarVisibility(isVisible: Bool)
    
    var tapAvatar: PublishSubject<Void> { get }
}

protocol OWAvatarViewModelingOutputs {
    var imageType: Observable<OWImageType> { get }
    var showOnlineIndicator: Observable<Bool> { get }
    
    var avatarTapped: Observable<Void> { get }
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
    
    fileprivate let _user = BehaviorSubject<SPUser?>(value: nil)
    fileprivate let _isAvatartVisible = BehaviorSubject<Bool?>(value: nil)
    
    fileprivate let imageURLProvider: SPImageProvider?
    
    var tapAvatar = PublishSubject<Void>()
    
    init (user: SPUser? = nil, imageURLProvider: SPImageProvider? = nil) {
        self.imageURLProvider = imageURLProvider
        
        if let user = user {
            configureUser(user: user)
        }
    }
    
    fileprivate lazy var user: Observable<SPUser> = {
        self._user
            .unwrap()
    }()
    
    fileprivate lazy var isAvatartVisible: Observable<Bool> = {
        self._isAvatartVisible
            .unwrap()
    }()
    
    var imageType: Observable<OWImageType> {
        Observable.combineLatest(user, isAvatartVisible)
            .map { user, isAvatartVisible in
                if let url = self.imageURLProvider?.imageURL(with: user.imageId, size: nil),
                    isAvatartVisible {
                    return .custom(url: url)
                }
                return .defaultImage
            }
    }
    
    var showOnlineIndicator: Observable<Bool> {
        let shouldDisableOnlineIndicator = SPConfigsDataSource.appConfig?.conversation?.disableOnlineDotIndicator ?? false
        return user
            .map { user in
                let isCurrentUser = user.id == SPUserSessionHolder.session.user?.id
                let isUserOnline = (user.online ?? false) || isCurrentUser
                return isUserOnline && !shouldDisableOnlineIndicator
            }
    }
    
    var avatarTapped: Observable<Void> {
        tapAvatar
            .asObservable()
    }
    
    func configureUser(user: SPUser) {
        self._user.onNext(user)
    }
    
    func changeAvatarVisibility(isVisible: Bool) {
        self._isAvatartVisible.onNext(isVisible)
    }
}


// TODO: this VM uses the new ImageProvider, once refactor is done old VM should be deleted
class OWAvatarViewModelV2: OWAvatarViewModeling,
                         OWAvatarViewModelingInputs,
                         OWAvatarViewModelingOutputs {
    
    var inputs: OWAvatarViewModelingInputs { return self }
    var outputs: OWAvatarViewModelingOutputs { return self }
    
    fileprivate let _user = BehaviorSubject<SPUser?>(value: nil)
    fileprivate let _isAvatartVisible = BehaviorSubject<Bool?>(value: nil)
    
    fileprivate let imageURLProvider: OWImageProviding
    
    var tapAvatar = PublishSubject<Void>()
    
    init (user: SPUser? = nil, imageURLProvider: OWImageProviding = OWCloudinaryImageProvider()) {
        self.imageURLProvider = imageURLProvider
        
        if let user = user {
            configureUser(user: user)
        }
    }
    
    fileprivate lazy var user: Observable<SPUser> = {
        self._user
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
    }
    
    var showOnlineIndicator: Observable<Bool> {
        let shouldDisableOnlineIndicator = SPConfigsDataSource.appConfig?.conversation?.disableOnlineDotIndicator ?? false
        return user
            .map { user in
                let isCurrentUser = user.id == SPUserSessionHolder.session.user?.id
                let isUserOnline = (user.online ?? false) || isCurrentUser
                return isUserOnline && !shouldDisableOnlineIndicator
            }
    }
    
    var avatarTapped: Observable<Void> {
        tapAvatar
            .asObservable()
    }
    
    func configureUser(user: SPUser) {
        self._user.onNext(user)
    }
    
    func changeAvatarVisibility(isVisible: Bool) {
        self._isAvatartVisible.onNext(isVisible)
    }
}

