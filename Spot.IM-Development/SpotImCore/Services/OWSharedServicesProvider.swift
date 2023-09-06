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
    func statusBarStyleService() -> OWStatusBarStyleServicing
    func imageCacheService() -> OWCacheService<String, UIImage>
    func commentsInMemoryCacheService() -> OWCacheService<OWCachedCommentKey, String>
    func lastCommentTypeInMemoryCacheService() -> OWCacheService<OWPostId, OWCachedLastCommentType>
    func netwokAPI() -> OWNetworkAPIProtocol
    func logger() -> OWLogger
    func appLifeCycle() -> OWRxAppLifeCycleProtocol
    func keychain() -> OWKeychainProtocol
    func analyticsService() -> OWAnalyticsServicing
    func analyticsEventCreatorService() -> OWAnalyticsEventCreatorServicing
    func userDefaults() -> OWUserDefaultsProtocol
    func realtimeService() -> OWRealtimeServicing
    func spotConfigurationService() -> OWSpotConfigurationServicing
    func skeletonShimmeringService() -> OWSkeletonShimmeringServicing
    func authorizationRecoveryServiceOldAPI() -> OWAuthorizationRecoveryServicingOldAPI
    func authorizationRecoveryService() -> OWAuthorizationRecoveryServicing
    func timeMeasuringService() -> OWTimeMeasuringServicing
    func sortDictateService() -> OWSortDictateServicing
    func authenticationManager() -> OWAuthenticationManagerProtocol
    func blockerServicing() -> OWBlockerServicing
    func commentsService() -> OWCommentsServicing
    func reportedCommentsService() -> OWReportedCommentsServicing
    func usersService() -> OWUsersServicing
    func presenterService() -> OWPresenterServicing
    func commentCreationRequestsService() -> OWCommentCreationRequestsServicing
    func commentUpdaterService() -> OWCommentUpdaterServicing
    func localCommentDataPopulator() -> OWLocalCommentDataPopulating
    func navigationControllerCustomizer() -> OWNavigationControllerCustomizing
    func permissionsService() -> OWPermissionsServicing
    func pageViewIdHolder() -> OWPageViewIdHolderProtocol
}

class OWSharedServicesProvider: OWSharedServicesProviding {

    // Singleton
    static let shared: OWSharedServicesProviding = OWSharedServicesProvider()

    private init() {}

    var configure: OWSharedServicesProviderConfigure { return self }

    fileprivate lazy var _themeStyleService: OWThemeStyleServicing = {
        return OWThemeStyleService()
    }()

    fileprivate lazy var _statusBarStyleService: OWStatusBarStyleServicing = {
        return OWStatusBarStyleService()
    }()

    fileprivate lazy var _imageCacheService: OWCacheService<String, UIImage> = {
        return OWCacheService<String, UIImage>()
    }()

    fileprivate lazy var _commentsInMemoryCacheService: OWCacheService<OWCachedCommentKey, String> = {
        return OWCacheService<OWCachedCommentKey, String>()
    }()

