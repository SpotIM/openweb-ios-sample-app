//
//  OWConversationEndpoint.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 25/07/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

enum OWConversationEndpoints: OWEndpoints {
    fileprivate struct Metrics {
        static let parentCommentDepth: Int = 2
        static let replyCommentDepth: Int = 1
    }

    case conversationAsync(articleUrl: String)
    case conversationRead(mode: OWSortOption, page: OWPaginationPage, count: Int, childCount: Int?, parentId: String, messageId: String, offset: Int)
    case commentReport(id: String, parentId: String?)
    case commentPost(parameters: OWNetworkParameters)
    case commentShare(id: String, parentId: String?)
    case commentUpdate(parameters: OWNetworkParameters)
    case commentDelete(id: String, parentId: String?)
    case commentRankChange(conversationId: String, operation: String, commentId: String)
    case commentsCounters(conversationIds: [String])
    case commentStatus(commentId: String)

    // MARK: - HTTPMethod
    var method: OWNetworkHTTPMethod {
        switch self {
        case .conversationAsync: return .post
        case .conversationRead: return .post
        case .commentPost: return .post
        case .commentUpdate: return .patch
        case .commentDelete: return .delete
        case .commentRankChange: return .post
        case .commentReport: return .post
        case .commentShare: return .post
        case .commentsCounters: return .post
        case .commentStatus: return .get
        }
    }

    // MARK: - Path
    var path: String {
        switch self {
        case .conversationAsync: return "/conversation/async"
        case .conversationRead: return "/conversation/read"
        case .commentPost, .commentUpdate, .commentDelete: return "/conversation/comment"
        case .commentRankChange: return "/rank/rank/message"
        case .commentReport: return "/conversation/report/message"
        case .commentShare: return "/conversation/message/share"
        case .commentsCounters: return "/conversation/count"
        case .commentStatus(let commentId): return "/message/\(commentId)/status"
        }
    }

    // MARK: - Parameters
    var parameters: OWNetworkParameters? {
        switch self {
        case .conversationAsync(let articleUrl):
            return ["host_url": articleUrl]
        case .conversationRead(let mode, let page, let count, let childCount, let parentId, let messageId, let offset):
            var params: [String: Any] = [
                "sort_by": mode.rawValue,
                "offset": offset,
                "count": count,
                "parent_id": parentId,
                "message_id": messageId,
                "extract_data": page == .first,
                "depth": parentId.isEmpty ? Metrics.parentCommentDepth : Metrics.replyCommentDepth
            ]
            if let childCount = childCount {
                params["child_count"] = childCount
            }
            return params
        case .commentReport(let id, let parentId):
            var params = ["message_id": id]
            if let parentId = parentId {
                params["parent_Id"] = parentId
            }
            return params
        case .commentPost(let parameters):
            return parameters
        case .commentShare(let id, let parentId):
            var params = ["message_id": id]
            if let parentId = parentId {
                params["parent_Id"] = parentId
            }
            return params
        case .commentUpdate(let parameters):
            return parameters
        case .commentDelete(let id, let parentId):
            var params = ["message_id": id]
            if let parentId = parentId {
                params["parent_Id"] = parentId
            }
            return params
        case .commentRankChange(let conversationId, let operation, let commentId):
            let spotKey = SPClientSettings.main.spotKey
            return [
                "conversation_id": "\(spotKey)_\(conversationId)",
                "operation": operation,
                "message_id": commentId
            ]
        case .commentsCounters(let conversationIds):
            return ["conversation_ids": conversationIds]
        case .commentStatus:
            return nil
        }
    }
}

fileprivate struct OWConversationEndpointConst {
    static let PAGE_SIZE = 15
}

protocol OWConversationAPI {
    func fetchConversation(articleUrl: String) -> OWNetworkResponse<EmptyDecodable>
    func conversationRead(
        mode: OWSortOption,
        page: OWPaginationPage,
        count: Int,
        childCount: Int?,
        parentId: String,
        messageId: String,
        offset: Int
    ) -> OWNetworkResponse<OWConversationReadRM>
    func commentReport(id: String, parentId: String?) -> OWNetworkResponse<EmptyDecodable>
    func commentPost(parameters: OWNetworkParameters) -> OWNetworkResponse<OWComment>
    func commentShare(id: String, parentId: String?) -> OWNetworkResponse<OWShareLink>
    func commentUpdate(parameters: OWNetworkParameters) -> OWNetworkResponse<OWComment>
    func commentDelete(id: String, parentId: String?) -> OWNetworkResponse<SPCommentDelete>
    func commentRankChange(conversationId: String, operation: String, commentId: String) -> OWNetworkResponse<EmptyDecodable>
    func commentsCounters(conversationIds: [String]) -> OWNetworkResponse<OWConversationCountersResponse>
    func commentStatus(commentId: String) -> OWNetworkResponse<OWCommentStatusResponse>
}

