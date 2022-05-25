//
//  OWHTTPHeaderRequestMiddleware.swift
//  SpotImCore
//
//  Created by Alon Haiut on 19/04/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import Alamofire

struct OWHTTPHeaderName {
    static let contentType = "Content-Type"
    static let userAgent = "User-Agent"
    static let authorization = "Authorization"
    static let spotId = "x-spot-id"
    static let postId = "x-post-id"
    static let platform = "x-platform"
    static let platformVersion = "x-platform-version"
    static let moblieGWVersion = "x-moblie-gw-version"
    static let sdkVersion = "x-sdk-version"
    static let appVersion = "x-app-version"
    static let appScheme = "x-app-scheme"
    static let pageViewId = "x-spotim-page-view-id"
    static let openWebToken = "x-openweb-token"
    static let guid = "x-guid"
}

struct OWHTTPHeaderContent {
    static let json = "application/json"
}

class OWHTTPHeaderRequestMiddleware: OWRequestMiddleware {
    func process(request: URLRequest) -> URLRequest {
        
        // TODO: Complete the headers
        let headers: HTTPHeaders = [OWHTTPHeaderName.contentType: OWHTTPHeaderContent.json]
        
        var newRequest = request
        
        headers.dictionary.forEach { header, content in
            newRequest.setValue(content, forHTTPHeaderField: header)
        }
        
        return newRequest
    }
}
