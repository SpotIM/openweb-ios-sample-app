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
    
    fileprivate let imageURLProvider: SPImageProvider?
    
    var tapAvatar = PublishSubject<Void>()
    
    init (user: SPUser? = nil,
          imageURLProvider: SPImageProvider?) {
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
            .map {
                if let url = self.imageURLProvider?.imageURL(with: $0.imageId, size: nil) {
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
            .asObserver()
    }
    
    func configureUser(user: SPUser) {
        self._user.onNext(user)
    }
}
