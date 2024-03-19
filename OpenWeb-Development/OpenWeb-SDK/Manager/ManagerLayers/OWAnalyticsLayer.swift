//
//  OWAnalyticsLayer.swift
//  OpenWebSDK
//
//  Created by Alon Haiut on 06/07/2022.
//  Copyright © 2022 OpenWeb. All rights reserved.
//

import Foundation

protocol OWAnalyticsInternalProtocol {
    func triggerBICallback(_ event: OWBIAnalyticEvent)
    func clearCallbacks()
}

class OWAnalyticsLayer: OWAnalytics, OWAnalyticsInternalProtocol {
    fileprivate struct Metrics {
        static let maxBIEventsCallbacksNumber: Int = 10
    }

    var customBIData: OWCustomBIData = [:]
    fileprivate var callbacks = [OWOptionalEncapsulation<OWBIAnalyticEventCallback>]()
    fileprivate let queue = DispatchQueue(label: "OpenWebSDKBIEventCallback", qos: .utility)

    func addBICallback(_ callback: @escaping OWBIAnalyticEventCallback) {
        guard callbacks.count < Metrics.maxBIEventsCallbacksNumber else {
            let logger = OWSharedServicesProvider.shared.logger()
            logger.log(level: .error,
                       "`addBICallback` function can accept up to \(Metrics.maxBIEventsCallbacksNumber) different callbacks. This number was already reached.")
            return
        }

        let optionalCallback = OWOptionalEncapsulation(value: callback)
        callbacks.append(optionalCallback)
    }

    func triggerBICallback(_ event: OWBIAnalyticEvent) {
        guard let postId = OWManager.manager.postId else { return }
        queue.async { [weak self] in
            guard let self = self else { return }
            self.callbacks.forEach { optionalCallback in
                guard let actualCallback = optionalCallback.value() else { return }
                actualCallback(event, OWBIAnalyticAdditionalInfo(customBIData: self.customBIData), postId)
            }
        }
    }

    func clearCallbacks() {
        callbacks.removeAll()
    }
}
