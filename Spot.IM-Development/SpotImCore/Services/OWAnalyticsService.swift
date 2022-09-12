//
//  OWAnalyticsService.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 12/09/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

fileprivate let MAX_EVENTS = 10 // TODO: change if needed

protocol OWAnalyticsServicing {
    func sendAnalyticEvent(event: OWAnalyticEvent)
    func sendAnalyticEvents(events: [OWAnalyticEvent])
}

class OWAnalyticsService: OWAnalyticsServicing {
    fileprivate let maxEventsForFlush: Int
    fileprivate let appLifeCycle: OWRxAppLifeCycleProtocol
    fileprivate var analyticsEvents: [OWAnalyticEvent]
    
    fileprivate let flushEventsQueue = DispatchQueue(label: "OpenWebSDKAnalyticsDispatchQueue", qos: .background) // Serial queue
    fileprivate let disposeBag = DisposeBag()
    
    init(maxEventsForFlush: Int = MAX_EVENTS,
         appLifeCycle: OWRxAppLifeCycleProtocol = OWSharedServicesProvider.shared.appLifeCycle()) {
        self.maxEventsForFlush = maxEventsForFlush
        self.appLifeCycle = appLifeCycle
        analyticsEvents = []
        
        setupObservers()
    }
    
    func sendAnalyticEvent(event: OWAnalyticEvent) {
        flushEventsQueue.async { [weak self] in
            guard let self = self else { return }
            self.analyticsEvents.append(event)
            self.flushEventsIfNeeded()
        }
    }
    
    func sendAnalyticEvents(events: [OWAnalyticEvent]) {
        flushEventsQueue.async { [weak self] in
            guard let self = self else { return }
            self.analyticsEvents.append(contentsOf: events)
            self.flushEventsIfNeeded()
        }
    }
    
}

fileprivate extension OWAnalyticsService {
    func flushEventsIfNeeded() {
        if analyticsEvents.count >= maxEventsForFlush {
            flushEvents()
        }
    }
    
    // TODO: perhaps some retry/report is needed if `analytics.sendEvents` fails ?
    func flushEvents() {
        let api: OWAnalyticsAPI = OWSharedServicesProvider.shared.netwokAPI().analytics
        let dummyEvent = SPEventInfo(eventType: "aaa", source: "aaa", isRegistered: true, splitName: "aaa", itemType: nil, targetType: nil, segment: nil, lang: nil, domain: nil, userId: nil, messageId: nil, relatedMessageId: nil, readingSeconds: nil, itemId: nil, totalComments: nil, engineStatusType: nil, publisherCustomData: nil, targetUrl: nil)
        
        Observable.just(())
            .flatMap {
                // TODO: shoule be api.sendEvents(events: analyticsEvents)
                return api.sendEvent(info: dummyEvent)
                    .response
                    .take(1)
                    .do(onNext: { [weak self] res in
                        guard let self = self else { return }
                        if res {
                            self.analyticsEvents = []
                        } else {
                            OWSharedServicesProvider.shared.logger().log(level: .error, "flushEvents result is false")
                            // TODO: should we self.analyticsEvents = [] ?
                        }
                    }, onError: { error in
                        OWSharedServicesProvider.shared.logger().log(level: .error, "flushEvents error \(error.localizedDescription)")
                        // TODO: should we self.analyticsEvents = [] ?
                    })
            }
            .subscribe()
            .disposed(by: disposeBag)
    }
}

// Rx
fileprivate extension OWAnalyticsService {
    func setupObservers() {
        appLifeCycle.didEnterBackground
            .filter { [weak self] in
                guard let self = self else { return false }
                return !self.analyticsEvents.isEmpty
            }
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.flushEventsQueue.async { [weak self] in
                    guard let self = self else { return }
                    self.flushEvents()
                }
            })
            .disposed(by: disposeBag)
    }
}
