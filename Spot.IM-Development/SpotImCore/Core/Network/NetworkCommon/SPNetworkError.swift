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
    
}

enum SPNetworkError: Error {
    
    case custom(_ description: String)
    case `default`
    case emptyResponse
    case noInternet
    
}

extension SPNetworkError: LocalizedError {
    
    var errorDescription: String? {
        switch self {
        case .default:
            return NSLocalizedString("It seems we are experiencing technical issues. Please try again",
                                     comment: "default error")
            
        case .emptyResponse:
            return NSLocalizedString("Empty response",
                                     comment: "Unknown networking error")
            
        case .custom(let description):
            return description
            
        case .noInternet:
            return NSLocalizedString("The Internet connection appears to be offline.",
                                     comment: "No internet")
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
