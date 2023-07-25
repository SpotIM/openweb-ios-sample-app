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
    func analyticsEvent(for type: OWAnalyticEventType, articleUrl: String, layoutStyle: OWLayoutStyle, component: OWViewSourceType) -> OWAnalyticEvent
    func serverAnalyticEvent(from event: OWAnalyticEvent) -> OWAnalyticEventServer
}

class OWAnalyticsEventCreatorService: OWAnalyticsEventCreatorServicing {
    fileprivate var userStatus: String = ""
    fileprivate var userId: String = ""

    fileprivate unowned let servicesProvider: OWSharedServicesProviding
    fileprivate let disposeBag = DisposeBag()

    init(servicesProvider: OWSharedServicesProviding) {
        self.servicesProvider = servicesProvider

        setupObservers()
    }

    func analyticsEvent(for type: OWAnalyticEventType, articleUrl: String, layoutStyle: OWLayoutStyle, component: OWViewSourceType) -> OWAnalyticEvent {
        return OWAnalyticEvent(
            type: type,
            timestamp: (Int(Date().timeIntervalSince1970) * 1000),
            articleUrl: articleUrl,
            layoutStyle: layoutStyle,
            component: component
        )
    }

    func serverAnalyticEvent(from event: OWAnalyticEvent) -> OWAnalyticEventServer {
        let generalData = OWAnalyticEventServerGeneralData(
            spotId: OWManager.manager.spotId,
            postId: OWManager.manager.postId ?? "",
            articleUrl: event.articleUrl,
            pageViewId: "", // TODO: we should create the correct logic for pageViewId in OWAnalyticsService
            userStatus: userStatus,
            userId: userId,
            deviceId: UIDevice.current.identifierForVendor?.uuidString ?? "",
            guid: servicesProvider.authenticationManager().networkCredentials.guid ?? "",
            platform: "ios_phone",
            platformVersion: UIDevice.current.systemVersion,
            sdkVersion: OWSettingsWrapper.sdkVersion() ?? "",
            hostAppVersion: Bundle.main.shortVersion ?? "",
            hostAppScheme: Bundle.main.bundleIdentifier ?? "",
            deviceType: UIDevice.current.deviceName(),
            layoutStyle: event.layoutStyle.rawValue
        )

        return OWAnalyticEventServer(
            eventName: event.type.eventName,
            eventGroup: event.type.eventGroup.rawValue,
            eventTimestamp: event.timestamp,
            productName: .conversation,
            componentName: event.component.analyticsComponentName,
            payload: event.type.payload,
            generalData: generalData,
            abTests: OWAnalyticEventServerAbTest(selectedTests: [], affectiveTests: [])
        )
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
