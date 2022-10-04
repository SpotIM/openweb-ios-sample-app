//
//  SPConversationsFacade.swift
//  Spot.IM-Core
//
//  Created by Andriy Fedin on 17/06/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift

class NetworkDataProvider {

    let manager: OWApiManager
    let servicesProvider: OWSharedServicesProviding

    init(apiManager: OWApiManager, servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.servicesProvider = servicesProvider
        self.manager = apiManager
    }
}

internal protocol SPConversationsDataProvider {

    var isLoading: Bool { get }
    var canLoadNextPage: Bool { get }
    var hasNext: Bool { get }

    var imageURLProvider: SPImageProvider? { get set }

    func resetOffset()
    
    /// fetch conversation for id
    func conversation(_ id: String,
                      _ mode: SPCommentSortMode,
                      page: SPPaginationPage,
                      loadingStarted: (() -> Void)?,
                      loadingFinished: (() -> Void)?,
                      completion: @escaping (_ response: SPConversationReadRM?, _ error: SPNetworkError?) -> Void)

    func comments(_ conversationId: String,
                  _ mode: SPCommentSortMode,
                  page: SPPaginationPage,
                  parentId: String,
                  loadingStarted: (() -> Void)?,
                  loadingFinished: (() -> Void)?,
                  completion: @escaping (_ response: SPConversationReadRM?, _ error: SPNetworkError?) -> Void)

    func commnetsCounters(conversationIds: [String]) -> Observable<[String: SPConversationCounters]>
    func conversationAsync(postId: String, articleUrl: String)
    func copy(modifyingOffset newOffset: Int?, hasNext: Bool?) -> SPConversationsDataProvider
}

internal final class SPConversationsFacade: NetworkDataProvider, SPConversationsDataProvider {

    static private let defaultHasNext = false
    static private let defaultOffset = 0

    internal var imageURLProvider: SPImageProvider?

    private let pageSize = 15
    private var offset = defaultOffset

    internal var isLoading = false
    internal var hasNext = defaultHasNext
    
    internal var canLoadNextPage: Bool {
        return !isLoading && hasNext
    }
    
    internal func resetOffset() {
        self.offset = SPConversationsFacade.defaultOffset
    }

    internal func conversation(
        _ id: String,
        _ mode: SPCommentSortMode,
        page: SPPaginationPage,
        loadingStarted: (() -> Void)? = nil,
        loadingFinished: (() -> Void)?,
        completion: @escaping (_ response: SPConversationReadRM?, _ error: SPNetworkError?) -> Void) {
        comments(id, mode, page: page, parentId: "", loadingStarted: loadingStarted, loadingFinished: loadingFinished, completion: completion)
    }

    internal func comments(_ id: String,
                           _ mode: SPCommentSortMode,
                           page: SPPaginationPage,
                           parentId: String,
                           loadingStarted: (() -> Void)? = nil,
                           loadingFinished: (() -> Void)?,
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
            "sort_by": mode.rawValue,
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
            parser: OWDecodableParser<SPConversationReadRM>(),
            headers: headers
        ) { (result, response) in
            DispatchQueue.main.async {
                self.isLoading = false
                loadingFinished?()

                SPUserSessionHolder.updateSession(with: response.response)

                switch result {
                case .success(let conversation):
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
                    SPDefaultFailureReporter.shared.report(error: .networkError(rawReport: rawReport))
                    completion(nil, error.spError())
                }
            }
        }
    }

    internal func commnetsCounters(conversationIds: [String]) -> Observable<[String: SPConversationCounters]> {
        return Observable.create { [weak self] observer in
            guard let self = self, let spotKey = SPClientSettings.main.spotKey else {
                let message = LocalizationManager.localizedString(key: "Please provide Spot Key")
                observer.onError(SPNetworkError.custom(message))
                return Disposables.create()
            }
            
            let spRequest = SPConversationRequest.commentsCounters
            let parameters: [String: Any] = [
                "conversation_ids": conversationIds,
            ]
            let headers = HTTPHeaders.basic(
                with: spotKey)
            
            let task = self.manager.execute(
                request: spRequest,
                parameters: parameters,
                parser: OWDecodableParser<[String:[String: SPConversationCounters]]>(),
                headers: headers
            ) { (result, response) in
                switch result {
                case .success(let counters):
                    if let dic = counters["counts"] {
                        observer.onNext(dic)
                        observer.onCompleted()
                    } else {
                        observer.onError(SPNetworkError.custom("Bad response: no key 'counts' in json"))
                    }
                case .failure(let error):
                    let rawReport = RawReportModel(
                        url: spRequest.method.rawValue + " " + spRequest.url.absoluteString,
                        parameters: parameters,
                        errorData: response.data,
                        errorMessage: error.localizedDescription
                    )
                    SPDefaultFailureReporter.shared.report(error: .networkError(rawReport: rawReport))
                    observer.onError(error)
                }
            }
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
    
    internal func conversationAsync(postId: String, articleUrl: String) {
        let spRequest = SPConversationRequest.conversationAsync
        guard let spotKey = SPClientSettings.main.spotKey else {
            return
        }
        
        let parameters: [String: Any] = [
            "host_url": articleUrl
        ]
        let headers = HTTPHeaders.basic(with: spotKey, postId: postId)
        
        manager.execute(
            request: spRequest,
            parameters: parameters,
            encoding: OWJsonWithoutEscapingSlashesEncoding(),
            parser: OWEmptyParser(),
            headers: headers
        ) { [weak self] (result, response) in
            guard let self = self else { return }
            switch result {
            case .success:
                self.servicesProvider.logger().log(level: .verbose, "Succesfully sent conversation async")
            case .failure(let error):
                let rawReport = RawReportModel(
                    url: spRequest.method.rawValue + " " + spRequest.url.absoluteString,
                    parameters: parameters,
                    errorData: response.data,
                    errorMessage: error.localizedDescription
                )
                SPDefaultFailureReporter.shared.report(error: .networkError(rawReport: rawReport))
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
