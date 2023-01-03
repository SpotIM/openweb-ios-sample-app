//
//  SPNetworkConstants.swift
//  Spot.IM-Core
//
//  Created by Andriy Fedin on 18/06/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation

struct APIConstants {
    static let baseURLString: String = "https://mobile-gw.spot.im"
    static let uploadImageBaseURL: String = SPConfigsDataSource.appConfig?.mobileSdk.imageUploadBaseUrl ?? "https://api.cloudinary.com/v1_1/com-3pix/image/upload/"
    static let fetchImageBaseURL: String = SPConfigsDataSource.appConfig?.mobileSdk.fetchImageBaseUrl ?? "https://images.spot.im/image/upload/"
    static let cdnBaseURL: String = "https://static-cdn.spot.im/production/"
    static let encoding = OWNetworkJSONEncoding.default
}

struct APIParamKeysContants {
    static let CODE_B = "code_b"
    static let SPOT_ID = "spot_id"
    static let SECRET = "secret"
}

struct APIHeadersConstants {
    static let authorization = "Authorization"
    static let openwebTokenHeader = "x-openweb-token"
    static let guid = "x-guid"
}
