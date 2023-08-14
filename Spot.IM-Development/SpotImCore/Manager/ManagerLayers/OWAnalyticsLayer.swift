//
//  OWAnalyticsLayer.swift
//  SpotImCore
//
//  Created by Alon Haiut on 06/07/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

// TODO: move to new files
#if NEW_API
public typealias OWCustomBIData = [String: String]
#else
typealias OWCustomBIData = [String: String]
#endif

// TODO: what event we want here?
#if NEW_API
public typealias OWAnalyticEventCallback = (String) -> Void
#else
typealias OWAnalyticEventCallback = (String) -> Void
#endif

protocol OWAnalyticsInternalProtocol {
    func triggerBICallback(_ event: String)
    func clearCallbacks()
}

class OWAnalyticsLayer: OWAnalytics, OWAnalyticsInternalProtocol {
    fileprivate struct Metrics {
        static let maxBIEventsCallbacksNumber: Int = 10
    }

    var customBIData: OWCustomBIData = [:]
    fileprivate var callbacks = [OWOptionalEncapsulation<OWAnalyticEventCallback>]()

    func addBICallback(_ callback: @escaping OWAnalyticEventCallback) {
        guard callbacks.count < Metrics.maxBIEventsCallbacksNumber else {
            let logger = OWSharedServicesProvider.shared.logger()
            logger.log(level: .error,
                       "`addBICallback` function can accept up to \(Metrics.maxBIEventsCallbacksNumber) different callbacks. This number was already reached.")
            return
        }

        let optionalCallback = OWOptionalEncapsulation(value: callback)
        callbacks.append(optionalCallback)
    }

    func triggerBICallback(_ event: String) { // TODO: propper data - not string
        let postId = OWManager.manager.postId

        callbacks.forEach { optionalCallback in
            guard let actualCallback = optionalCallback.value() else { return }
            actualCallback(event)
        }
    }

    func clearCallbacks() {
        callbacks.removeAll()
    }
}
