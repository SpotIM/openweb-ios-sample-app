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
    func prepareForNewPage(customBIData: [String:String]?)
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
    private var customBIData: [String: String]?

    func log(event: SPAnalyticsEvent, source: SPAnSource) {
        let analyticsEventInfo = analyticsInfo(from: event, source: source)
        sender?.sendEvent(with: analyticsEventInfo, postId: postId)
//        SpotIm.analyticsEventDelegate?.trackEvent(type: event.eventType, event: analyticsEventInfo)
    }
    
    func trackEvent(event: SPAnalyticsEvent, source: SPAnSource) {
        let analyticsEventInfo = analyticsInfo(from: event, source: source)
        SpotIm.analyticsEventDelegate?.trackEvent(type: event.eventType, event: analyticsEventInfo)
    }

    internal func prepareForNewPage(customBIData: [String:String]?) {
        pageViewId = UUID().uuidString
        isUserRegistered = false
        userId = nil
        totalComments = 0
        self.customBIData = customBIData
    }

    private func analyticsInfo(from event: SPAnalyticsEvent,
                               source: SPAnSource) -> SPEventInfo {

        var itemType: String?
        var targetType: String?
        var messageId: String?
        var relatedMessageId: String?
        var itemId: String?
        var reading: Int?
        var engineStatusType: String?

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
        case .engineStatus(let statusType, let engineStatusTargetType):
            engineStatusType = statusType.kebabValue
            targetType = engineStatusTargetType.kebabValue
        default:
            break
        }

        let lang = Locale.current.identifier.replacingOccurrences(of: "_", with: "-")
        var splitNames: String = ""
        for test in SPAnalyticsHolder.abActiveTests {
            splitNames += "\(test.testName):\(test.group)|"
        }
        splitNames = String(splitNames.dropLast())
        
        let publisherCustomData = customBIData

        let info = SPEventInfo(eventType: event.kebabValue,
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
                                  publisherCustomData: publisherCustomData)
        return info
    }

}
