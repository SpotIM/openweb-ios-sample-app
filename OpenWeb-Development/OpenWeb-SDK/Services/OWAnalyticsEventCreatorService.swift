//
//  OWAnalyticsEventCreatorService.swift
//  OpenWebSDK
//
//  Created by  Nogah Melamed on 12/07/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

protocol OWAnalyticsEventCreatorServicing {
    func analyticEvent(for type: OWAnalyticEventType, articleUrl: String, layoutStyle: OWLayoutStyle, component: OWAnalyticSourceType) -> OWAnalyticEvent
    func serverAnalyticEvent(from event: OWAnalyticEvent) -> OWAnalyticEventServer
}

class OWAnalyticsEventCreatorService: OWAnalyticsEventCreatorServicing {
    private var userStatus: String = ""
    private var userId: String = ""

    private unowned let servicesProvider: OWSharedServicesProviding
    private let disposeBag = DisposeBag()

    init(servicesProvider: OWSharedServicesProviding) {
        self.servicesProvider = servicesProvider

        setupObservers()
    }

    func analyticEvent(for type: OWAnalyticEventType, articleUrl: String, layoutStyle: OWLayoutStyle, component: OWAnalyticSourceType) -> OWAnalyticEvent {
        let generalDataDynamicPart = OWAnalyticEventGeneralDataDynamicPart(spotId: OWManager.manager.spotId,
                                                                           postId: OWManager.manager.postId ?? "",
                                                                           pageViewId: servicesProvider.pageViewIdHolder().pageViewId,
                                                                           userStatus: userStatus,
                                                                           userId: userId,
                                                                           guid: servicesProvider.authenticationManager().networkCredentials.guid ?? "",
                                                                           articleUrl: articleUrl,
                                                                           layoutStyle: layoutStyle)

        return OWAnalyticEvent(
            type: type,
            timestamp: Date().timeIntervalSince1970 * 1000,
            component: component,
            generalDataDynamicPart: generalDataDynamicPart
        )
    }

    func serverAnalyticEvent(from event: OWAnalyticEvent) -> OWAnalyticEventServer {
        let generalData = OWAnalyticEventServerGeneralData(
            spotId: event.generalDataDynamicPart.spotId,
            postId: event.generalDataDynamicPart.postId,
            articleUrl: event.generalDataDynamicPart.articleUrl,
            pageViewId: event.generalDataDynamicPart.pageViewId,
            userStatus: event.generalDataDynamicPart.userStatus,
            userId: event.generalDataDynamicPart.userId,
            deviceId: UIDevice.current.identifierForVendor?.uuidString ?? "",
            guid: event.generalDataDynamicPart.guid,
            platform: "ios_phone",
            platformVersion: UIDevice.current.systemVersion,
            sdkVersion: OWSettingsWrapper.sdkVersion() ?? "",
            hostAppVersion: Bundle.main.shortVersion ?? "",
            hostAppScheme: Bundle.main.bundleIdentifier ?? "",
            deviceType: UIDevice.current.deviceName(),
            layoutStyle: event.generalDataDynamicPart.layoutStyle.rawValue
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

private extension OWAnalyticsEventCreatorService {
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
