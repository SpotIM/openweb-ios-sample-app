//
//  OWViewActionCallbackType.swift
//  SpotImCore
//
//  Created by Alon Haiut on 06/09/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public enum OWViewActionCallbackType: Codable {
    case contentPressed
    case showMoreCommentsPressed
    case communityGuidelinesPressed(url: URL)
    case adClosed
    case adTapped
    case closeConversationPressed
    case openPublisherProfile(ssoPublisherId: String, type: OWUserProfileType)
    case openOWProfile(data: OWOpenProfileData)
    case openReportReason(commentId: OWCommentId, parentId: OWCommentId)
    case openCommentCreation(type: OWCommentCreationType)
    case closeReportReason
    case openClarityDetails(data: OWClarityDetailsRequireData)
    case closeClarityDetails
    case floatingCommentCreationDismissed
    case error(_ error: OWError)
    case commentSubmitted
    case closeWebView
    case openLinkInComment(url: URL)
}
#else
enum OWViewActionCallbackType: Codable {
    case contentPressed
    case showMoreCommentsPressed
    case communityGuidelinesPressed(url: URL)
    case adClosed
    case adTapped
    case closeConversationPressed
    case openPublisherProfile(ssoPublisherId: String, type: OWUserProfileType)
    case openOWProfile(data: OWOpenProfileData)
    case openReportReason(commentId: OWCommentId, parentId: OWCommentId)
    case openCommentCreation(type: OWCommentCreationType)
    case closeReportReason
    case openClarityDetails(data: OWClarityDetailsRequireData)
    case closeClarityDetails
    case floatingCommentCreationDismissed
    case error(_ error: OWError)
    case commentSubmitted
    case closeWebView
    case openLinkInComment(url: URL)
}
#endif

extension OWViewActionCallbackType: Equatable {
    public static func == (lhs: OWViewActionCallbackType, rhs: OWViewActionCallbackType) -> Bool {
        switch (lhs, rhs) {
        case (.contentPressed, .contentPressed):
            return true
        case (.showMoreCommentsPressed, .showMoreCommentsPressed):
            return true
        case (.communityGuidelinesPressed, .communityGuidelinesPressed):
            return true
        case (.adClosed, .adClosed):
            return true
        case (.adTapped, .adTapped):
            return true
        case (.closeConversationPressed, .closeConversationPressed):
            return true
        case (let .openPublisherProfile(lhsId, lhsType), let .openPublisherProfile(rhsId, rhsType)):
            return lhsId == rhsId && lhsType == rhsType
        case (let .openOWProfile(lhsData), let .openOWProfile(rhsData)):
            return lhsData == rhsData
        case (let .openReportReason(lhsId, lhsParent), let .openReportReason(rhsId, rhsParent)):
            return lhsId == rhsId && lhsParent == rhsParent
        case (let .openCommentCreation(lhsId), let .openCommentCreation(rhsId)):
            return lhsId == rhsId
        case (.closeReportReason, .closeReportReason):
            return true
        case (let .openClarityDetails(lhsData), let .openClarityDetails(rhsData)):
            return lhsData.type == rhsData.type && lhsData.commentId == rhsData.commentId
        case (.closeClarityDetails, .closeClarityDetails):
            return true
        case (.floatingCommentCreationDismissed, .floatingCommentCreationDismissed):
            return true
        case (let .error(lhsErr), let .error(rhsErr)):
            return lhsErr.description == rhsErr.description
        case (.commentSubmitted, .commentSubmitted):
            return true
        case (.closeWebView, .closeWebView):
            return true
        case (.openLinkInComment(let lhsUrl), .openLinkInComment(let rhsUrl)):
            return lhsUrl == rhsUrl
        default:
            return false
        }
    }
}

