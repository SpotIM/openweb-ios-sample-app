//
//  OWUserBadgeService.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 09/01/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

protocol OWUserBadgeServicing {
    func userBadgeText(user: SPUser, conversationConfig: SPConfigurationConversation) -> String?
}

class OWUserBadgeService: OWUserBadgeServicing {
    func userBadgeText(user: SPUser, conversationConfig: SPConfigurationConversation) -> String? {
        guard user.isStaff else { return nil }
        
        if let translations = conversationConfig.translationTextOverrides,
           let currentTranslation = LocalizationManager.currentLanguage == .spanish ? translations["es-ES"] : translations[LocalizationManager.getLanguageCode()]
        {
            if user.isAdmin, let adminBadge = currentTranslation[BadgesOverrideKeys.admin.rawValue] {
                return adminBadge
            } else if user.isJournalist, let jurnalistBadge = currentTranslation[BadgesOverrideKeys.journalist.rawValue] {
                return jurnalistBadge
            } else if user.isModerator, let moderatorBadge = currentTranslation[BadgesOverrideKeys.moderator.rawValue] {
                return moderatorBadge
            } else if user.isCommunityModerator, let communityModeratorBadge = currentTranslation[BadgesOverrideKeys.communityModerator.rawValue]  {
                return communityModeratorBadge
            }
        }
        return user.authorityTitle
    }
}
