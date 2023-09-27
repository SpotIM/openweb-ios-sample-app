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
    case articleHeaderPressed
    case communityGuidelinesPressed(url: URL)
    case communityQuestionsPressed
    case postCommentPressed
    case adClosed
    case adTapped
    case closeConversationPressed
    case openPublisherProfile(userId: String)
    case openReportReason(commentId: OWCommentId, parentId: OWCommentId)
    case openCommentCreation(type: OWCommentCreationType)
    case closeReportReason
    case openClarityDetails(type: OWClarityDetailsType)
    case closeClarityDetails
    case error(_ error: OWError)
}
#else
enum OWViewActionCallbackType: Codable {
    case contentPressed
    case showMoreCommentsPressed
    case articleHeaderPressed
    case communityGuidelinesPressed(url: URL)
    case communityQuestionsPressed
    case postCommentPressed
    case adClosed
    case adTapped
    case closeConversationPressed
    case openPublisherProfile(userId: String)
    case openReportReason(commentId: OWCommentId, parentId: OWCommentId)
    case openCommentCreation(type: OWCommentCreationType)
    case closeReportReason
    case openClarityDetails(type: OWClarityDetailsType)
    case closeClarityDetails
    case error(_ error: OWError)
}
#endif

extension OWViewActionCallbackType: Equatable {
    public static func == (lhs: OWViewActionCallbackType, rhs: OWViewActionCallbackType) -> Bool {
        switch (lhs, rhs) {
        case (.contentPressed, .contentPressed):
            return true
        case (.showMoreCommentsPressed, .showMoreCommentsPressed):
            return true
        case (.articleHeaderPressed, .articleHeaderPressed):
            return true
        case (.communityGuidelinesPressed, .communityGuidelinesPressed):
            return true
        case (.communityQuestionsPressed, .communityQuestionsPressed):
            return true
        case (.postCommentPressed, .postCommentPressed):
            return true
        case (.adClosed, .adClosed):
            return true
        case (.adTapped, .adTapped):
            return true
        case (.closeConversationPressed, .closeConversationPressed):
            return true
        case (let .openPublisherProfile(lhsId), let .openPublisherProfile(rhsId)):
            return lhsId == rhsId
        case (let .openReportReason(lhsId, lhsParent), let .openReportReason(rhsId, rhsParent)):
            return lhsId == rhsId && lhsParent == rhsParent
        case (let .openCommentCreation(lhsId), let .openCommentCreation(rhsId)):
            return lhsId == rhsId
        case (.closeReportReason, .closeReportReason):
            return true
        case (let .openClarityDetails(lhsType), let .openClarityDetails(rhsType)):
            return lhsType == rhsType
        case (.closeClarityDetails, .closeClarityDetails):
            return true
        default:
            return false
        }
    }
}

