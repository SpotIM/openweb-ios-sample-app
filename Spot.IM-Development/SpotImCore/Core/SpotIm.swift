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

extension SpotImResult where T == Void {
    static var success: SpotImResult {
        return .success(())
    }
}

public class SpotIm {
    private static var configurationPromise: Promise<Void>?
    private static var getUserPromise: Promise<SPUser>?
    private static let apiManager: ApiManager = ApiManager()
    internal static let authProvider: SpotImAuthenticationProvider = SpotImAuthenticationProvider(manager: SpotIm.apiManager, internalProvider: SPDefaultInternalAuthProvider(apiManager: SpotIm.apiManager))
    internal static var currentUser: SPUser?

    /**
    Initialize the SDK

     You must call this method before calling any other SDK API
     This method should be called from your application AppDelegate

     - Parameter spotId: The SpotId you got from Spot.IM, if you don't have one contact Spot.IM
     */
    public static func initialize(spotId: String) {
        configurationPromise = SPClientSettings.main.setup(spotId: spotId)
        getUserPromise = authProvider.getUser()
    }

    /**
    Authenticate with SpotIm system

     Call this method when a user has finished register/login flow with your own system, or when user is already logged in but not yet authenticated with SpotIm system.
     If you don't have a JWT secret key, please use startSSO method instead

     - Parameter withJwtSecret: The JWT secret key
     - Parameter completion: A completion handler to receive the response/error of the SSO process
     */
    public static func sso(withJwtSecret secret: String, completion: @escaping AuthStratCompleteionHandler) {
        execute(call: {
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
        execute(call: {
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
        execute(call: {
            authProvider.completeSSO(with: codeB, completion: completion)
        }) { (error) in
            completion(false, error)
        }
    }

    /**
    Factory method to create a SpotImSDKFlowCoordinator objcet

     The SpotImSDKFlowCoordinator is the start point to interact with SpotIm commenting system UI

     - Parameter completion: A completion handler to receive the response/error of the completeSSO process
     */
    public static func createSpotImFlowCoordinator(navigationDelegate: SpotImSDKNavigationDelegate, completion: @escaping ((SpotImResult<SpotImSDKFlowCoordinator>) -> Void)) {
        execute(call: {
            let coordinator = SpotImSDKFlowCoordinator(delegate: navigationDelegate)
            completion(SpotImResult.success(coordinator))
        }) { (error) in
            completion(SpotImResult.failure(error))
        }
    }
    
    /**
    Set your dark theme background color, so Spot.IM components background will match the background of the parent app
     
     - Parameter color: The parent app backgournd color for dark theme
     */
    public static var darkModeBackgroundColor: UIColor = SpotIm.darkModeBackgroundColor {
        didSet {
            SPClientSettings.darkModeBackgroundColor = SpotIm.darkModeBackgroundColor
        }
    }

    /**
     Get the currernt user login status
     
     The login status may be one of 2 options:
     1. Guest - an unauthenticated session
     2. LoggedIn - an authenticated session
     - Parameter completion: A completion handler to receive the current login status of the user
     */
    public static func getUserLoginStatus(completion: @escaping ((SpotImResult<SpotImLoginStatus>) -> Void)) {
        execute(call: {
            if let user = currentUser {
                completion(.success(user.registered ? SpotImLoginStatus.loggedIn : SpotImLoginStatus.guest))
            } else {
                authProvider.getUser().done { user in
                    currentUser = user
                    completion(.success(user.registered ? SpotImLoginStatus.loggedIn : SpotImLoginStatus.guest))
                }.catch { error in
                    completion(.failure(SpotImError.internalError(error.localizedDescription)))
                }
            }
        }) { (error) in
            completion(.failure(SpotImError.internalError(error.localizedDescription)))
        }
    }
    
    public static func logout(completion: @escaping ((SpotImResult<Void>) -> Void)) {
        execute(call: {
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
    private static func execute(call: @escaping () -> Void, failure: @escaping ((SpotImError) -> Void)) {
        if let configurationPromise = configurationPromise, let userPromise = getUserPromise {
            firstly {
                configurationPromise
            }.then {
                userPromise
            }.done { user in
                if let enabled = SPConfigsDataSource.appConfig?.mobileSdk?.enabled, enabled {
                    call()
                } else {
                    Logger.error("SpotIM SDK is disabled for spot id: \(SPClientSettings.main.spotKey ?? "NONE").\nPlease contact SpotIM for more information")
                    failure(SpotImError.configurationSdkDisabled)
                }
            }.catch { error in
                Logger.error("SpotIM SDK failed to load the configuration for spot id: \(SPClientSettings.main.spotKey ?? "NONE"), with error: \(error)")
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
}
