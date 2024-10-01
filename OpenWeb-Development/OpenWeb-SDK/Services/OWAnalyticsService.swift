//
//  OWAnalyticsService.swift
//  OpenWebSDK
//
//  Created by  Nogah Melamed on 12/09/2022.
//  Copyright © 2022 OpenWeb. All rights reserved.
//

import Foundation
import RxSwift

protocol OWAnalyticsServicing {
    func sendAnalyticEvent(event: OWAnalyticEvent)
    func sendAnalyticEvents(events: [OWAnalyticEvent])
    func spotChanged(spotId: OWSpotId)
}

class OWAnalyticsService: OWAnalyticsServicing {
    private struct Metrics {
        static let maxEvents: Int = 10
        static let allEventsPlacholder: String = "all"
    }

    private let maxEventsForFlush: Int
    private let appLifeCycle: OWRxAppLifeCycleProtocol
    private var analyticsEvents = OWObservableArray<OWAnalyticEvent>()
    private var blockedEvents = BehaviorSubject<[String]>(value: [])
    private let analyticsEventCreatorService: OWAnalyticsEventCreatorServicing
    private let analyticsLayer: OWAnalyticsInternalProtocol
    private let appendEventsPublisher = PublishSubject<[OWAnalyticEvent]>()
    private let removeAllPublisher = PublishSubject<Void>()

    private let flushEventsQueue = SerialDispatchQueueScheduler(qos: .background, internalSerialQueueName: "OpenWebSDKAnalyticsDispatchQueue")
    private let disposeBag = DisposeBag()

    // swiftlint:disable force_cast
    init(maxEventsForFlush: Int = Metrics.maxEvents,
         appLifeCycle: OWRxAppLifeCycleProtocol = OWSharedServicesProvider.shared.appLifeCycle(),
         analyticsEventCreatorService: OWAnalyticsEventCreatorServicing = OWSharedServicesProvider.shared.analyticsEventCreatorService(),
         analyticsLayer: OWAnalyticsInternalProtocol = OpenWeb.manager.analytics as! OWAnalyticsInternalProtocol
    ) {
        self.maxEventsForFlush = maxEventsForFlush
        self.appLifeCycle = appLifeCycle
        self.analyticsEventCreatorService = analyticsEventCreatorService
        self.analyticsLayer = analyticsLayer

        setupObservers()
        setEventsStrategyConfig(spotId: OWManager.manager.spotId)
    }
    // swiftlint:enable force_cast

    func sendAnalyticEvent(event: OWAnalyticEvent) {
        sendAnalyticEvents(events: [event])
    }

    func sendAnalyticEvents(events: [OWAnalyticEvent]) {
        // Triggering BI events immediately
        events.forEach { event in
            if let biEvent = event.type.biAnalyticEvent {
                analyticsLayer.triggerBICallback(biEvent)
            }
        }
        appendEventsPublisher.onNext(events)
    }

    func spotChanged(spotId: OWSpotId) {
        setEventsStrategyConfig(spotId: spotId)
    }

}

private extension OWAnalyticsService {

    func flushEvents() {
        let api: OWAnalyticsAPI = OWSharedServicesProvider.shared.networkAPI().analytics

        _ = Observable.just(())
            .observe(on: flushEventsQueue)
            .flatMap { [weak self] _ -> Observable<[OWAnalyticEvent]> in
                guard let self else { return .empty()}
                return self.analyticsEvents
                    .rx_elements()
                    .take(1)
            }
            .withLatestFrom(self.blockedEvents) { [weak self] items, blockedEvents -> [OWAnalyticEvent] in
                guard let self else { return [] }
                return items.filter { [weak self] in
                    guard let self else { return false }
                    return self.shouldSendEvent(event: $0, blockedEvents: blockedEvents)
                }
            }
            .map { [weak self] event in
                guard let self else { return [] }
                return event.map {
                    self.analyticsEventCreatorService
                        .serverAnalyticEvent(from: $0)
                }
            }
            .filter { $0.count > 0 }
            .flatMap { items -> Observable<OWBatchAnalyticsResponse> in
                return api.sendEvents(events: items)
                    .response
                    .exponentialRetry(maxAttempts: 2, millisecondsDelay: 1000)
                    .take(1)
            }
            .do(onNext: { [weak self] _ in
                guard let self else { return }
                self.removeAllPublisher.onNext()
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
private extension OWAnalyticsService {
    func setupObservers() {
        // Appending events
        appendEventsPublisher
            .observe(on: flushEventsQueue)
            .subscribe(onNext: { [weak self] events in
                self?.analyticsEvents.append(contentsOf: events)
            })
            .disposed(by: disposeBag)

        // Removing all events
        removeAllPublisher
            .observe(on: flushEventsQueue)
            .subscribe(onNext: { [weak self] _ in
                self?.analyticsEvents.removeAll()
            })
            .disposed(by: disposeBag)

        let backgroundObservable = appLifeCycle.didEnterBackground
            .filter { [weak self] in
                guard let self else { return false }
                return !self.analyticsEvents.isEmpty
            }

        let maxEventObservable = analyticsEvents
            .rx_elements()
            .filter { [weak self] events in
                guard let self else { return false }
                return events.count >= self.maxEventsForFlush
            }
            .voidify()

        Observable.merge(backgroundObservable, maxEventObservable)
            .observe(on: flushEventsQueue)
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
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
                guard let eventsStrategyConfig,
                      let currentSdkVersionString = OWSettingsWrapper.sdkVersion(),
                      let currentSdkVersion = try? OWVersion(from: currentSdkVersionString)
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
                guard let self else { return }
                self.blockedEvents.onNext(blockedEvents)
            })
    }
}
