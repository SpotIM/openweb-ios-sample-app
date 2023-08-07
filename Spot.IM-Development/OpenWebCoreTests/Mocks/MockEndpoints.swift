//
//  MockEndpoints.swift
//  OpenWebCoreTests
//
//  Created by Philip Kluz on 2023-08-04.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

@testable import SpotImCore

enum MockUserEndpoint: OWEndpoints {
    
    case userData
    
    var method: OWNetworkHTTPMethod {
        switch self {
        case .userData:
            return .get
        }
    }
    
    var path: String {
        switch self {
        case .userData:
            return "/user/data"
        }
    }
    
    var parameters: OWNetworkParameters? {
        switch self {
        case .userData:
            return nil
        }
    }
}
