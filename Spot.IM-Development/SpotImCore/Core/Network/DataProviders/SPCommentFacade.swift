//
//  SPCommentFacade.swift
//  Spot.IM-Core
//
//  Created by Andriy Fedin on 08/07/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation
import Alamofire

typealias SuccessHandler = () -> Void
typealias CommentHandler = (SPComment) -> Void
typealias DeleteCommentHandler = (SPCommentDelete) -> Void
typealias ShareCommentHandler = (URL?) -> Void
typealias ErrorHandler = (Error) -> Void

internal protocol SPCommentUpdater {

    func changeRank(_ change: SPRankChange, for commentId: String?, with parentId: String?,
                    in conversationId: String?, completion: @escaping BooleanCompletion)
    
    func createComment(parameters: [String: Any], postId: String,
                       success: @escaping CommentHandler, failure: @escaping ErrorHandler)
    
    func deleteComment(parameters: [String: Any], postId: String,
                       success: @escaping DeleteCommentHandler, failure: @escaping ErrorHandler)
    
    func reportComment(parameters: [String: Any], postId: String,
                       success: @escaping SuccessHandler, failure: @escaping ErrorHandler)
    
    func editComment(parameters: [String: Any], postId: String,
                     success: @escaping CommentHandler, failure: @escaping ErrorHandler)
    
    func shareComment(parameters: [String: Any], postId: String,
                      success: @escaping ShareCommentHandler, failure: @escaping ErrorHandler)
}

internal final class SPCommentFacade: SPCommentUpdater {
    
    let apiManager: ApiManager
    
    init(apiManager: ApiManager) {
        self.apiManager = apiManager
    }

    
    internal func changeRank(_ change: SPRankChange,
                             for commentId: String?,
                             with parentId: String?,
                             in conversationId: String?,
                             completion: @escaping BooleanCompletion) {
        let spRequest = SPConversationRequest.commentRankChange
        guard let spotKey = SPClientSettings.main.spotKey else {
            completion(false, SPNetworkError.custom("Please provide Spot Key"))
            return
        }

        guard let commentId = commentId else {
            completion(false, SPNetworkError.custom("Comment ID is required"))
            return
        }

        guard let conversationId = conversationId else {
            completion(false, SPNetworkError.custom("Conversation ID is required"))
            return
        }

        let parameters: [String: Any] = [
            ChangeRankAPIKeys.postId: "\(spotKey)_\(conversationId)",
            ChangeRankAPIKeys.operation: change.subject.rawValue,
            ChangeRankAPIKeys.parentId: parentId ?? "",
            ChangeRankAPIKeys.messageId: commentId
        ]

        let headers = HTTPHeaders.basic(with: spotKey,
                                        postId: conversationId)

        apiManager.execute(request: spRequest,
                           parameters: parameters,
                           encoding: APIConstants.encoding,
                           parser: EmptyParser(),
                           headers: headers) { (result, response) in
                            switch result {
                            case .success:
                                completion(true, nil)
                            case .failure(_):
                                completion(false, SPNetworkError.default)
                            }
                            
        }
    }
    
    internal func deleteComment(parameters: [String: Any], postId: String,
                                success: @escaping DeleteCommentHandler, failure: @escaping ErrorHandler) {
        guard let spotKey = SPClientSettings.main.spotKey
            else {
                failure(SPNetworkError.custom("Please provide Spot Key"))
                return
        }
        
        let request = SPConversationRequest.commentDelete
        let headers = HTTPHeaders.basic(with: spotKey,
                                        postId: postId)
        
        apiManager.execute(request: request,
                           parameters: parameters,
                           encoding: APIConstants.encoding,
                           parser: DecodableParser<SPCommentDelete>(),
                           headers: headers) { (result, response) in
                            switch result {
                            case .success(let deletionData):
                                success(deletionData)
                            case .failure(let error):
                                let rawReport = RawReportModel(
                                    url: request.method.rawValue + " " + request.url.absoluteString,
                                    parameters: parameters,
                                    errorData: response.data,
                                    errorMessage: error.localizedDescription
                                )
                                SPDefaultFailureReporter.shared.sendFailureReport(rawReport)
                                failure(SPNetworkError.default)
                            }
        }
    }
    
