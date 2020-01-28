//
//  SPConversationsFacade.swift
//  Spot.IM-Core
//
//  Created by Andriy Fedin on 17/06/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit

class NetworkDataProvider {

    let manager: ApiManager

    init(apiManager: ApiManager) {
        self.manager = apiManager
    }
}

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

    func commnetsCounters(conversationIds: [String]) -> Promise<[String: SPConversationCounters]>
    
    func copy(modifyingOffset newOffset: Int?, hasNext: Bool?) -> SPConversationsDataProvider
}

internal final class SPConversationsFacade: NetworkDataProvider, SPConversationsDataProvider {

    static private let defaultHasNext = false
    static private let defaultOffset = 0

    internal var imageURLProvider: SPImageURLProvider?

    private let pageSize = 15
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
        guard let spotKey = SPClientSettings.main.spotKey else {
            let message = LocalizationManager.localizedString(key: "Please provide Spot Key")
            completion(nil, SPNetworkError.custom(message))
            return
        }

        let needExtraData = page == .first
        let currentRequestOffset = page == .first ? 0 : self.offset

        let depth = parentId.isEmpty ? 2 : 1
        
        // TODO: (Fedin) make sting constants for this
        let parameters: [String: Any] = [
            "conversation_id": "\(spotKey)_\(id)",
            "sort_by": mode.backEndTitle,
            "offset": currentRequestOffset,
            "count": pageSize,
            "parent_id": parentId,
            "extract_data": needExtraData,
            "depth": depth
        ]
        let headers = HTTPHeaders.basic(
            with: spotKey,
            postId: id)
        isLoading = true

        loadingStarted?()

        manager.execute(
            request: spRequest,
            parameters: parameters,
            parser: DecodableParser<SPConversationReadRM>(),
            headers: headers
        ) { (result, response) in
            let timeOffset = page == .first ? 0.0 : 0.0
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + timeOffset) {
                self.isLoading = false

                SPUserSessionHolder.updateSession(with: response.response)

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
            }
        }
    }

    internal func commnetsCounters(conversationIds: [String]) -> Promise<[String: SPConversationCounters]> {
        return Promise { seal in
            let spRequest = SPConversationRequest.commentsCounters
            guard let spotKey = SPClientSettings.main.spotKey else {
                let message = LocalizationManager.localizedString(key: "Please provide Spot Key")
                seal.reject(SPNetworkError.custom(message))
                return
            }
            
            // TODO: (Fedin) make sting constants for this
            let parameters: [String: Any] = [
                "conversation_ids": conversationIds,
            ]
            let headers = HTTPHeaders.basic(
                with: spotKey)

            manager.execute(
                request: spRequest,
                parameters: parameters,
                parser: DecodableParser<[String:[String: SPConversationCounters]]>(),
                headers: headers
            ) { (result, response) in
                switch result {
                case .success(let counters):
                    if let dic = counters["counts"] {
                        seal.fulfill(dic)
                    } else {
                        seal.reject(SPNetworkError.custom("Bad response: no key 'counts' in json"))
                    }
                case .failure(let error):
                    let rawReport = RawReportModel(
                        url: spRequest.method.rawValue + " " + spRequest.url.absoluteString,
                        parameters: parameters,
                        errorData: response.data,
                        errorMessage: error.localizedDescription
                    )
                    SPDefaultFailureReporter().sendFailureReport(rawReport)
                    seal.reject(error)
                }
            }
        }
    }
    
    func copy(modifyingOffset newOffset: Int? = defaultOffset,
              hasNext: Bool? = defaultHasNext) -> SPConversationsDataProvider {
        let copy = SPConversationsFacade(apiManager: manager)
        copy.offset = newOffset ?? SPConversationsFacade.defaultOffset
        copy.hasNext = hasNext ?? SPConversationsFacade.defaultHasNext
        return copy
    }

}
