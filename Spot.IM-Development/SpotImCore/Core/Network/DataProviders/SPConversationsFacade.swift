//
//  SPConversationsFacade.swift
//  Spot.IM-Core
//
//  Created by Andriy Fedin on 17/06/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation
import Alamofire

internal protocol SPConversationsDataProvider {

    var isLoading: Bool { get }
    var canLoadNextPage: Bool { get }
    var hasNext: Bool { get }

    var imageURLProvider: SPImageURLProvider? { get set }

    /// fetch conversation for id
    func conversation(_ id: String,
                      _ mode: SPCommentSortMode,
                      page: SPPaginationPage,
                      loadingStarted: (() -> Void)?,
                      completion: @escaping (_ response: SPConversationReadRM?, _ error: SPNetworkError?) -> Void)

    func comments(_ conversationId: String,
                  _ mode: SPCommentSortMode,
                  page: SPPaginationPage,
                  parentId: String,
                  loadingStarted: (() -> Void)?,
                  completion: @escaping (_ response: SPConversationReadRM?, _ error: SPNetworkError?) -> Void)

    func copy(modifyingOffset newOffset: Int?, hasNext: Bool?) -> SPConversationsDataProvider
}

internal final class SPConversationsFacade: SPConversationsDataProvider {

    static private let defaultHasNext = false
    static private let defaultOffset = 0

    internal var imageURLProvider: SPImageURLProvider?

    private let pageSize = 10
    private var offset = defaultOffset

    internal var isLoading = false
    internal var hasNext = defaultHasNext
    
    internal var canLoadNextPage: Bool {
        return !isLoading && hasNext
    }
    
    internal func conversation(
        _ id: String,
        _ mode: SPCommentSortMode,
        page: SPPaginationPage,
        loadingStarted: (() -> Void)? = nil,
        completion: @escaping (_ response: SPConversationReadRM?, _ error: SPNetworkError?) -> Void) {
        comments(id, mode, page: page, parentId: "", loadingStarted: loadingStarted, completion: completion)
    }
    
    internal func comments(_ id: String,
                           _ mode: SPCommentSortMode,
                           page: SPPaginationPage,
                           parentId: String,
                           loadingStarted: (() -> Void)? = nil,
                           completion: @escaping (SPConversationReadRM?, SPNetworkError?) -> Void) {
        let spRequest = SPConversationRequest.conversationRead
        guard let spotKey = SPClientSettings.spotKey else {
            let message = NSLocalizedString("Please provide Spot Key",
                                            bundle: Bundle.spot,
                                            comment: "Spot Key not set by client")
            completion(nil, SPNetworkError.custom(message))
            return
        }

        let needExtraData = page == .first
        let currentRequestOffset = page == .first ? 0 : self.offset

        // TODO: (Fedin) make sting constants for this
        let parameters = ["conversation_id": "\(spotKey)_\(id)",
            "sort_by": mode.backEndTitle,
            "offset": currentRequestOffset,
            "count": pageSize,
            "parent_id": parentId,
            "extract_data": needExtraData] as [String: Any]
        isLoading = true

        loadingStarted?()

        // TODO: (Fedin) move Alamofire.request elsewhere
        Alamofire.request(spRequest.url,
                          method: spRequest.method,
                          parameters: parameters,
                          encoding: APIConstants.encoding,
                          headers: HTTPHeaders.basic(with: spotKey, id, userSession: SPUserSessionHolder.session))
            .validate()
            .responseData { response in
                let timeOffset = page == .first ? 0.0 : 0.0
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + timeOffset, execute: {
                    self.isLoading = false

                    SPUserSessionHolder.updateSession(with: response.response?.allHeaderFields)
                    
                    let result: Result<SPConversationReadRM> = defaultDecoder.decodeResponse(from: response)
                    switch result {
                    case .success(let conversation):
                        SPUserSessionHolder.updateSessionUser(user: conversation.user)
                        self.offset = conversation.conversation?.offset ?? self.offset
                        self.hasNext = conversation.conversation?.hasNext ?? false
                        completion(conversation, nil)
                        
                    case .failure(let error):
                        let rawReport = RawReportModel(
                            url: spRequest.method.rawValue + " " + spRequest.url.absoluteString,
                            parameters: parameters,
                            errorData: response.data,
                            errorMessage: error.localizedDescription
                        )
                        SPDefaultFailureReporter().sendFailureReport(rawReport)
                        
                        completion(nil, error.spError())
                    }
                })
            }
    }

    func copy(modifyingOffset newOffset: Int? = defaultOffset,
              hasNext: Bool? = defaultHasNext) -> SPConversationsDataProvider {
        let copy = SPConversationsFacade()
        copy.offset = newOffset ?? SPConversationsFacade.defaultOffset
        copy.hasNext = hasNext ?? SPConversationsFacade.defaultHasNext
        return copy
    }
}
