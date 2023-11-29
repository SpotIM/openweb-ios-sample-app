//
//  OWEndpoint.swift
//  SpotImCore
//
//  Created by Alon Haiut on 19/04/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

/*
 OWEndpoint - protocol which represent the necessary stuff related to an endpoint
 All endpoints will conform to it
 */
protocol OWEndpoints {
    var method: OWNetworkHTTPMethod { get }
    var path: String { get }
    var parameters: OWNetworkParameters? { get }
    var queryParams: [Foundation.URLQueryItem]? { get }
    var overrideBaseURL: URL? { get }
    var additionalMiddlewares: [OWRequestMiddleware]? { get }
}

extension OWEndpoints {
    var overrideBaseURL: URL? {
        return nil
    }

    var additionalMiddlewares: [OWRequestMiddleware]? {
        return nil
    }

    var queryParams: [Foundation.URLQueryItem]? {
        return nil
    }
}
