//
//  OWEndpoint.swift
//  SpotImCore
//
//  Created by Alon Haiut on 19/04/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import Alamofire

/*
 OWEndpoint - protocol which represent the necessary stuff related to an endpoint
 All endpoints will conform to it
 */
protocol OWEndpoints {
    var method: HTTPMethod { get }
    var path: String { get }
    var parameters: Parameters? { get }
    var overrideBaseURL: URL? { get }
}

extension OWEndpoints {
    var overrideBaseURL: URL? {
        return nil
    }
}
