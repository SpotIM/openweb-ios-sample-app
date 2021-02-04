//
//  SpotIm.swift
//  SpotImCore
//
//  Created by Rotem Itzhak on 22/12/2019.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation
import PromiseKit

public enum SpotImError: Error {
    /// SDK was not initilized, please call SpotIm.initialize(spotId: String) with your spotId before calling any other SDK APIs
    case notInitialized
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
    case loggedIn
}

public struct SpotImConversationCounters: Codable {
    let comments: Int
    let replies: Int
}

public struct SpotImArticleMetadata {
    let url: String
    let title: String
    let subtitle: String
    let thumbnailUrl: String

    public init(url: String, title: String, subtitle: String, thumbnailUrl: String) {
        self.url = url
        self.title = title
        self.subtitle = subtitle
        self.thumbnailUrl = thumbnailUrl
    }
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

public class SpotIm {
    private static var configurationPromise: Promise<SpotConfig>?
    private static var userPromise: Promise<SPUser>?
    private static let apiManager: ApiManager = ApiManager()
    internal static let authProvider: SpotImAuthenticationProvider = SpotImAuthenticationProvider(manager: SpotIm.apiManager, internalProvider: SPDefaultInternalAuthProvider(apiManager: SpotIm.apiManager))
    private static let conversationDataProvider: SPConversationsFacade = SPConversationsFacade(apiManager: apiManager)
    private static var spotId: String?
    public static var reinit: Bool = false
    public static var googleAdsProvider: AdsProvider?

    /**
    Initialize the SDK

     You must call this method before calling any other SDK API
     This method should be called from your application AppDelegate

     - Parameter spotId: The SpotId you got from Spot.IM, if you don't have one contact Spot.IM
     */
    public static func initialize(spotId: String) {
        if SpotIm.reinit {
            SpotIm.reinit = false
            SpotIm.spotId = nil
            SPUserSessionHolder.resetUserSession()
            configurationPromise = nil
            userPromise = nil
            LocalizationManager.reset()
        }

        if SpotIm.spotId == nil {
            SpotIm.reinit = false
            SpotIm.spotId = spotId
            getConfigPromise(spotId: spotId).ensure {
                SPClientSettings.main.sendAppInitEvent()
            }.catch { error in
                Logger.verbose("FAILED to initialize the SDK, will try to recover on next API call: \(error)")
            }
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

     - Parameter navigationDelegate: DEPRECATED - please use LoginDelegate instead
     - Parameter completion: A completion handler to receive the response/error of the completeSSO process
     */
    @available(*, deprecated, message: "Use SpotIm.createSpotImFlowCoordinator(loginDelegate: LoginDelegate, completion: @escaping ((SpotImResult<SpotImSDKFlowCoordinator>) -> Void)) instead")
    public static func createSpotImFlowCoordinator(navigationDelegate: SpotImSDKNavigationDelegate, completion: @escaping ((SpotImResult<SpotImSDKFlowCoordinator>) -> Void)) {
        execute(call: { config in
            guard let spotId = spotId else {
                completion(SpotImResult.failure(.internalError("Please call init SDK")))
                return
            }

            let coordinator = SpotImSDKFlowCoordinator(spotConfig: config, delegate: navigationDelegate, spotId: spotId, localeId: config.appConfig.mobileSdk.locale)
            completion(SpotImResult.success(coordinator))
        }) { (error) in
            completion(SpotImResult.failure(error))
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
    public static func getConversationCounters(conversationIds: [String], completion: @escaping ((SpotImResult<[String:SpotImConversationCounters]>) -> Void)) {
        execute(call: { _ in
            conversationDataProvider.commnetsCounters(conversationIds: conversationIds).done { countersData in
                let counters = Dictionary(uniqueKeysWithValues: countersData.map { key, value in
                    (key, SpotImConversationCounters(comments: value.comments, replies: value.replies))
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
    public static var overrideUserInterfaceStyle: SPUserInterfaceStyle?
    
    /**
     Get the currernt user login status

     The login status may be one of 2 options:
     1. Guest - an unauthenticated session
     2. LoggedIn - an authenticated session
     - Parameter completion: A completion handler to receive the current login status of the user
     */
    public static func getUserLoginStatus(completion: @escaping ((SpotImResult<SpotImLoginStatus>) -> Void)) {
        execute(call: { _ in
            if let user = SPUserSessionHolder.session.user {
                completion(.success(user.registered ? .loggedIn : .guest))
            } else {
                completion(.failure(SpotImError.notInitialized))
            }
        }) { (error) in
            completion(.failure(SpotImError.internalError(error.localizedDescription)))
        }
    }

    public static func logout(completion: @escaping ((SpotImResult<Void>) -> Void)) {
        execute(call: { _ in
            firstly {
                authProvider.logout()
            }.done {
                completion(.success)
            }.catch { (error) in
                completion(.failure(SpotImError.internalError(error.localizedDescription)))
            }
        }) { (error) in
            completion(SpotImResult.failure(error))
        }
    }

    // MARK: Private
    private static func execute(call: @escaping (SpotConfig) -> Void, failure: @escaping ((SpotImError) -> Void)) {
        if let spotId = SpotIm.spotId {
            getConfigPromise(spotId: spotId).done { config in
                if let enabled = config.appConfig.mobileSdk.enabled, enabled {
                    getUserPromise().done { user in
                        call(config)
                    }.catch { error in
                        Logger.verbose("FAILED!!!!")
                        if let spotError = error as? SpotImError {
                            failure(spotError)
                        } else {
                            failure(SpotImError.internalError(error.localizedDescription))
                        }
                    }
                } else {
                    Logger.error("SpotIM SDK is disabled for spot id: \(SPClientSettings.main.spotKey ?? "NONE").\nPlease contact SpotIM for more information")
                    failure(SpotImError.configurationSdkDisabled)
                }
            }.catch { error in
                Logger.verbose("FAILED!!!!")
                if let spotError = error as? SpotImError {
                    failure(spotError)
                } else {
                    failure(SpotImError.internalError(error.localizedDescription))
                }
            }
        } else {
            Logger.error("Please call SpotIm.initialize(spotId: String) before calling any SpotIm SDK method")
            failure(SpotImError.notInitialized)
        }
    }

    private static func getConfigPromise(spotId: String) -> Promise<SpotConfig> {
        if let configurationPromise = configurationPromise, !configurationPromise.isRejected {
            return configurationPromise
        }

        let result = SPClientSettings.main.setup(spotId: spotId)
        configurationPromise = result
        return result
    }

    private static func getUserPromise() -> Promise<SPUser> {
        if let userPromise = userPromise, !userPromise.isRejected {
            return userPromise
        }

        
        let result = authProvider.getUser()
        userPromise = result
        return result
    }
}
