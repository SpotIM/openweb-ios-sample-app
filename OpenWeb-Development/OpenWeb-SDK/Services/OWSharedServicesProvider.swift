//
//  OWSharedServicesProvider.swift
//  OpenWebSDK
//
//  Created by Alon Haiut on 07/03/2022.
//  Copyright © 2022 OpenWeb. All rights reserved.
//

import Foundation
import UIKit

protocol OWSharedServicesProviderConfigure {
    func configureLogger(logLevel: OWLogLevel, logMethods: [OWLogMethod])
    func set(spotId: OWSpotId)
    // If spotId re-set, this function should be called to re-prepare all the services which require a spotId
    func change(spotId: OWSpotId)
    func resetNetworkEnvironment()
}

protocol OWSharedServicesProviding: AnyObject {
    var configure: OWSharedServicesProviderConfigure { get }
    func profileService() -> OWProfileServicing
    func themeStyleService() -> OWThemeStyleServicing
    func orientationService() -> OWOrientationServicing
    func statusBarStyleService() -> OWStatusBarStyleServicing
    func imageCacheService() -> OWCacheService<String, UIImage>
    func commentsInMemoryCacheService() -> OWCacheService<OWCachedCommentKey, OWCommentCreationCtaData>
    func lastCommentTypeInMemoryCacheService() -> OWCacheService<OWPostId, OWCachedLastCommentType>
    func networkAPI() -> OWNetworkAPIProtocol
    func logger() -> OWLogger
    func appLifeCycle() -> OWRxAppLifeCycleProtocol
    func keychain() -> OWKeychainProtocol
    func analyticsService() -> OWAnalyticsServicing
    func analyticsEventCreatorService() -> OWAnalyticsEventCreatorServicing
    func userDefaults() -> OWUserDefaultsProtocol
    func realtimeService() -> OWRealtimeServicing
    func spotConfigurationService() -> OWSpotConfigurationServicing
    func skeletonShimmeringService() -> OWSkeletonShimmeringServicing
    func authorizationRecoveryService() -> OWAuthorizationRecoveryServicing
    func timeMeasuringService() -> OWTimeMeasuringServicing
    func sortDictateService() -> OWSortDictateServicing
    func filterTabsDictateService() -> OWFilterTabsDictateServicing
    func authenticationManager() -> OWAuthenticationManagerProtocol
    func blockerServicing() -> OWBlockerServicing
    func commentsService() -> OWCommentsServicing
    func reportedCommentsService() -> OWReportedCommentsServicing
    func usersService() -> OWUsersServicing
    func presenterService() -> OWPresenterServicing
    func commentCreationRequestsService() -> OWCommentCreationRequestsServicing
    func activeArticleService() -> OWActiveArticleServicing
    func conversationUpdaterService() -> OWConversationUpdaterServicing
    func localCommentDataPopulator() -> OWLocalCommentDataPopulating
    func navigationControllerCustomizer() -> OWNavigationControllerCustomizing
    func realtimeIndicatorService() -> OWRealtimeIndicatorServicing
    func permissionsService() -> OWPermissionsServicing
    func pageViewIdHolder() -> OWPageViewIdHolderProtocol
    func toastNotificationService() -> OWToastNotificationServicing
    func commentStatusUpdaterService() -> OWCommentStatusUpdaterServicing
    func actionsCallbacksNotifier() -> OWActionsCallbacksNotifierServicing
    func networkAvailabilityService() -> OWNetworkAvailabilityServicing
    func conversationSizeService() -> OWConversationSizeServicing
    func gifService() -> OWGifServicing
    func viewableTimeService() -> OWViewableTimeServicing
}

class OWSharedServicesProvider: OWSharedServicesProviding {

    // Singleton
    static let shared: OWSharedServicesProviding = OWSharedServicesProvider()

    private init() {}

    var configure: OWSharedServicesProviderConfigure { return self }

    private lazy var _profileService: OWProfileServicing = {
        return OWProfileService(sharedServicesProvider: self)
    }()

    private lazy var _themeStyleService: OWThemeStyleServicing = {
        return OWThemeStyleService()
    }()

    private lazy var _orientationService: OWOrientationService = {
        return OWOrientationService()
    }()

    private lazy var _conversationSizeService: OWConversationSizeServicing = {
        return OWConversationSizeService()
    }()

    private lazy var _gifService: OWGifServicing = {
        return OWGifService(sharedServicesProvider: self)
    }()

    private lazy var _statusBarStyleService: OWStatusBarStyleServicing = {
        return OWStatusBarStyleService()
    }()

