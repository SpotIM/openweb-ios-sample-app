//
//  OWLoggerConfigurationLayer.swift
//  SpotImCore
//
//  Created by Alon Haiut on 21/02/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

class OWLoggerConfigurationLayer: OWLoggerConfiguration {
    fileprivate let servicesProvider: OWSharedServicesProviding
    fileprivate var _logLevel: OWLogLevel = .verbose
    fileprivate var _logMethods: [OWLogMethod] = []

    init(servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.servicesProvider = servicesProvider
    }

    var level: OWLogLevel {
        get {
            return _logLevel
        }
        set(newLevel) {
            _logLevel = newLevel
            configureLogger()
        }
    }

    var methods: [OWLogMethod] {
        get {
            return _logMethods
        }
        set(newMethods) {
            _logMethods = newMethods
            configureLogger()
        }
    }
}

fileprivate extension OWLoggerConfigurationLayer {
    func configureLogger() {
        guard let servicesProviderConfigure = servicesProvider as? OWSharedServicesProviderConfigure else {
            let logMessage = "Failed casting `OWSharedServicesProvider` to `OWSharedServicesProviderConfigure` protocol, can't configure logger settings"
            servicesProvider.logger().log(level: .error, logMessage)
            return
        }

        servicesProviderConfigure.configureLogger(logLevel: _logLevel, logMethods: _logMethods)
    }
}
