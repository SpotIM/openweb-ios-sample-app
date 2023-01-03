//
//  OWNetworkStatusCode.swift
//  SpotImCore
//
//  Created by Alon Haiut on 21/12/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

struct OWNetworkStatusCode {
    static let authorizationErrorCode = 403
    static let acceptableStatusCodes: Range<Int> = 200..<300
    static let emptyResponseSucceededStatusCodes = [204, 205]
}
