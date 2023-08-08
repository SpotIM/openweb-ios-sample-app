//
//  OWSortingCustomizer.swift
//  SpotImCore
//
//  Created by Alon Haiut on 08/11/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

protocol OWSortingCustomizationsInternal {
    func customizedTitle(forOption sortOption: OWSortOption) -> OWCustomizedSortTitle
}

class OWSortingCustomizer: OWSortingCustomizations, OWSortingCustomizationsInternal {

    fileprivate var customizationTitleMapper: [OWSortOption: String] = [:]

    var initialOption: OWInitialSortStrategy = .useServerConfig {
        didSet {
            sendEvent(for: .configuredInitialSort(initialSort: initialOption))
        }
    }

    func setTitle(_ title: String, forOption sortOption: OWSortOption) {
        customizationTitleMapper[sortOption] = title
        sendEvent(for: .configureSortTitle(sort: sortOption, title: title))
    }

    func customizedTitle(forOption sortOption: OWSortOption) -> OWCustomizedSortTitle {
        guard let title = customizationTitleMapper[sortOption] else {
            return .none
        }

        return .customized(title: title)
    }
}

fileprivate extension OWSortingCustomizer {
    func event(for eventType: OWAnalyticEventType) -> OWAnalyticEvent {
        return OWSharedServicesProvider.shared
            .analyticsEventCreatorService()
            .analyticsEvent(
                for: eventType,
                articleUrl: "",
                layoutStyle: .none,
                component: .none)
    }

    func sendEvent(for eventType: OWAnalyticEventType) {
        let event = event(for: eventType)
        OWSharedServicesProvider.shared
            .analyticsService()
            .sendAnalyticEvents(events: [event])
    }
}
