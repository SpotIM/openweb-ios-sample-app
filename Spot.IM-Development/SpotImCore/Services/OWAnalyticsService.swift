//
//  OWAnalyticsService.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 12/09/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

fileprivate let MAX_EVENTS = 10 // TODO: change if needed

protocol OWAnalyticsServicing {
    func sendAnalyticEvent(event: OWAnalyticEvent)
    func sendAnalyticEvents(events: [OWAnalyticEvent])
}

class OWAnalyticsService: OWAnalyticsServicing {
    fileprivate let maxEventsForFlush: Int
    fileprivate var events: [OWAnalyticEvent]
    
    init(maxEventsForFlush: Int = MAX_EVENTS) {
        self.maxEventsForFlush = maxEventsForFlush
        events = []
    }
    
    func sendAnalyticEvent(event: OWAnalyticEvent) {
    }
    
    func sendAnalyticEvents(events: [OWAnalyticEvent]) {
    }
    
    
}
