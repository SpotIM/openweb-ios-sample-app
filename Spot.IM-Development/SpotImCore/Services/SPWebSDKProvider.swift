//
//  SPWebSDKProvider.swift
//  SpotImCore
//
//  Created by Alon Shprung on 16/03/2021.
//  Copyright © 2021 Spot.IM. All rights reserved.
//

import Foundation

internal final class SPWebSDKProvider {
    
    fileprivate struct Settings {
        static let helpers: OWHelpersLayer = OpenWeb.manager.ui.helpers as! OWHelpersLayer
        static let tenantConfigCommentsFilter: String = "tenant_config.user-profile.keys_to_filter_comments"
    }
    
    enum WebModule: String {
        case profile = "user-profile"
    }
    
    internal static func openWebModule(delegate: SPSafariWebPageDelegate?, params: Params) {
        if let urlString = getUrlString(params: params) {
            delegate?.openWebPage(with: urlString)
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
        
        if Settings.helpers.shouldSuppressFinmbFilter {
            // Current way for Yahoo internal testing for suppress finmb
            // We will remove this noize from the code soon
            url.appendQueryParam(name: Settings.tenantConfigCommentsFilter, value: "")
        }
        
        return url.absoluteString
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
        
        init(module: WebModule, spotId: String, postId: String) {
            self.module = module
            self.spotId = spotId
            self.postId = postId
        }
        
        convenience init(module: WebModule, spotId: String, postId: String, userId: String) {
            self.init(module: module, spotId: spotId, postId: postId)
            self.userId = userId
        }
    }
}
