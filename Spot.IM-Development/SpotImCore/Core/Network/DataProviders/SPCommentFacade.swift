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

        // TODO: (Fedin) move Alamofire.request elsewhere
        AF.request(spRequest.url,
                          method: spRequest.method,
                          parameters: parameters,
                          encoding: APIConstants.encoding,
                          headers: headers)
            .validate()
            .log(level: .medium)
            .responseData { response in
                switch response.result {
                case .success:
                    completion(true, nil)
                case .failure:
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
        
        let request = SPConversationRequest.commentPost
        let headers = HTTPHeaders.basic(with: spotKey,
                                        postId: postId)
        
        AF.request(request.url,
                          method: .delete,
                          parameters: parameters,
                          encoding: APIConstants.encoding,
                          headers: headers)
            .validate()
            .log(level: .medium)
            .responseData { response in
                let result: Result<SPCommentDelete> = defaultDecoder.decodeResponse(from: response)
                
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
                    SPDefaultFailureReporter().sendFailureReport(rawReport)
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

        AF.request(request.url,
                          method: .post,
                          parameters: parameters,
                          encoding: APIConstants.encoding,
                          headers: headers)
            .validate()
            .log(level: .medium)
            .responseData { response in
                let result: Result<SPComment> = defaultDecoder.decodeResponse(from: response)
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
                    SPDefaultFailureReporter().sendFailureReport(rawReport)
                    
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
        
        AF.request(request.url,
                          method: request.method,
                          parameters: parameters,
                          encoding: APIConstants.encoding,
                          headers: headers)
            .validate()
            .log(level: .medium)
            .responseData { response in
                switch response.result {
                case .success:
                    success()
                    
                case .failure:
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
        
        AF.request(request.url,
                          method: request.method,
                          parameters: parameters,
                          encoding: APIConstants.encoding,
                          headers: headers)
            .validate()
            .log(level: .medium)
            .responseData { response in
                let result: Result<SPShareLink> = defaultDecoder.decodeResponse(from: response)
                switch result {
                case .success(let link):
                    success(link.reference)
                    
                case .failure:
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
        
        AF.request(request.url,
                          method: request.method,
                          parameters: parameters,
                          encoding: APIConstants.encoding,
                          headers: headers)
            .validate()
            .log(level: .medium)
            .responseData { _ in }
    }
    
    private enum ChangeRankAPIKeys {
        static let postId = "conversation_id"
        static let operation = "operation"
        static let parentId = "parent_id"
        static let messageId = "message_id"
    }
    
}