    private lazy var _imageCacheService: OWCacheService<String, UIImage> = {
        return OWCacheService<String, UIImage>()
    }()

    private lazy var _commentsInMemoryCacheService: OWCacheService<OWCachedCommentKey, OWCommentCreationCtaData> = {
        return OWCacheService<OWCachedCommentKey, OWCommentCreationCtaData>()
    }()

    private lazy var _lastCommentTypeInMemoryCacheService: OWCacheService<OWPostId, OWCachedLastCommentType> = {
        return OWCacheService<OWPostId, OWCachedLastCommentType>()
    }()

    private lazy var _viewableTimeService: OWViewableTimeServicing = {
        return OWViewableTimeService()
    }()

    private lazy var _networkAPI: OWNetworkAPIProtocol = {
        /*
         By default we create the network once.
         If we will want to "reset" everything when a new spotIfy provided, we can re-create the network entirely.
         Note that the environment is being set in the `OWEnvironment` class which we can set in an earlier step by some
         environment variable / flag in Xcode scheme configuration.
         */
        return OWNetworkAPI(environment: OWEnvironment.currentEnvironment)
    }()

    private lazy var _logger: OWLogger = {
        let logger = OWLogger(logLevel: OWLogLevel.defaultLevelToUse, logMethods: OWLogMethod.defaultMethodsToUse)
        logger.log(level: .verbose, "Logger initialized")
        return logger
    }()

    private lazy var _appLifeCycle: OWRxAppLifeCycleProtocol = {
        return OWRxAppLifeCycle()
    }()

    private lazy var _keychain: OWKeychainProtocol = {
        return OWKeychain(servicesProvider: self)
    }()

    private lazy var _analyticsService: OWAnalyticsServicing = {
        return OWAnalyticsService()
    }()

    private lazy var _analyticsEventCreatorService: OWAnalyticsEventCreatorServicing = {
        return OWAnalyticsEventCreatorService(servicesProvider: self)
    }()

    private lazy var _userDefaults: OWUserDefaultsProtocol = {
        return OWUserDefaults(servicesProvider: self)
    }()

    private lazy var _realtimeService: OWRealtimeServicing = {
        return OWRealtimeService(servicesProvider: self)
    }()

    private lazy var _spotConfigurationService: OWSpotConfigurationServicing = {
        return OWSpotConfigurationService(servicesProvider: self)
    }()

    private lazy var _skeletonShimmeringService: OWSkeletonShimmeringServicing = {
        return OWSkeletonShimmeringService(config: OWSkeletonShimmeringConfiguration.default)
    }()

    private lazy var _authorizationRecoveryService: OWAuthorizationRecoveryServicing = {
        return OWAuthorizationRecoveryService(servicesProvider: self)
    }()

    private lazy var _timeMeasuringService: OWTimeMeasuringServicing = {
        return OWTimeMeasuringService()
    }()

    private lazy var _sortDictateService: OWSortDictateServicing = {
        return OWSortDictateService(servicesProvider: self)
    }()

    private lazy var _filterTabsDictateService: OWFilterTabsDictateServicing = {
        return OWFilterTabsDictateService(servicesProvider: self)
    }()

    private lazy var _authenticationManager: OWAuthenticationManagerProtocol = {
        return OWAuthenticationManager(servicesProvider: self)
    }()

    private lazy var _blockerService: OWBlockerServicing = {
        return OWBlockerService()
    }()

    private lazy var _commentsService: OWCommentsServicing = {
        return OWCommentsService()
    }()

    private lazy var _reportedCommentsService: OWReportedCommentsServicing = {
        return OWReportedCommentsService()
    }()

    private lazy var _usersService: OWUsersServicing = {
        return OWUsersService(servicesProvider: self)
    }()

    private lazy var _presenterService: OWPresenterServicing = {
        return OWPresenterService(sharedServicesProvider: self)
    }()

    private lazy var _commentCreationRequestsService: OWCommentCreationRequestsServicing = {
        return OWCommentCreationRequestsService()
    }()

    private lazy var _activeArticleService: OWActiveArticleServicing = {
        return OWActiveArticleService(servicesProvider: self)
    }()

    private lazy var _conversationUpdaterService: OWConversationUpdaterServicing = {
        return OWConversationUpdaterService(servicesProvider: self)
    }()

    private lazy var _localCommentDataPopulator: OWLocalCommentDataPopulating = {
        return OWLocalCommentDataPopulator()
    }()

