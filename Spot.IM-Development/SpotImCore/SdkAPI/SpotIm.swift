//
//  SpotIm.swift
//  SpotImCore
//
//  Created by Rotem Itzhak on 22/12/2019.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation
import PromiseKit
import RxSwift

public enum SpotImError: Error {
    /// SDK was not initilized, please call SpotIm.initialize(spotId: String) with your spotId before calling any other SDK APIs
    case notInitialized
    /// SDK is already initialized, set reinit to true if you want to initialize it again
    case alreadyInitialized
    /// SDK is disabled for the provided spotId, please contact Spot.IM to obtain your spotId before trying to use this SDK
    case configurationSdkDisabled
    /// Internal Error in Spot.IM SDK, please contact Spot.IM for more information
    case internalError(String)
}

public enum SpotImResult<T> {
    case success(T)
    case failure(SpotImError)

    public var value: T? {
        switch self {
        case .success(let result): return result
        case .failure: return nil
        }
    }

    public var error: SpotImError? {
        switch self {
        case .success: return nil
        case .failure(let error): return error
        }
    }
}

public enum SpotImLoginStatus {
    case guest
    case ssoLoggedIn(userId: String)
}

public struct SpotImConversationCounters: Codable {
    public let comments: Int
    public let replies: Int
}

public struct SpotImArticleMetadata {
    let url: String
    let title: String
    let subtitle: String
    let thumbnailUrl: String
    let section: String
    var customBIData: [String:String]?
    var readOnlyMode: SpotImReadOnlyMode

    public init(url: String, title: String, subtitle: String, thumbnailUrl: String, section: String = "default", customBIData: [String:String]? = nil, readOnlyMode: SpotImReadOnlyMode = .default) {
        self.url = url
        self.title = title
        self.subtitle = subtitle
        self.thumbnailUrl = thumbnailUrl
        self.section = section
        self.customBIData = customBIData
        self.readOnlyMode = readOnlyMode
    }
    
    public mutating func setCustomBIData(_ data: [String:String]) {
        self.customBIData = data
    }
    
    public mutating func setReadOnlymode(_ mode: SpotImReadOnlyMode) {
        self.readOnlyMode = mode
    }
}

public enum SpotImSortByOption {
    case best
    case newest
    case oldest
}

public enum SpotImButtonOnlyMode {
    case disable
    case withTitle
    case withoutTitle
    
    func isEnabled() -> Bool {
        return self != .disable
    }
}

    
public enum SpotImReadOnlyMode {
    case `default`
    case enable
    case disable
}

public protocol SPAnalyticsEventDelegate {
    func trackEvent(type: SPEventType, event: SPEventInfo)
}

extension SpotImResult where T == Void {
    static var success: SpotImResult {
        return .success(())
    }
}

internal let NUM_OF_RETRIES: UInt = 3

private struct InitResult {
    let config: SpotConfig
    let user: SPUser
}

public typealias InitizlizeCompletionHandler = (_ success: Bool, _ error: SpotImError?) -> Void

public class SpotIm {
    private static var configurationPromise: Promise<SpotConfig>?
    private static let apiManager: OWApiManager = OWApiManager()
    internal static let authProvider: SpotImAuthenticationProvider = SpotImAuthenticationProvider(manager: SpotIm.apiManager, internalProvider: SPDefaultInternalAuthProvider(apiManager: SpotIm.apiManager))
    internal static let profileProvider: SPProfileProvider = SPProfileProvider(apiManager: SpotIm.apiManager)
    private static let conversationDataProvider: SPConversationsFacade = SPConversationsFacade(apiManager: apiManager)
    private static var spotId: String?
    public static var reinit: Bool = false
    public static var googleAdsProvider: AdsProvider?
    
    public static var customFontFamily: String? = nil
    public static var displayArticleHeader: Bool = true

    public static var reactNativeShowLoginScreenOnRootVC: Bool = false

    public static var enableCreateCommentNewDesign: Bool = false
    public static var shouldConversationFooterStartFromBottomAnchor = false
    public static var buttonOnlyMode: SpotImButtonOnlyMode = .disable
    public static var enableCustomNavigationItemTitle: Bool = false
    
