//
//  SPNetworkError.swift
//  Spot.IM-Core
//
//  Created by Andriy Fedin on 20/06/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation

enum SPNetworkErrorCode: Int {

    case custom = 10000
    case `default` = 10001
    case emptyResponse = 10002
    case noInternet = 10003
    case requestFailed = 10004
    case missingStatusCode = 10005

}

public enum SPNetworkError: Error {

    case custom(_ description: String)
    case `default`
    case emptyResponse
    case noInternet
    case requestFailed
    case missingStatusCode

}

extension SPNetworkError: LocalizedError {

    public var errorDescription: String? {
        switch self {
        case .default:
            return LocalizationManager.localizedString(key: "It seems we are experiencing technical issues. Please try again")

        case .emptyResponse:
            return LocalizationManager.localizedString(key: "Empty response")

        case .custom(let description):
            return description

        case .noInternet:
            return LocalizationManager.localizedString(key: "The Internet connection appears to be offline.")

        case .requestFailed:
            return LocalizationManager.localizedString(key: "Load conversation request failed")

        case .missingStatusCode:
            return LocalizationManager.localizedString(key: "Missing status code")
        }
    }
}

extension SPNetworkError: CustomNSError {

    public static var errorDomain: String {
        return "SPNetworkErrorDomain"
    }

    public var errorCode: Int {
        switch self {

        case .custom:
            return SPNetworkErrorCode.custom.rawValue

        case .default:
            return SPNetworkErrorCode.default.rawValue

        case .emptyResponse:
            return SPNetworkErrorCode.emptyResponse.rawValue

        case .noInternet:
            return SPNetworkErrorCode.noInternet.rawValue

        case .requestFailed:
            return SPNetworkErrorCode.requestFailed.rawValue

        case .missingStatusCode:
            return SPNetworkErrorCode.missingStatusCode.rawValue
        }
    }
}

extension Error {

    func spError() -> SPNetworkError {
        if let spError = self as? SPNetworkError {
            return spError
        }

        let nsError = self as NSError

        switch nsError.code {
        case -1009:
            return SPNetworkError.noInternet
        default:
            return SPNetworkError.default
        }
    }
}
