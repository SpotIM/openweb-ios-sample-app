//
//  SPConfigurationInitialization.swift
//  Spot.IM-Core
//
//  Created by Eugene on 8/2/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation

struct SPConfigurationInitialization: Decodable {

    enum CodingKeys: String, CodingKey {

        case ads, name, brandColor, categoryId, commentRepliesMaxDepth, customLogin, giphyLevel,
        displayNameInSayControlForGuests, emojiKeyboardEnabled, emojisEnabled, enableDislikes,
        enableRealtimeCommentsSticky, enableSpotimUtm, enableUserPoints, externalPublicProfile,
        hasCommunity, id, inpageSkin, lazyLoadMargin, loadingIndicatorEnabled, ltr, mainLanguage,
        miniNewsfeedEnabled, monetized, multipleModeratorsMode, newsfeedPosition, newsfeedSkin,
        openLinksInNewTab, openingMode, platform, recommendationEnabled, richSayControlEnabled, sortBy,
        ssoEditableProfile, ssoEnabled, ssoStartedBySpotim, subCategoryId, tickerIcon, tickerIconSize,
        tickerSkin, uppercaseMsgsEnabled, userModerationEnabled, websiteUrl

        case avatarsFont = "avatars.font"
        case avatarsFontBackgroundColor = "avatars.fontBackgroundColor"
        case avatarsInitials = "avatars.initials"
        case avatarsNumbered = "avatars.numbered"
        case avatarsScheme = "avatars.scheme"
        case circulationEnabled = "circulation.enabled"
        case circulationRowsCount = "circulation.rowsCount"
        case connectNetworks0 = "connectNetworks.0"
        case connectNetworks1 = "connectNetworks.1"
        case connectNetworks2 = "connectNetworks.2"
        case connectNetworks3 = "connectNetworks.3"
        case connectNetworks4 = "connectNetworks.4"
        case connectNetworks5 = "connectNetworks.5"
        case injectionFrameScript = "injection.frameScript"
        case injectionFrameStyle = "injection.frameStyle"
        case injectionHostOptions = "injection.hostPptions"
        case networkId = "network.id"
        case policyAllowGuestsToLike = "policy.allowGuestsToLike"
        case policyForceRegister = "policy.forceRegister"
        case policyRogerMode = "policy.rogerMode"

    }

    let name: String?
    let ads: String?
    let brandColor: String?
    let categoryId: Int?
    let commentRepliesMaxDepth: Int?
    let customLogin: Bool?
    let giphyLevel: String?
    let displayNameInSayControlForGuests: Bool?
    let emojiKeyboardEnabled: Bool?
    let emojisEnabled: Bool?
    let enableDislikes: Bool?
    let enableRealtimeCommentsSticky: Bool?
    let enableSpotimUtm: Bool?
    let enableUserPoints: Bool?
    let externalPublicProfile: Bool?
    let hasCommunity: Bool?
    let id: String?
    let inpageSkin: String?
    let lazyLoadMargin: String?
    let loadingIndicatorEnabled: Bool?
    let ltr: Bool?
    let mainLanguage: String?
    let miniNewsfeedEnabled: Bool?
    let monetized: Bool?
    let multipleModeratorsMode: Bool?
    let newsfeedPosition: String?
    let newsfeedSkin: String?
    let openLinksInNewTab: Bool?
    let openingMode: String?
    let platform: String?
    let recommendationEnabled: Bool?
    let richSayControlEnabled: Bool?
    let sortBy: SPCommentSortMode?
    let ssoEditableProfile: Bool?
    let ssoEnabled: Bool?
    let ssoStartedBySpotim: Bool?
    let subCategoryId: Int?
    let tickerIcon: String?
    let tickerIconSize: Int?
    let tickerSkin: String?
    let uppercaseMsgsEnabled: Bool?
    let userModerationEnabled: Bool?
    let websiteUrl: String?
    let avatarsFont: String?
    let avatarsFontBackgroundColor: String?
    let avatarsInitials: Bool?
    let avatarsNumbered: Bool?
    let avatarsScheme: String?
    let circulationEnabled: Bool?
    let circulationRowsCount: Int?
    let connectNetworks0: String?
    let connectNetworks1: String?
    let connectNetworks2: String?
    let connectNetworks3: String?
    let connectNetworks4: String?
    let connectNetworks5: String?
    let injectionFrameScript: String?
    let injectionFrameStyle: String?
    let injectionHostOptions: String?
    let networkId: String?
    let policyAllowGuestsToLike: Bool?
    let policyForceRegister: Bool?
    let policyRogerMode: Bool?

}