    fileprivate lazy var _lastCommentTypeInMemoryCacheService: OWCacheService<OWPostId, OWCachedLastCommentType> = {
        return OWCacheService<OWPostId, OWCachedLastCommentType>()
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
        let logger = OWLogger(logLevel: OWLogLevel.defaultLevelToUse, logMethods: OWLogMethod.defaultMethodsToUse)
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

    fileprivate lazy var _analyticsEventCreatorService: OWAnalyticsEventCreatorServicing = {
        return OWAnalyticsEventCreatorService(servicesProvider: self)
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

    fileprivate lazy var _authorizationRecoveryServiceOldAPI: OWAuthorizationRecoveryServicingOldAPI = {
        return OWAuthorizationRecoveryServiceOldAPI(servicesProvider: self)
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

    fileprivate lazy var _authenticationManager: OWAuthenticationManagerProtocol = {
        return OWAuthenticationManager(servicesProvider: self)
    }()

    fileprivate lazy var _blockerService: OWBlockerServicing = {
        return OWBlockerService()
    }()

    fileprivate lazy var _commentsService: OWCommentsServicing = {
        return OWCommentsService()
    }()

    fileprivate lazy var _reportedCommentsService: OWReportedCommentsServicing = {
        return OWReportedCommentsService()
    }()

    fileprivate lazy var _usersService: OWUsersServicing = {
        return OWUsersService(servicesProvider: self)
    }()

    fileprivate lazy var _presenterService: OWPresenterServicing = {
        return OWPresenterService()
    }()

    fileprivate lazy var _commentCreationRequestsService: OWCommentCreationRequestsServicing = {
        return OWCommentCreationRequestsService()
    }()

    fileprivate lazy var _commentUpdaterService: OWCommentUpdaterServicing = {
        return OWCommentUpdaterService(servicesProvider: self)
    }()

    fileprivate lazy var _localCommentDataPopulator: OWLocalCommentDataPopulating = {
        return OWLocalCommentDataPopulator()
    }()

    fileprivate lazy var _navigationControllerCustomizer: OWNavigationControllerCustomizing = {
        return OWNavigationControllerCustomizer(servicesProvider: self)
    }()

    fileprivate lazy var _permissionsService: OWPermissionsServicing = {
        return OWPermissionsService(servicesProvider: self)
    }()

    fileprivate lazy var _pageViewIdHolder: OWPageViewIdHolderProtocol = {
        return OWPageViewIdHolder()
    }()

    func themeStyleService() -> OWThemeStyleServicing {
        return _themeStyleService
    }

    func statusBarStyleService() -> OWStatusBarStyleServicing {
        return _statusBarStyleService
    }

    func imageCacheService() -> OWCacheService<String, UIImage> {
        return _imageCacheService
    }

    func commentsInMemoryCacheService() -> OWCacheService<OWCachedCommentKey, String> {
        return _commentsInMemoryCacheService
    }

    func lastCommentTypeInMemoryCacheService() -> OWCacheService<OWPostId, OWCachedLastCommentType> {
        return _lastCommentTypeInMemoryCacheService
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

    func analyticsEventCreatorService() -> OWAnalyticsEventCreatorServicing {
        return _analyticsEventCreatorService
    }

    func skeletonShimmeringService() -> OWSkeletonShimmeringServicing {
        return _skeletonShimmeringService
    }

    func authorizationRecoveryServiceOldAPI() -> OWAuthorizationRecoveryServicingOldAPI {
        return _authorizationRecoveryServiceOldAPI
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

    func authenticationManager() -> OWAuthenticationManagerProtocol {
        return _authenticationManager
    }

    func blockerServicing() -> OWBlockerServicing {
        return _blockerService
    }

    func commentsService() -> OWCommentsServicing {
        return _commentsService
    }

    func reportedCommentsService() -> OWReportedCommentsServicing {
        return _reportedCommentsService
    }

    func usersService() -> OWUsersServicing {
        return _usersService
    }

    func presenterService() -> OWPresenterServicing {
        return _presenterService
    }

    func commentCreationRequestsService() -> OWCommentCreationRequestsServicing {
        return _commentCreationRequestsService
    }

    func commentUpdaterService() -> OWCommentUpdaterServicing {
        return _commentUpdaterService
    }

    func localCommentDataPopulator() -> OWLocalCommentDataPopulating {
        return _localCommentDataPopulator
    }

    func navigationControllerCustomizer() -> OWNavigationControllerCustomizing {
        return _navigationControllerCustomizer
    }

    func permissionsService() -> OWPermissionsServicing {
        return _permissionsService
    }

    func pageViewIdHolder() -> OWPageViewIdHolderProtocol {
        return _pageViewIdHolder
    }
}

// Configure
extension OWSharedServicesProvider: OWSharedServicesProviderConfigure {
    func configureLogger(logLevel level: OWLogLevel, logMethods methods: [OWLogMethod]) {
        _logger = OWLogger(logLevel: level, logMethods: methods)
        _logger.log(level: .verbose, "Logger re-initialized with new configuration")
    }

    func set(spotId: OWSpotId) {
        configure(forSpotId: spotId)
        _authenticationManager.prepare(forSpotId: spotId)
    }

    func change(spotId: OWSpotId) {
        configure(forSpotId: spotId)

        // Stop / re-create services which depend on spot id
        /*
         In order to not cause confusions, once we change in the SampleApp a spotId during the same app session,
         we are clearing any data relevant to the active user.
         This means that if afterwards we re-select the original spotId, we will need to re-login and other user relevant functionality.
        */
        _authenticationManager.change(newSpotId: spotId)
        _realtimeService.stopFetchingData()
        _skeletonShimmeringService.removeAllSkeletons()
        _sortDictateService.invalidateCache()
        _blockerService.invalidateAllBlockers()
        _spotConfigurationService.spotChanged(spotId: spotId)
        _commentsService.cleanCache()
        _usersService.cleanCache()
        _analyticsService.spotChanged(spotId: spotId)
        _reportedCommentsService.cleanCache()
        _imageCacheService.cleanCache()
        _commentsInMemoryCacheService.cleanCache()
        _lastCommentTypeInMemoryCacheService.cleanCache()
    }
}

fileprivate extension OWSharedServicesProvider {
    func configure(forSpotId spotId: OWSpotId) {
        OWLocalizationManager.shared.configure(forSpotId: spotId)
    }
}
