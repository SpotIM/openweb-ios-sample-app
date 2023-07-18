//
//  OWAnalyticsEventCreatorService.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 12/07/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWAnalyticsEventCreatorServicing {
    func analyticsEvent(for type: OWAnalyticEventType, articleUrl: String, layoutStyle: OWLayoutStyle, component: OWAnalyticsComponent) -> OWAnalyticEventServer
}

class OWAnalyticsEventCreatorService: OWAnalyticsEventCreatorServicing {
    fileprivate var userStatus: String = ""
    fileprivate var userId: String = ""

    fileprivate let servicesProvider: OWSharedServicesProviding
    fileprivate let disposeBag = DisposeBag()

    init(servicesProvider: OWSharedServicesProviding) {
        self.servicesProvider = servicesProvider

        setupObservers()
    }

    func analyticsEvent(for type: OWAnalyticEventType, articleUrl: String, layoutStyle: OWLayoutStyle, component: OWAnalyticsComponent) -> OWAnalyticEventServer {
        return OWAnalyticEvent(
            type: type,
            timestamp: Date().timeIntervalSince1970 * 1000,
            articleUrl: articleUrl,
            layoutStyle: layoutStyle,
            component: component,
            userStatus: userStatus,
            userId: userId,
            guid: servicesProvider.authenticationManager().networkCredentials.guid ?? "")
        .analyticEventServer()
    }
}

fileprivate extension OWAnalyticsEventCreatorService {
    func setupObservers() {
        servicesProvider.authenticationManager()
            .currentAuthenticationLevelAvailability
            .subscribe(onNext: { [weak self] availability in
                guard let self = self else { return }
                switch availability {
                case .level(let level):
                    switch level {
                    case .notAutenticated:
                        self.userStatus = "notAutenticated"
                    case .guest:
                        self.userStatus = "guest"
                    case .loggedIn:
                        self.userStatus = "loggedIn"
                    }
                case .pending:
                    return
                }
            })
            .disposed(by: disposeBag)

        servicesProvider.authenticationManager()
            .activeUserAvailability
            .subscribe(onNext: { [weak self] availability in
                guard let self = self else { return }
                switch availability {
                case .notAvailable:
                    self.userId = ""
                case .user(let user):
                    self.userId = user.userId ?? ""
                }
            })
            .disposed(by: disposeBag)
    }
}
