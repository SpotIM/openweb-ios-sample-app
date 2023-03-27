//
//  OWSubscriberIconViewModel.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 22/03/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

protocol OWSubscriberIconViewModelingInputs {
}

protocol OWSubscriberIconViewModelingOutputs {
    var image: Observable<UIImage> { get }
    var isSubscriber: Observable<Bool> { get }
}

protocol OWSubscriberIconViewModeling {
    var inputs: OWSubscriberIconViewModelingInputs { get }
    var outputs: OWSubscriberIconViewModelingOutputs { get }
}

class OWSubscriberIconViewModel: OWSubscriberIconViewModeling,
                                 OWSubscriberIconViewModelingInputs,
                                 OWSubscriberIconViewModelingOutputs {

    var inputs: OWSubscriberIconViewModelingInputs { return self }
    var outputs: OWSubscriberIconViewModelingOutputs { return self }

    fileprivate let _user = BehaviorSubject<SPUser?>(value: nil)
    fileprivate var subscriberBadgeService: OWSubscriberBadgeServicing!
    fileprivate var servicesProvider: OWSharedServicesProviding

    init (user: SPUser,
          servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared,
          subscriberBadgeService: OWSubscriberBadgeServicing = OWSubscriberBadgeService()) {
        self.subscriberBadgeService = subscriberBadgeService
        self.servicesProvider = servicesProvider

        _user.onNext(user)
    }

    fileprivate lazy var user: Observable<SPUser> = {
        self._user
            .unwrap()
    }()

    fileprivate lazy var subscriberBadgeConfig: Observable<OWSubscriberBadgeConfiguration> = {
        servicesProvider.spotConfigurationService()
            .config(spotId: OWManager.manager.spotId)
            .map { config in
                config.conversation?.subscriberBadgeConfig
            }
            .unwrap()
    }()

    var image: Observable<UIImage> {
        isSubscriber
            .filter { $0 } // Only start the download of the image (or caching retrieve) if the user is a subscriber
            .withLatestFrom(subscriberBadgeConfig) { [weak self] _, config -> Observable<UIImage>? in
                guard let self = self else { return nil }
                return self.subscriberBadgeService.badgeImage(config: config)
            }
            .unwrap()
            .flatMap { $0 }
            .asDriver(onErrorJustReturn: UIImage(spNamed: "verifyIcon", supportDarkMode: false)!)
            .asObservable()
    }

    var isSubscriber: Observable<Bool> {
        return user
            .map { $0.ssoData?.isSubscriber ?? false}
    }
}
