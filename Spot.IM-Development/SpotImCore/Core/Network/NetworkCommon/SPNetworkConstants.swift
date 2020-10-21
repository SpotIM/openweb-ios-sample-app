//
//  SPNetworkConstants.swift
//  Spot.IM-Core
//
//  Created by Andriy Fedin on 18/06/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation
import Alamofire

internal struct APIConstants {
    static internal let baseURLString: String = "https://mobile-gw.spot.im" // TODO: (Fedin) should be set by publisher
    static internal let termsURLString: String = "https://www.spot.im/terms"
    static internal let privacyURLString: String = "https://www.spot.im/privacy"
    static internal let joinURLString: String = "https://www.spot.im/"
    static internal let encoding = JSONEncoding.default
}

internal struct APIParamKeysContants {
    static internal let CODE_B = "code_b"
    static internal let SPOT_ID = "spot_id"
    static internal let SECRET = "secret"
}

internal struct APIHeadersConstants {
    static internal let AUTHORIZATION = "Authorization"
}
