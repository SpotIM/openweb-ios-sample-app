//
//  OWMiddleware.swift
//  SpotImCore
//
//  Created by Alon Haiut on 19/04/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

/*
 Middleware usages is to perform data manipulation and other utility stuff on requests and responses
 */
protocol OWMiddleware {}

protocol OWRequestMiddleware: OWMiddleware {
    func process(request: URLRequest) -> URLRequest
}

protocol OWResponseMiddleware: OWMiddleware {
    func process<T: Any>(response: DataResponse<T, AFError>) -> DataResponse<T, AFError>
}
