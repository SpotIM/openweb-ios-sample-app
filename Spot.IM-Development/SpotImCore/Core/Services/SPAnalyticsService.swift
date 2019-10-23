//
//  SPAnalyticsService.swift
//  Spot.IM-Core
//
//  Created by Andriy Fedin on 22/08/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation
import GoogleMobileAds

internal protocol SPAnalyticsService {

    var sender: SPAnalyticsSender? { get set }

    var isUserRegistered: Bool { get set }
    var userId: String? { get set }
    var totalComments: Int? { get set }
    var domain: String? { get set }
    var pageViewId: String { get }

    func prepareForNewPage()
    func log(event: SPAnalyticsEvent, source: SPAnSource)
}

internal final class SPAnalyticsHolder {
    
    internal static var `default`: SPAnalyticsService = {
        let service = SPDefaultAnalyticsService()
        service.sender = SPDefaultAnalyticsSender()
        return service
    }()
    
    internal static func setup() {
        self.default = SPDefaultAnalyticsService()
        self.default.sender = SPDefaultAnalyticsSender()
    }
}

internal final class SPDefaultAnalyticsService: SPAnalyticsService {

    internal var sender: SPAnalyticsSender?

    // common event params
    internal var isUserRegistered = false
    internal var userId: String?
    internal var totalComments: Int?
    internal var domain: String?
    private (set) var pageViewId: String = UUID().uuidString

    private var didLogLoadedConversation = false

    func log(event: SPAnalyticsEvent, source: SPAnSource) {
        guard shouldLog(event: event, source: source) else { return }
        if event == .viewed, source == .conversation {
            didLogLoadedConversation = true
        }

        sender?.sendEvent(with: analyticsInfo(from: event, source: source))
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
        default:
            break
        }

        let lang = Locale.current.identifier.replacingOccurrences(of: "_", with: "-")

        let info = SPAnalyticsDTO(eventType: event.kebabValue,
                                  source: source.kebabValue,
                                  isRegistered: isUserRegistered,
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
                                  totalComments: totalComments)
        return info
    }

}