extension OWConversationAPI {
    // Better accesability to conversationRead
    func conversationRead(
        mode: OWSortOption,
        page: OWPaginationPage = .next,
        count: Int = OWConversationEndpointConst.PAGE_SIZE,
        childCount: Int? = nil,
        parentId: String = "",
        messageId: String = "",
        offset: Int = 0
    ) -> OWNetworkResponse<OWConversationReadRM> {
        return conversationRead(mode: mode, page: page, count: count, childCount: childCount, parentId: parentId, messageId: messageId, offset: offset)
    }
}

extension OWNetworkAPI: OWConversationAPI {
    // Access by .conversation for readability
    var conversation: OWConversationAPI { return self }

    func fetchConversation(articleUrl: String) -> OWNetworkResponse<EmptyDecodable> {
        let endpoint = OWConversationEndpoints.conversationAsync(articleUrl: articleUrl)
        let requestConfigure = request(for: endpoint)
        return performRequest(route: requestConfigure)
    }

    func conversationRead(
        mode: OWSortOption,
        page: OWPaginationPage,
        count: Int,
        childCount: Int?,
        parentId: String,
        messageId: String,
        offset: Int
    ) -> OWNetworkResponse<OWConversationReadRM> {
        let endpoint = OWConversationEndpoints.conversationRead(mode: mode, page: page, count: count, childCount: childCount, parentId: parentId, messageId: messageId, offset: offset)
        let requestConfigure = request(for: endpoint)
        return performRequest(route: requestConfigure)
    }

    func commentReport(id: String, parentId: String?) -> OWNetworkResponse<EmptyDecodable> {
        let endpoint = OWConversationEndpoints.commentReport(id: id, parentId: parentId)
        let requestConfigure = request(for: endpoint)
        return performRequest(route: requestConfigure)
    }

    func commentPost(parameters: OWNetworkParameters) -> OWNetworkResponse<OWComment> {
        let endpoint = OWConversationEndpoints.commentPost(parameters: parameters)
        let requestConfigure = request(for: endpoint)
        return performRequest(route: requestConfigure)
    }

    func commentShare(id: String, parentId: String?) -> OWNetworkResponse<OWShareLink> {
        let endpoint = OWConversationEndpoints.commentShare(id: id, parentId: parentId)
        let requestConfigure = request(for: endpoint)
        return performRequest(route: requestConfigure)
    }

    func commentUpdate(parameters: OWNetworkParameters) -> OWNetworkResponse<OWComment> {
        let endpoint = OWConversationEndpoints.commentUpdate(parameters: parameters)
        let requestConfigure = request(for: endpoint)
        return performRequest(route: requestConfigure)
    }

    func commentDelete(id: String, parentId: String?) -> OWNetworkResponse<SPCommentDelete> {
        let endpoint = OWConversationEndpoints.commentDelete(id: id, parentId: parentId)
        let requestConfigure = request(for: endpoint)
        return performRequest(route: requestConfigure)
    }

    func commentRankChange(conversationId: String, operation: String, commentId: String) -> OWNetworkResponse<EmptyDecodable> {
        let endpoint = OWConversationEndpoints.commentRankChange(conversationId: conversationId, operation: operation, commentId: commentId)
        let requestConfigure = request(for: endpoint)
        return performRequest(route: requestConfigure)
    }

    func commentsCounters(conversationIds: [String]) -> OWNetworkResponse<OWConversationCountersResponse> {
        let endpoint = OWConversationEndpoints.commentsCounters(conversationIds: conversationIds)
        let requestConfigure = request(for: endpoint)
        return performRequest(route: requestConfigure)
    }

    func commentStatus(commentId: String) -> OWNetworkResponse<OWCommentStatusResponse> {
        let endpoint = OWConversationEndpoints.commentStatus(commentId: commentId)
        let requestConfigure = request(for: endpoint)
        return performRequest(route: requestConfigure)
    }
}

enum OWPaginationPage {
    case first
    case next
}
