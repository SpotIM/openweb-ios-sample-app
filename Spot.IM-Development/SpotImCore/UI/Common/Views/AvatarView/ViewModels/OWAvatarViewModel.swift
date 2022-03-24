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
    func configureUser(user: SPUser) // ??
}

protocol OWAvatarViewModelingOutputs {
    var imageUrl: Observable<URL?> { get }
    var showOnlineIndicator: Observable<Bool> { get }
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
    
    var imageUrl: Observable<URL?> {
        self.user
            .map { self.imageURLProvider?.imageURL(with: $0.imageId, size: nil) }
    }
    
    var showOnlineIndicator: Observable<Bool> {
        let disableOnlineIndicator = SPConfigsDataSource.appConfig?.conversation?.disableOnlineDotIndicator ?? false
        return user
            .map { ($0.online ?? false || $0.id == SPUserSessionHolder.session.user?.id) && !disableOnlineIndicator }
    }
    
    func configureUser(user: SPUser) {
        self._user.onNext(user)
    }
}