    private lazy var _navigationControllerCustomizer: OWNavigationControllerCustomizing = {
        return OWNavigationControllerCustomizer(servicesProvider: self)
    }()

    private lazy var _realtimeIndicatorServicre: OWRealtimeIndicatorServicing = {
        return OWRealtimeIndicatorService(servicesProvider: self)
    }()

    private lazy var _permissionsService: OWPermissionsServicing = {
        return OWPermissionsService(servicesProvider: self)
    }()

    private lazy var _pageViewIdHolder: OWPageViewIdHolderProtocol = {
        return OWPageViewIdHolder()
    }()

    private lazy var _toastNotificationService: OWToastNotificationServicing = {
        return OWToastNotificationService(servicesProvider: self)
    }()

    private lazy var _commentStatusUpdaterService: OWCommentStatusUpdaterServicing = {
        return OWCommentStatusUpdaterService(servicesProvider: self)
    }()

    private lazy var _networkAvailabilityService: OWNetworkAvailabilityServicing = {
        return OWNetworkAvailabilityService.shared
    }()

    private lazy var _actionsCallbacksNotifier: OWActionsCallbacksNotifierServicing = {
        return OWActionsCallbacksNotifierService()
    }()

    func profileService() -> OWProfileServicing {
        return _profileService
    }

    func themeStyleService() -> OWThemeStyleServicing {
        return _themeStyleService
    }

    func orientationService() -> OWOrientationServicing {
        return _orientationService
    }

    func statusBarStyleService() -> OWStatusBarStyleServicing {
        return _statusBarStyleService
    }

    func imageCacheService() -> OWCacheService<String, UIImage> {
        return _imageCacheService
    }

    func commentsInMemoryCacheService() -> OWCacheService<OWCachedCommentKey, OWCommentCreationCtaData> {
        return _commentsInMemoryCacheService
    }

    func lastCommentTypeInMemoryCacheService() -> OWCacheService<OWPostId, OWCachedLastCommentType> {
        return _lastCommentTypeInMemoryCacheService
    }

    func networkAPI() -> OWNetworkAPIProtocol {
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

    func authorizationRecoveryService() -> OWAuthorizationRecoveryServicing {
        return _authorizationRecoveryService
    }

    func timeMeasuringService() -> OWTimeMeasuringServicing {
        return _timeMeasuringService
    }

    func sortDictateService() -> OWSortDictateServicing {
        return _sortDictateService
    }

    func filterTabsDictateService() -> OWFilterTabsDictateServicing {
        return _filterTabsDictateService
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

    func activeArticleService() -> OWActiveArticleServicing {
        return _activeArticleService
    }

    func conversationUpdaterService() -> OWConversationUpdaterServicing {
        return _conversationUpdaterService
    }

    func localCommentDataPopulator() -> OWLocalCommentDataPopulating {
        return _localCommentDataPopulator
    }

    func navigationControllerCustomizer() -> OWNavigationControllerCustomizing {
        return _navigationControllerCustomizer
    }

    func realtimeIndicatorService() -> OWRealtimeIndicatorServicing {
        return _realtimeIndicatorServicre
    }

    func permissionsService() -> OWPermissionsServicing {
        return _permissionsService
    }

    func commentStatusUpdaterService() -> OWCommentStatusUpdaterServicing {
        return _commentStatusUpdaterService
    }

    func networkAvailabilityService() -> OWNetworkAvailabilityServicing {
        return _networkAvailabilityService
    }

    func pageViewIdHolder() -> OWPageViewIdHolderProtocol {
        return _pageViewIdHolder
    }

    func toastNotificationService() -> OWToastNotificationServicing {
        return _toastNotificationService
    }

    func actionsCallbacksNotifier() -> OWActionsCallbacksNotifierServicing {
        _actionsCallbacksNotifier
    }

    func conversationSizeService() -> OWConversationSizeServicing {
        return _conversationSizeService
    }

    func gifService() -> OWGifServicing {
        return _gifService
    }

    func viewableTimeService() -> OWViewableTimeServicing {
        return _viewableTimeService
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
        _commentStatusUpdaterService.spotChanged(newSpotId: spotId)
        _viewableTimeService.inputs.clearAllTracking()
    }

    func resetNetworkEnvironment() {
        _networkAPI = OWNetworkAPI(environment: OWEnvironment.currentEnvironment)
    }
}

private extension OWSharedServicesProvider {
    func configure(forSpotId spotId: OWSpotId) {
        OWLocalizationManager.shared.configure(forSpotId: spotId)
    }
}
