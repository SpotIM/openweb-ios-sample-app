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
    case navigationBarTitle(_ label: UILabel)
    case navigationBar(_ navigationBar: UINavigationBar)
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
#else
enum OWCustomizableElement {
    case navigationBarTitle(_ label: UILabel)
    case navigationBar(_ navigationBar: UINavigationBar)
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
#endif