    internal static var customSortByOptionText: [SpotImSortByOption:String] = [:]

    
    public static let OVERRIDE_USER_INTERFACE_STYLE_NOTIFICATION: String = "overrideUserInterfaceStyle did change"
    
    internal static var analyticsEventDelegate: SPAnalyticsEventDelegate?
    
    internal static var customInitialSortByOption: SpotImSortByOption? = nil
    
    fileprivate static let servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared
    
    /**
    Initialize the SDK

     You must call this method before calling any other SDK API
     This method should be called from your application AppDelegate

     - Parameter spotId: The SpotId you got from Spot.IM, if you don't have one contact Spot.IM
     - Parameter completion: Initialize success callback
     */
    public static func initialize(spotId: String, completion: InitizlizeCompletionHandler? = nil) {
        if SpotIm.reinit {
            SpotIm.reinit = false
            SpotIm.spotId = nil
            SPUserSessionHolder.resetUserSession()
            configurationPromise = nil
            LocalizationManager.reset()
        }

        if SpotIm.spotId == nil {
            SpotIm.reinit = false
            SpotIm.spotId = spotId
            
            _ = getConfig(spotId: spotId)
                .take(1) // No need to disposed since we take 1
                .subscribe(onNext: { _ in
                    SPClientSettings.main.sendAppInitEvent()
                    completion?(true, nil)
                }, onError: { error in
                    servicesProvider.logger().log(level: .error, "FAILED to initialize the SDK, will try to recover on next API call: \(error.localizedDescription)")
                    completion?(false, SpotImError.internalError(error.localizedDescription))
                })
        } else {
            completion?(false, SpotImError.alreadyInitialized)
        }
    }
    
    public static func setGoogleAdsProvider(googleAdsProvider: AdsProvider) {
        self.googleAdsProvider = googleAdsProvider
    }

    /**
    Authenticate with SpotIm system

     Call this method when a user has finished register/login flow with your own system, or when user is already logged in but not yet authenticated with SpotIm system.
     If you don't have a JWT secret key, please use startSSO method instead

     - Parameter withJwtSecret: The JWT secret key
     - Parameter completion: A completion handler to receive the response/error of the SSO process
     */
    public static func sso(withJwtSecret secret: String, completion: @escaping AuthStratCompleteionHandler) {
        execute(call: { _ in
            authProvider.sso(withJwtSecret: secret, completion: completion)
        }) { (error) in
            completion(nil, error)
        }
    }

    /**
    Authenticate with SpotIm system

     Call this method when a user has finished register/login flow with your own system, or when user is already logged in but not yet authenticated with SpotIm system.
     This method has to be followed by a call to your authentication system with the codeA returned from this call, then a call to completeSSO with the codeB you got from your authentication system

     - Parameter completion: A completion handler to receive the response/error of the startSSO process
     */
    public static func startSSO(completion: @escaping AuthStratCompleteionHandler) {
        execute(call: { _ in
            authProvider.startSSO(completion: completion)
        }) { (error) in
            completion(nil, error)
        }
    }

    /**
    Authenticate with SpotIm system

     Call this method when you want to complete the sso process started with a call to startSSO

     - Parameter with: codeB, you should get this code from your own authintication system.
     - Parameter completion: A completion handler to receive the response/error of the completeSSO process
     */
    public static func completeSSO(with codeB: String, completion: @escaping AuthCompletionHandler) {
        execute(call: { _ in
            authProvider.completeSSO(with: codeB, completion: completion)
        }) { (error) in
            completion(false, error)
        }
    }

