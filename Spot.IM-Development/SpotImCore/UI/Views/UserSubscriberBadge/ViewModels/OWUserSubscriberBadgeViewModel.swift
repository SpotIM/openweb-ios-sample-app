//
//  OWUserSubscriberBadgeViewModel.swift
//  SpotImCore
//
//  Created by Tomer Ben Rachel on 26/01/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

protocol OWUserSubscriberBadgeViewModelingInputs {
    func configureUser(user: SPUser)
}

protocol OWUserSubscriberBadgeViewModelingOutputs {
    var image: Observable<UIImage> { get }
    var isSubscriber: Observable<Bool> { get }
}

protocol OWUserSubscriberBadgeViewModeling {
    var inputs: OWUserSubscriberBadgeViewModelingInputs { get }
    var outputs: OWUserSubscriberBadgeViewModelingOutputs { get }
}

class OWUserSubscriberBadgeViewModel: OWUserSubscriberBadgeViewModeling,
                                      OWUserSubscriberBadgeViewModelingInputs,
                                      OWUserSubscriberBadgeViewModelingOutputs {
    
    var inputs: OWUserSubscriberBadgeViewModelingInputs { return self }
    var outputs: OWUserSubscriberBadgeViewModelingOutputs { return self }
    
    fileprivate let _user = BehaviorSubject<SPUser?>(value: nil)
    fileprivate var subscriberBadgeConfig: OWSubscriberBadgeConfiguration?
    fileprivate var subscriberBadgeService: SubscriberBadgeServicing!
    
    init (user: SPUser? = nil,
          subscriberBadgeConfig: OWSubscriberBadgeConfiguration? = SPConfigsDataSource.appConfig?.conversation?.subscriberBadge,
          subscriberBadgeService: SubscriberBadgeServicing = SubscriberBadgeService()) {
        self.subscriberBadgeService = subscriberBadgeService
        self.subscriberBadgeConfig = subscriberBadgeConfig
        
        if let user = user {
            configureUser(user: user)
        }
    }
    
    fileprivate lazy var user: Observable<SPUser> = {
        self._user
            .unwrap()
    }()
    
    var image: Observable<UIImage> {
        user
            .map { [weak self] _ -> OWSubscriberBadgeConfiguration? in
                guard let self = self else { return nil }
                return self.subscriberBadgeConfig
            }
            .unwrap()
            .flatMap { [weak self] config -> Observable<UIImage> in
                guard let self = self else { return Observable.empty() }
                return self.subscriberBadgeService.badgeImage(config: config)
            }
    }
    
    var isSubscriber: Observable<Bool> {
        return user
            .map { $0.ssoData?.isSubscriber ?? false}
    }
    
    func configureUser(user: SPUser) {
        self._user.onNext(user)
    }
}
