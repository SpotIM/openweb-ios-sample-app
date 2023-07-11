//
//  OWAnalyticsService.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 12/09/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWAnalyticsServicing {
    func sendAnalyticEvent(event: OWAnalyticEvent)
    func sendAnalyticEvents(events: [OWAnalyticEvent])
    func spotChanged(spotId: OWSpotId)
}

class OWAnalyticsService: OWAnalyticsServicing {
    fileprivate struct Metrics {
        static let maxEvents: Int = 10
        static let allEventsPlacholder: String = "all"
    }

    fileprivate let maxEventsForFlush: Int
    fileprivate let appLifeCycle: OWRxAppLifeCycleProtocol
    fileprivate var analyticsEvents = OWObservableArray<OWAnalyticEvent>()
    fileprivate var blockedEvents = BehaviorSubject<[String]>(value: [])

    fileprivate let flushEventsQueue = SerialDispatchQueueScheduler(qos: .background, internalSerialQueueName: "OpenWebSDKAnalyticsDispatchQueue")
    fileprivate let disposeBag = DisposeBag()

    init(maxEventsForFlush: Int = Metrics.maxEvents,
         appLifeCycle: OWRxAppLifeCycleProtocol = OWSharedServicesProvider.shared.appLifeCycle()) {
        self.maxEventsForFlush = maxEventsForFlush
        self.appLifeCycle = appLifeCycle

        setupObservers()
        setEventsStrategyConfig(spotId: OWManager.manager.spotId)
    }

    func sendAnalyticEvent(event: OWAnalyticEvent) {
        sendAnalyticEvents(events: [event])
    }

    func sendAnalyticEvents(events: [OWAnalyticEvent]) {
        analyticsEvents.append(contentsOf: events)
    }

    func spotChanged(spotId: OWSpotId) {
        setEventsStrategyConfig(spotId: spotId)
    }

}

fileprivate extension OWAnalyticsService {

    func flushEvents() {
        let api: OWAnalyticsAPI = OWSharedServicesProvider.shared.netwokAPI().analytics

        _ = Observable.just(())
            .flatMap { [weak self] _ -> Observable<[OWAnalyticEvent]> in
                guard let self = self else { return .empty()}
                return self.analyticsEvents
                    .rx_elements()
                    .take(1)
            }
            .withLatestFrom(self.blockedEvents) { items, blockedEvents -> [OWAnalyticEvent] in
                return items.filter { self.shouldSendEvent(event: $0, blockedEvents: blockedEvents)  }
            }
            .flatMap { items -> Observable<Bool> in
                return api.sendEvents(events: items)
                    .response
                    .exponentialRetry(maxAttempts: 2, millisecondsDelay: 1000)
                    .take(1)
            }
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.analyticsEvents.removeAll()
            }, onError: { error in
                OWSharedServicesProvider.shared.logger().log(level: .error, "flushEvents error \(error.localizedDescription)")
            })
            .subscribe()
    }

    func shouldSendEvent(event: OWAnalyticEvent, blockedEvents: [String]) -> Bool {
        let blockedEventsSet = Set(blockedEvents)
        if blockedEventsSet.contains(Metrics.allEventsPlacholder) {
            return false
        }
        return !blockedEventsSet.contains(event.type.eventName)
    }
}

// Rx
fileprivate extension OWAnalyticsService {
    func setupObservers() {
        let backgroundObservable = appLifeCycle.didEnterBackground
            .filter { [weak self] in
                guard let self = self else { return false }
                return !self.analyticsEvents.isEmpty
            }

        let maxEventObservable = analyticsEvents
            .rx_elements()
            .filter { [weak self] events in
                guard let self = self else { return false }
                return events.count >= self.maxEventsForFlush
            }
            .voidify()

        Observable.merge(backgroundObservable, maxEventObservable)
            .observe(on: flushEventsQueue)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.flushEvents()
            })
            .disposed(by: disposeBag)
    }

    func setEventsStrategyConfig(spotId: OWSpotId) {
        _ = OWSharedServicesProvider.shared.spotConfigurationService()
            .config(spotId: spotId)
            .take(1)
            .map { config in
                return config.mobileSdk.eventsStrategyConfig
            }
            .map { eventsStrategyConfig -> [String] in
                guard let eventsStrategyConfig = eventsStrategyConfig,
                      let currentSdkVersionString = OWSettingsWrapper.sdkVersion(),
                      let currentSdkVersion = OWVersion(from: currentSdkVersionString)
                else { return [] }

                // Check if need to block all events
                if let minVersionForEvents = eventsStrategyConfig.blockVersionsEqualOrPrevious,
                   minVersionForEvents >= currentSdkVersion {
                    return [Metrics.allEventsPlacholder]
                }

                // Check if need to block specific version
                if let eventsForCurrentVersion = eventsStrategyConfig.blockEventsByVersionMapper[currentSdkVersion] {
                    return eventsForCurrentVersion
                }
                return []
            }
            .subscribe(onNext: { [weak self] blockedEvents in
                guard let self = self else { return }
                self.blockedEvents.onNext(blockedEvents)
            })
    }
}