    /**
    Factory method to create a SpotImSDKFlowCoordinator objcet

     The SpotImSDKFlowCoordinator is the start point to interact with SpotIm commenting system UI

     - Parameter loginDelegate: A delegate to notify the parent app that a login flow was requested by the user
     - Parameter completion: A completion handler to receive the response/error of the completeSSO process
     */
    public static func createSpotImFlowCoordinator(loginDelegate: SpotImLoginDelegate, completion: @escaping ((SpotImResult<SpotImSDKFlowCoordinator>) -> Void)) {
        execute(call: { config in
            guard let spotId = spotId else {
                completion(SpotImResult.failure(.internalError("Please call init SDK")))
                return
            }
            
            // googleAdsProviderRequired key is optional in appConfig so first we need to check if exists.
            // if googleAdsProviderRequired exists AND "true" AND publisher didn't provide an adsProvider we will fail
            if let googleAdsProviderRequired = config.appConfig.mobileSdk.googleAdsProviderRequired,
               googleAdsProviderRequired && SpotIm.googleAdsProvider == nil {
                completion(SpotImResult.failure(.internalError("Make sure to call setAdsProvider() with an AdsProvider")))
                return
            }

            let coordinator = SpotImSDKFlowCoordinator(spotConfig: config, loginDelegate: loginDelegate, spotId: spotId, localeId: config.appConfig.mobileSdk.locale)
            completion(SpotImResult.success(coordinator))
        }) { (error) in
            completion(SpotImResult.failure(error))
        }
    }

    /**
     Call this method to get the conversation counters (comments, replies) for a [post_id]

     - Parameter conversationIds: The conversations to get counters for
     - Parameter completion: A completion handler to receive the  conversation counter
     */
    public static func getConversationCounters(conversationIds: [String], completion: @escaping ((SpotImResult<[String: SpotImConversationCounters]>) -> Void)) {
        execute(call: { _ in
            let encodedConversationIds = conversationIds.map { ($0 as OWPostId).encoded }
            conversationDataProvider.commnetsCounters(conversationIds: encodedConversationIds).done { countersData in
                let counters = Dictionary<String, SpotImConversationCounters>(uniqueKeysWithValues: countersData.map { key, value in
                    let decodedConversationId = (key as OWPostId).decoded
                    let conversationCounter = SpotImConversationCounters(comments: value.comments, replies: value.replies)
                    return (decodedConversationId, conversationCounter)
                })

                completion(SpotImResult.success(counters))
            }.catch { error in
                completion(SpotImResult.failure(.internalError(error.localizedDescription)))
            }
        }) { error in
            completion(SpotImResult.failure(error))
        }
    }

    /**
    Set your dark theme background color, so Spot.IM components background will match the background of the parent app

     - Parameter color: The parent app backgournd color for dark theme
     */
    public static var darkModeBackgroundColor: UIColor = SPClientSettings.darkModeBackgroundColor {
        didSet {
            SPClientSettings.darkModeBackgroundColor = SpotIm.darkModeBackgroundColor
        }
    }

    /**
    Set your interface style manually instead of using system settings

     - Parameter SPUserInterfaceStyle: The style to set to the conversation SDK
     */
    public static var overrideUserInterfaceStyle: SPUserInterfaceStyle? {
        didSet {
            NotificationCenter.default.post(name: Notification.Name(OVERRIDE_USER_INTERFACE_STYLE_NOTIFICATION), object: nil)
        }
    }
    
    /**
     Get the current user login status

     The login status may be one of 2 options:
     1. guest - an unauthenticated session
     2. ssoLoggedIn - an authenticated session
     - Parameter completion: A completion handler to receive the current login status of the user
     */
    public static func getUserLoginStatus(completion: @escaping ((SpotImResult<SpotImLoginStatus>) -> Void)) {
        execute(call: { _ in
            guard let user = SPUserSessionHolder.session.user else {
                completion(.failure(SpotImError.notInitialized))
                return
            }
            let loginStatus: SpotImLoginStatus
            if user.registered, let userId = user.id {
                loginStatus = .ssoLoggedIn(userId: userId)
            } else {
                loginStatus = .guest
            }
            completion(.success(loginStatus))

        }) { (error) in
            completion(.failure(SpotImError.internalError(error.localizedDescription)))
        }
    }
    
