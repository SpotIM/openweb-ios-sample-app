//
//  SPWebSDKProvider.swift
//  SpotImCore
//
//  Created by Alon Shprung on 16/03/2021.
//  Copyright © 2021 Spot.IM. All rights reserved.
//

import Foundation

internal final class SPWebSDKProvider {
    
    enum WebModule: String {
        case profile = "user-profile"
    }
    
    internal static func openWebModule(delegate: SPSafariWebPageDelegate?, params: Params) {
        
        SpotIm.profileProvider.getSingleUseToken().done { singleUseToken in
            params.singleUseTicket = singleUseToken
        }
        .ensure {
            if let urlString = getUrlString(params: params) {
                delegate?.openWebPage(with: urlString)
            }
        }
    }
    
    private static func getUrlString(params: Params) -> String? {
        let baseUrl = URL(string: "https://sdk.openweb.com/index.html")
        guard var url = baseUrl else { return nil }
        url.appendQueryParam(name: "module_name", value: params.module.rawValue)
        url.appendQueryParam(name: "spot_id", value: params.spotId)
        url.appendQueryParam(name: "post_id", value: params.postId)
        url.appendQueryParam(name: "single_use_ticket", value: params.singleUseTicket)
        if let userId = params.userId {
            url.appendQueryParam(name: "user_id", value: userId)
        }

        url = urlWithDarkModeParam(url: url)
        return url.absoluteString
    }
    
    private static func getCleanToken(token: String) -> String {
        return token.replacingOccurrences(of: "Bearer ", with: "")
    }
    
    public static func urlWithDarkModeParam(url: URL) -> URL {
        var urlWithDarkModeParam = url
        urlWithDarkModeParam.appendQueryParam(name: "theme", value: SPUserInterfaceStyle.isDarkMode ? "dark" : "light")
        return urlWithDarkModeParam
    }
}

extension SPWebSDKProvider {
    internal class Params {
        var module: WebModule
        var spotId: String
        var postId: String = "default"
        var userId: String?
        var singleUseTicket: String?
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
