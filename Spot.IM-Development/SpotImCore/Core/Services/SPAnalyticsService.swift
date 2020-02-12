//
//  SPAnalyticsService.swift
//  Spot.IM-Core
//
//  Created by Andriy Fedin on 22/08/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation
import AdSupport

internal protocol SPAnalyticsService {

    var sender: SPAnalyticsSender? { get set }

    var isUserRegistered: Bool { get set }
    var userId: String? { get set }
    var totalComments: Int? { get set }
    var domain: String? { get set }
    var pageViewId: String { get }
    var lastRecordedMainViewedPageViewId: String { get set }
    var postId: String? { get set }
    func prepareForNewPage()
    func log(event: SPAnalyticsEvent, source: SPAnSource)
}

internal final class SPAnalyticsHolder {
    static var abActiveTests: [SPABData] = []
    
    internal static var `default`: SPAnalyticsService = {
        let service = SPDefaultAnalyticsService()
        service.sender = SPDefaultAnalyticsSender(apiManager: ApiManager())
        return service
    }()

    private init() {}
}

internal final class SPDefaultAnalyticsService: SPAnalyticsService {

    internal var sender: SPAnalyticsSender?

    // common event params
    internal var isUserRegistered = false
    internal var userId: String?
    internal var totalComments: Int?
    internal var domain: String?
    private (set) var pageViewId: String = UUID().uuidString
    public var lastRecordedMainViewedPageViewId: String = ""
    internal var postId: String?
    
    private var didLogLoadedConversation = false

    func log(event: SPAnalyticsEvent, source: SPAnSource) {
        guard shouldLog(event: event, source: source) else { return }
        if event == .viewed, source == .conversation {
            didLogLoadedConversation = true
        }

        sender?.sendEvent(with: analyticsInfo(from: event, source: source), postId: postId)
    }

    internal func prepareForNewPage() {
        pageViewId = UUID().uuidString
        didLogLoadedConversation = false
        isUserRegistered = false
        userId = nil
        totalComments = 0
    }

    private func shouldLog(event: SPAnalyticsEvent, source: SPAnSource) -> Bool {
        if event == .viewed, source == .conversation, didLogLoadedConversation {
            return false
        }
        return true
    }

    private func analyticsInfo(from event: SPAnalyticsEvent,
                               source: SPAnSource) -> SPAnalyticsDTO {

        var itemType: String?
        var targetType: String?
        var messageId: String?
        var relatedMessageId: String?
        var itemId: String?
        var reading: Int?
        var engineStatusType: String?
        let idfa: String = ASIdentifierManager.shared().advertisingIdentifier.uuidString

        switch event {
        case .loginClicked(let newTargetType):
            itemType = SPAnItemType.login.kebabValue
            targetType = newTargetType.kebabValue
        case .reading(let seconds):
            itemType = SPAnItemType.main.kebabValue
            reading = seconds
        case .loadMoreRepliesClicked(let newMessageId, let newRelatedMessageId):
            itemType = SPAnItemType.main.kebabValue
            messageId = newMessageId
            relatedMessageId = newRelatedMessageId
        case .hideMoreRepliesClicked(let newMessageId, let newRelatedMessageId):
            itemType = SPAnItemType.main.kebabValue
            messageId = newMessageId
            relatedMessageId = newRelatedMessageId
        case .createMessageClicked(let newItemType, let newTargetType, let newRelatedMessageId):
            itemType = newItemType.kebabValue
            targetType = newTargetType.kebabValue
            relatedMessageId = newRelatedMessageId
        case .userProfileClicked(let newMessageId, let authorId):
            messageId = newMessageId
            itemId = authorId
        case .sortByClicked(let sortMode):
            targetType = sortMode.kebabValue
        case .engineStatus(let statusType):
            engineStatusType = statusType.kebabValue
        default:
            break
        }

        let lang = Locale.current.identifier.replacingOccurrences(of: "_", with: "-")
        var splitNames: String = ""
        for test in SPAnalyticsHolder.abActiveTests {
            splitNames += "\(test.testName):\(test.group)|"
        }
        splitNames = String(splitNames.dropLast())
        
        let info = SPAnalyticsDTO(eventType: event.kebabValue,
                                  source: source.kebabValue,
                                  isRegistered: isUserRegistered,
                                  splitName: splitNames,
                                  itemType: itemType,
                                  targetType: targetType,
                                  segment: nil, // TODO: (Fedin) remove hardcode
                                  lang: lang,
                                  domain: domain,
                                  userId: userId,
                                  messageId: messageId,
                                  relatedMessageId: relatedMessageId,
                                  readingSeconds: reading,
                                  itemId: itemId,
                                  totalComments: totalComments,
                                  engineStatusType: engineStatusType,
                                  idfa: idfa)
        return info
    }

}