    public static func logout(completion: @escaping ((SpotImResult<Void>) -> Void)) {
        execute(call: { _ in
            _ = authProvider.logout()
                .take(1) // No need to disposed since we take 1
                .subscribe(onNext: { _ in
                    completion(.success)
                }, onError: { error in
                    completion(.failure(SpotImError.internalError(error.localizedDescription)))
                })
        }) { (error) in
            completion(SpotImResult.failure(error))
        }
    }
    
    public static func setCustomSortByOptionText(option: SpotImSortByOption, text: String) {
        customSortByOptionText[option] = text
    }
    
    /**
     Set SPAnalyticsEventDelegate for tracking analytics events

     - Parameter delegate: A delegate to notify the parent app that an analytics event sent
     */
    public static func setAnalyticsEventDelegate(delegate: SPAnalyticsEventDelegate) {
        self.analyticsEventDelegate = delegate
    }
    
    /**
        Set SpotImButtonOnlyMode for pre-conversation button-only mode

     - Parameter mode: SpotImButtonOnlyMode (to disable/enable/no title)
     */
    public static func setButtonOnlyMode(mode: SpotImButtonOnlyMode) {
        self.buttonOnlyMode = mode
    }
    
    public static func getButtonOnlyMode() -> SpotImButtonOnlyMode {
        return self.buttonOnlyMode
    }
    
    /**
        Set initial conversation sort option

     - Parameter option: SpotImSortByOption
     */
    public static func setInitialSort(option: SpotImSortByOption) {
        self.customInitialSortByOption = option
    }
    
    /**
        Configure OpenWeb SDK logger

     - Parameter logLevel: SPLogLevel - the level which will be logged out
     - Parameter logMethods: [SPLogMethod] - the methods in which we will log
     */
    public static func configureLogger(logLevel: SPLogLevel, logMethods: [SPLogMethod]) {
        self.servicesProvider.configure.configureLogger(logLevel: logLevel.toOWPrefix,
                                                        logMethods: logMethods.map {$0.toOWPrefix })
    }

    // MARK: Private
    private static func execute(call: @escaping (SpotConfig) -> Void, failure: @escaping ((SpotImError) -> Void)) {
        if let spotId = SpotIm.spotId {
            _ = getConfig(spotId: spotId) // Load config
                .catch { error in
                    servicesProvider.logger().log(level: .error, "FAILED to load config: \(error.localizedDescription)")
                    if let spotError = error as? SpotImError {
                        failure(spotError)
                    } else {
                        failure(SpotImError.internalError(error.localizedDescription))
                    }
                    return .empty() // Actually stop here
                }
                .take(1) // No need to disposed since we take 1
                .flatMapLatest { config in
                    return getUser() // Load user
                        .catch { error in
                            servicesProvider.logger().log(level: .error, "FAILED to load user: \(error.localizedDescription)")
                            if let spotError = error as? SpotImError {
                                failure(spotError)
                            } else {
                                failure(SpotImError.internalError(error.localizedDescription))
                            }
                            return .empty() // Actually stop here
                        }
                        .map { _ in
                            return config
                        }
                }
                .take(1) // No need to disposed since we take 1
                .subscribe(onNext: { config in
                    call(config)
                })
        } else {
            servicesProvider.logger().log(level: .error, "Please call SpotIm.initialize(spotId: String) before calling any SpotIm SDK method")
            failure(SpotImError.notInitialized)
        }
    }

    private static func getConfig(spotId: String) -> Observable<SpotConfig> {
        return Observable.create { observer in
            let configuration: Promise<SpotConfig>
            if let configurationPromise = self.configurationPromise, !configurationPromise.isRejected {
                configuration = configurationPromise
            } else {
                let result = SPClientSettings.main.setup(spotId: spotId)
                self.configurationPromise = result
                configuration = self.configurationPromise!
            }

            configuration.done { config in
                observer.onNext(config)
                observer.onCompleted()
            }.catch { error in
                return observer.onError(error)
            }
            
            return Disposables.create()
        }
    }

    private static func getUser() -> Observable<SPUser> {
        // Since the way to know the user expired is by code 403 for that request, we should never cache the user.
        // We will able to do so only after some expiration field will be added
        return authProvider.getUser()
    }
}
