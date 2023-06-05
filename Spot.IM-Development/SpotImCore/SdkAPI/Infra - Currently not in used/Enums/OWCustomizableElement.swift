//
//  OWCustomizableElement.swift
//  SpotImCore
//
//  Created by Alon Haiut on 08/11/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit

#if NEW_API
public enum OWCustomizableElement {
    case navigationTitle(label: UILabel)
    case navigationBar(element: OWNavigationBarCustomizableElement)
    case articleDescription(element: OWArticleDescriptionCustomizableElement) // TODO image
    case summery(element: OWSummeryCustomizableElement) // Done
    case summeryHeader(element: OWSummeryHeaderCustomizableElement) // Done
    case onlineUsers(element: OWOnlineUsersCustomizableElement) // Done
    case commentCreationCTA(element: OWCommentCreationCTACustomizableElement)
    case communityQuestion(element: OWCommunityQuestionCustomizableElement) // TODO regular
    case communityGuidelines(element: OWCommunityGuidelinesCustomizableElement) // Done
    case emptyState(element: OWEmptyStateCustomizableElement) // Done
    case emptyStateCommentingEnded(element: OWEmptyStateCommentingEndedCustomizableElement)
    case commentingEnded(element: OWCommentingEndedCustomizableElement)
}
#else
enum OWCustomizableElement {
    case navigationTitle(label: UILabel)
    case navigationBar(element: OWNavigationBarCustomizableElement)
    case articleDescription(element: OWArticleDescriptionCustomizableElement) // TODO image
    case summery(element: OWSummeryCustomizableElement) // Done
    case summeryHeader(element: OWSummeryHeaderCustomizableElement) // Done
    case onlineUsers(element: OWOnlineUsersCustomizableElement) // Done
    case commentCreationCTA(element: OWCommentCreationCTACustomizableElement)
    case communityQuestion(element: OWCommunityQuestionCustomizableElement) // TODO regular
    case communityGuidelines(element: OWCommunityGuidelinesCustomizableElement) // Done
    case emptyState(element: OWEmptyStateCustomizableElement) // Done
    case emptyStateCommentingEnded(element: OWEmptyStateCommentingEndedCustomizableElement)
    case commentingEnded(element: OWCommentingEndedCustomizableElement)
}
#endif
