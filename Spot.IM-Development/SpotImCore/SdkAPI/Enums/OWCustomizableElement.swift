//
//  OWCustomizableElement.swift
//  SpotImCore
//
//  Created by Alon Haiut on 08/11/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit

public enum OWCustomizableElement {
    case navigation(element: OWNavigationCustomizableElement)
    case header(element: OWHeaderCustomizableElement)
    case articleDescription(element: OWArticleDescriptionCustomizableElement)
    case summary(element: OWSummaryCustomizableElement)
    case summaryHeader(element: OWSummaryHeaderCustomizableElement)
    case onlineUsers(element: OWOnlineUsersCustomizableElement)
    case commentCreationCTA(element: OWCommentCreationCTACustomizableElement)
    case communityQuestion(element: OWCommunityQuestionCustomizableElement)
    case communityGuidelines(element: OWCommunityGuidelinesCustomizableElement)
    case emptyState(element: OWEmptyStateCustomizableElement)
    case emptyStateCommentingEnded(element: OWEmptyStateCommentingEndedCustomizableElement)
    case commentingEnded(element: OWCommentingEndedCustomizableElement)
}
