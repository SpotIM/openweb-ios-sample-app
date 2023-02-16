//
//  OWSharedServicesProvider.swift
//  SpotImCore
//
//  Created by Alon Haiut on 07/03/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import UIKit

protocol OWSharedServicesProviderConfigure {
    func configureLogger(logLevel: OWLogLevel, logMethods: [OWLogMethod])
    func set(spotId: OWSpotId)
    // If spotId re-set, this function should be called to re-prepare all the services which require a spotId
    func change(spotId: OWSpotId)
}

protocol OWSharedServicesProviding: AnyObject {
    var configure: OWSharedServicesProviderConfigure { get }
    func themeStyleService() -> OWThemeStyleServicing
    func imageCacheService() -> OWCacheService<String, UIImage>
    func commentsInMemoryCacheService() -> OWCacheService<String, String>
    func netwokAPI() -> OWNetworkAPIProtocol
    func logger() -> OWLogger
    func appLifeCycle() -> OWRxAppLifeCycleProtocol
    func keychain() -> OWKeychainProtocol
    func analyticsService() -> OWAnalyticsServicing
    // Remove this migration service within half a year from now
    func keychainMigrationService() -> OWKeychainMigrationServicing
    func userDefaults() -> OWUserDefaultsProtocol
    func realtimeService() -> OWRealtimeServicing
    func spotConfigurationService() -> OWSpotConfigurationServicing
    func skeletonShimmeringService() -> OWSkeletonShimmeringServicing
    func authorizationRecoveryService() -> OWAuthorizationRecoveryServicing
    func timeMeasuringService() -> OWTimeMeasuringServicing
    func sortDictateService() -> OWSortDictateServicing
}

class OWSharedServicesProvider: OWSharedServicesProviding {

    // Singleton
    static let shared: OWSharedServicesProviding = OWSharedServicesProvider()

    private init() {}

    var configure: OWSharedServicesProviderConfigure { return self }

    fileprivate lazy var _themeStyleService: OWThemeStyleServicing = {
        return OWThemeStyleService()
    }()

    fileprivate lazy var _imageCacheService: OWCacheService<String, UIImage> = {
        return OWCacheService<String, UIImage>()
    }()

    fileprivate lazy var _commentsInMemoryCacheService: OWCacheService<String, String> = {
        return OWCacheService<String, String>()
    }()

    fileprivate lazy var _networkAPI: OWNetworkAPIProtocol = {
        /*
         By default we create the network once.
         If we will want to "reset" everything when a new spotIfy provided, we can re-create the network entirely.
         Note that the environment is being set in the `OWEnvironment` class which we can set in an earlier step by some
         environment variable / flag in Xcode scheme configuration.
         */
        return OWNetworkAPI(environment: OWEnvironment.currentEnvironment)
    }()

    fileprivate lazy var _logger: OWLogger = {
        var methods: [OWLogMethod] = [.nsLog, .file(maxFilesNumber: OWLogger.Metrics.defaultLogFilesNumber)]
        let logger = OWLogger(logLevel: .verbose, logMethods: methods)
        logger.log(level: .verbose, "Logger initialized")
        return logger
    }()

    fileprivate lazy var _appLifeCycle: OWRxAppLifeCycleProtocol = {
        return OWRxAppLifeCycle()
    }()

    fileprivate lazy var _keychain: OWKeychainProtocol = {
        return OWKeychain(servicesProvider: self)
    }()

    fileprivate lazy var _analyticsService: OWAnalyticsServicing = {
        return OWAnalyticsService()
    }()

    fileprivate lazy var _keychainMigration: OWKeychainMigrationServicing = {
        return OWKeychainMigrationService(servicesProvider: self)
    }()

    fileprivate lazy var _userDefaults: OWUserDefaultsProtocol = {
        return OWUserDefaults(servicesProvider: self)
    }()

    fileprivate lazy var _realtimeService: OWRealtimeServicing = {
        return OWRealtimeService(servicesProvider: self)
    }()

    fileprivate lazy var _spotConfigurationService: OWSpotConfigurationServicing = {
        return OWSpotConfigurationService(servicesProvider: self)
    }()

    fileprivate lazy var _skeletonShimmeringService: OWSkeletonShimmeringServicing = {
        return OWSkeletonShimmeringService(config: OWSkeletonShimmeringConfiguration.default)
    }()

    fileprivate lazy var _authorizationRecoveryService: OWAuthorizationRecoveryServicing = {
        return OWAuthorizationRecoveryService(servicesProvider: self)
    }()

    fileprivate lazy var _timeMeasuringService: OWTimeMeasuringServicing = {
        return OWTimeMeasuringService()
    }()

    fileprivate lazy var _sortDictateService: OWSortDictateServicing = {
        return OWSortDictateService(servicesProvider: self)
    }()

    func themeStyleService() -> OWThemeStyleServicing {
        return _themeStyleService
    }

    func imageCacheService() -> OWCacheService<String, UIImage> {
        return _imageCacheService
    }

    func commentsInMemoryCacheService() -> OWCacheService<String, String> {
        return _commentsInMemoryCacheService
    }

    func netwokAPI() -> OWNetworkAPIProtocol {
        return _networkAPI
    }

    func logger() -> OWLogger {
        return _logger
    }

    func appLifeCycle() -> OWRxAppLifeCycleProtocol {
        return _appLifeCycle
    }

    func keychain() -> OWKeychainProtocol {
        return _keychain
    }

    func keychainMigrationService() -> OWKeychainMigrationServicing {
        return _keychainMigration
    }

    func userDefaults() -> OWUserDefaultsProtocol {
        return _userDefaults
    }

    func realtimeService() -> OWRealtimeServicing {
        return _realtimeService
    }

    func spotConfigurationService() -> OWSpotConfigurationServicing {
        return _spotConfigurationService
    }

    func analyticsService() -> OWAnalyticsServicing {
        return _analyticsService
    }

    func skeletonShimmeringService() -> OWSkeletonShimmeringServicing {
        return _skeletonShimmeringService
    }

    func authorizationRecoveryService() -> OWAuthorizationRecoveryServicing {
        return _authorizationRecoveryService
    }

    func timeMeasuringService() -> OWTimeMeasuringServicing {
        return _timeMeasuringService
    }

    func sortDictateService() -> OWSortDictateServicing {
        return _sortDictateService
    }
}

// Configure
extension OWSharedServicesProvider: OWSharedServicesProviderConfigure {
    func configureLogger(logLevel level: OWLogLevel, logMethods methods: [OWLogMethod]) {
        _logger = OWLogger(logLevel: level, logMethods: methods)
        _logger.log(level: .verbose, "Logger re-initialized with new configuration")
    }

    func set(spotId: OWSpotId) {
        fetchConfig(spotId: spotId)
    }

    func change(spotId: OWSpotId) {
        fetchConfig(spotId: spotId)

        // Stop / re-create services which depend on spot id
        _realtimeService.stopFetchingData()
        _skeletonShimmeringService.removeAllSkeletons()
        _sortDictateService.invalidateCache()
    }
}

fileprivate extension OWSharedServicesProvider {
    func fetchConfig(spotId: OWSpotId) {
        // TODO: Replace it with new network API - create a dedicated class which do initialization stuff for new spotId
        _ = SPClientSettings.main.setup(spotId: spotId)
            .take(1)
            .do(onNext: { config in
                LocalizationManager.setLocale(config.appConfig.mobileSdk.locale ?? "en")
            })
            .subscribe()
    }
}
