//
//  OWUserBadgeService.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 09/01/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol OWUserBadgeServicing {
    func userBadgeText(user: SPUser) -> Observable<OWUserBadgeType>
}

class OWUserBadgeService: OWUserBadgeServicing {

    fileprivate let servicesProvider: OWSharedServicesProviding

    init(servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.servicesProvider = servicesProvider
    }

    fileprivate var conversationConfig: Observable<SPConfigurationConversation> {
        servicesProvider.spotConfigurationService()
            .config(spotId: OWManager.manager.spotId)
            .map { config -> SPConfigurationConversation? in
                return config.conversation
            }
            .unwrap()
    }

    func userBadgeText(user: SPUser) -> Observable<OWUserBadgeType> {
        return self.conversationConfig
            .map { conversationConfig in
                guard user.isStaff else { return .empty }

                if let translations = conversationConfig.translationTextOverrides,
                   let currentTranslation = SPLocalizationManager.currentLanguage == .spanish ? translations["es-ES"] : translations[SPLocalizationManager.getLanguageCode()] {
                    if user.isAdmin, let adminBadge = currentTranslation[BadgesOverrideKeys.admin.rawValue] {
                        return .badge(text: adminBadge)
                    } else if user.isJournalist, let jurnalistBadge = currentTranslation[BadgesOverrideKeys.journalist.rawValue] {
                        return .badge(text: jurnalistBadge)
                    } else if user.isModerator, let moderatorBadge = currentTranslation[BadgesOverrideKeys.moderator.rawValue] {
                        return .badge(text: moderatorBadge)
                    } else if user.isCommunityModerator, let communityModeratorBadge = currentTranslation[BadgesOverrideKeys.communityModerator.rawValue] {
                        return .badge(text: communityModeratorBadge)
                    }
                }
                if let title = user.authorityTitle {
                    return .badge(text: title)
                }
                return .empty
            }
    }
}

enum OWUserBadgeType {
    case empty
    case badge(text: String)
}