    internal func createComment(parameters: [String: Any], postId: String,
                                success: @escaping CommentHandler, failure: @escaping ErrorHandler) {
        guard let spotKey = SPClientSettings.main.spotKey
            else {
                failure(SPNetworkError.custom("Please provide Spot Key"))
                return
        }
        
        let request = SPConversationRequest.commentPost
        let headers = HTTPHeaders.basic(with: spotKey,
                                        postId: postId)
        
        apiManager.execute(request: request,
                           parameters: parameters,
                           encoding: APIConstants.encoding,
                           parser: DecodableParser<SPComment>(),
                           headers: headers) { (result, response) in
                            switch result {
                            case .success(let comment):
                                SPUserSessionHolder.freezeDisplayNameIfNeeded()
                                success(comment)
                            case .failure(let error):
                                let rawReport = RawReportModel(
                                    url: request.method.rawValue + " " + request.url.absoluteString,
                                    parameters: parameters,
                                    errorData: response.data,
                                    errorMessage: error.localizedDescription
                                )
                                SPDefaultFailureReporter.shared.sendFailureReport(rawReport)
                                
                                failure(SPNetworkError.default)
                            }
        }
    }
    
    func reportComment(parameters: [String: Any], postId: String,
                       success: @escaping SuccessHandler, failure: @escaping ErrorHandler) {
        guard let spotKey = SPClientSettings.main.spotKey
            else {
                failure(SPNetworkError.custom("Please provide Spot Key"))
                return
        }
        
        let request = SPConversationRequest.commentReport
        let headers = HTTPHeaders.basic(with: spotKey,
                                        postId: postId)
        
        apiManager.execute(request: request,
                           parameters: parameters,
                           encoding: APIConstants.encoding,
                           parser: EmptyParser(),
                           headers: headers) { (result, response) in
                            switch result {
                            case .success:
                                success()
                            case .failure(_):
                                failure(SPNetworkError.default)
                            }
        }
    }
    
    func shareComment(parameters: [String: Any], postId: String,
                      success: @escaping ShareCommentHandler, failure: @escaping ErrorHandler) {
        guard let spotKey = SPClientSettings.main.spotKey
            else {
                failure(SPNetworkError.custom("Please provide Spot Key"))
                return
        }
        
        let request = SPConversationRequest.commentShare
        let headers = HTTPHeaders.basic(with: spotKey,
                                        postId: postId)
        apiManager.execute(request: request,
                           parameters: parameters,
                           encoding: APIConstants.encoding,
                           parser: DecodableParser<SPShareLink>(),
                           headers: headers) { (result, response) in
                            switch result {
                            case .success(let link):
                                success(link.reference)
                            case .failure(_):
                                failure(SPNetworkError.default)
                            }
        }
    }
    
    func editComment(parameters: [String: Any], postId: String,
                     success: @escaping CommentHandler, failure: @escaping ErrorHandler) {
        guard let spotKey = SPClientSettings.main.spotKey
            else {
                failure(SPNetworkError.custom("Please provide Spot Key"))
                return
        }
        
        let request = SPConversationRequest.commentUpdate
        let headers = HTTPHeaders.basic(with: spotKey,
                                        postId: postId)
        
        apiManager.execute(request: request,
                           parameters: parameters,
                           encoding: APIConstants.encoding,
                           parser: DecodableParser<SPComment>(),
                           headers: headers) { (result, response) in
                            switch result {
                            case .success(let comment):
                                success(comment)
                            case .failure(_):
                                failure(SPNetworkError.default)
                            }
        }
    }
    
    private enum ChangeRankAPIKeys {
        static let postId = "conversation_id"
        static let operation = "operation"
        static let parentId = "parent_id"
        static let messageId = "message_id"
    }
    
}
