//
//  OWUserBadgeService.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 09/01/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

protocol OWUserBadgeServicing {
    func userBadgeText(user: SPUser, conversationConfig: SPConfigurationConversation) -> OWUserBadgeType
}

class OWUserBadgeService: OWUserBadgeServicing {
    func userBadgeText(user: SPUser, conversationConfig: SPConfigurationConversation) -> OWUserBadgeType {
        guard user.isStaff else { return .empty }
        
        if let translations = conversationConfig.translationTextOverrides,
           let currentTranslation = LocalizationManager.currentLanguage == .spanish ? translations["es-ES"] : translations[LocalizationManager.getLanguageCode()]
        {
            if user.isAdmin, let adminBadge = currentTranslation[BadgesOverrideKeys.admin.rawValue] {
                return .badge(text: adminBadge)
            } else if user.isJournalist, let jurnalistBadge = currentTranslation[BadgesOverrideKeys.journalist.rawValue] {
                return .badge(text: jurnalistBadge)
            } else if user.isModerator, let moderatorBadge = currentTranslation[BadgesOverrideKeys.moderator.rawValue] {
                return .badge(text: moderatorBadge)
            } else if user.isCommunityModerator, let communityModeratorBadge = currentTranslation[BadgesOverrideKeys.communityModerator.rawValue]  {
                return .badge(text: communityModeratorBadge)
            }
        }
        if let title = user.authorityTitle {
            return .badge(text: title)
        }
        return .empty
    }
}

enum OWUserBadgeType {
    case empty
    case badge(text: String)
}
