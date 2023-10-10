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
    fileprivate let localizationManager: OWLocalizationManagerProtocol

    init(servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared,
         localizationManager: OWLocalizationManagerProtocol = OWLocalizationManager.shared) {
        self.servicesProvider = servicesProvider
        self.localizationManager = localizationManager
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
            .withLatestFrom(localizationManager.currentLanguage) { conversationConfig, currentLanguage -> OWUserBadgeType in
                guard user.isStaff else { return .empty }

                if let translations = conversationConfig.translationTextOverrides,
                   let currentTranslation = translations[currentLanguage.userBadgeCode] {
                    if user.isAdmin, let adminBadge = currentTranslation[OWBadgesKeys.admin.rawValue] {
                        return .badge(text: adminBadge)
                    } else if user.isJournalist, let jurnalistBadge = currentTranslation[OWBadgesKeys.journalist.rawValue] {
                        return .badge(text: jurnalistBadge)
                    } else if user.isModerator, let moderatorBadge = currentTranslation[OWBadgesKeys.moderator.rawValue] {
                        return .badge(text: moderatorBadge)
                    } else if user.isCommunityModerator, let communityModeratorBadge = currentTranslation[OWBadgesKeys.communityModerator.rawValue] {
                        return .badge(text: communityModeratorBadge)
                    }
                } else if let title = user.authorityTitle {
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
