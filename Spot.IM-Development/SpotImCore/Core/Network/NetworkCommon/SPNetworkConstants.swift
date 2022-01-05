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
    static internal let baseURLString: String = "https://mobile-gw.spot.im"
    static internal let uploadImageBaseURL: String = SPConfigsDataSource.appConfig?.mobileSdk.imageUploadBaseUrl ?? "https://api.cloudinary.com/v1_1/com-3pix/image/upload"
    static internal let fetchImageBaseURL: String = SPConfigsDataSource.appConfig?.mobileSdk.fetchImageBaseUrl ?? "https://images.spot.im/image/upload"
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
