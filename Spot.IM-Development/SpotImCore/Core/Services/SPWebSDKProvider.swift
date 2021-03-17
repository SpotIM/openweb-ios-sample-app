//
//  SPWebSDKProvider.swift
//  SpotImCore
//
//  Created by Alon Shprung on 16/03/2021.
//  Copyright © 2021 Spot.IM. All rights reserved.
//

import Foundation

internal protocol SPWebSDKDelegate: class {
    func openWebSDKPage(with urlString: String)
}

internal final class SPWebSDKProvider {
    
    enum WebModule: String {
        case profile = "user-profile"
        case communityGuidelines = "community-guidelines"
    }
    
    internal static func openWebModule(delegate: SPWebSDKDelegate?, params: Params) {
        if let urlString = getUrlString(params: params) {
            delegate?.openWebSDKPage(with: urlString)
        }
    }
    
    private static func getUrlString(params: Params) -> String? {
        let baseUrl = URL(string: "https://sdk.openweb.com/index.html")
        guard var url = baseUrl else { return nil }
        url.appendQueryParam(name: "module_name", value: params.module.rawValue)
        url.appendQueryParam(name: "spot_id", value: params.spotId)
        url.appendQueryParam(name: "post_id", value: params.postId)
        if let userId = params.userId {
            url.appendQueryParam(name: "user_id", value: userId)
        }
        if let userAccessToken = params.userAccessToken {
            url.appendQueryParam(name: "user_access_token", value: getCleanToken(token: userAccessToken))
        }
        if let userOwToken = params.userOwToken {
            url.appendQueryParam(name: "user_ow_token", value: userOwToken)
        }
        return url.absoluteString
    }
    
    private static func getCleanToken(token: String) -> String {
        return token.replacingOccurrences(of: "Bearer ", with: "")
    }
}

extension SPWebSDKProvider {
    internal class Params {
        var module: WebModule
        var spotId: String
        var postId: String = "default"
        var userId: String?
        var userAccessToken: String?
        var userOwToken: String?
        
        init(module: WebModule, spotId: String, postId: String) {
            self.module = module
            self.spotId = spotId
            self.postId = postId
        }
        
        convenience init(module: WebModule, spotId: String, postId: String, userId: String, userAccessToken: String? = nil, userOwToken: String? = nil) {
            self.init(module: module, spotId: spotId, postId: postId)
            self.userId = userId
            self.userAccessToken = userAccessToken
            self.userOwToken = userOwToken
        }
    }
}
