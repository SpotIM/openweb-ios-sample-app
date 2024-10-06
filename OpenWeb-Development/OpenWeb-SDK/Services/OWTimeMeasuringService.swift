//
//  OWTimeMeasuringService.swift
//  OpenWebSDK
//
//  Created by Revital Pisman on 11/01/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation

protocol OWTimeMeasuringServicing {
    func startMeasure(forKey key: OWTimeMeasuringService.OWKeys)
    func endMeasure(forKey key: OWTimeMeasuringService.OWKeys) -> OWTimeMeasuringResult
    func timeMeasuringMilliseconds(forKey key: OWTimeMeasuringService.OWKeys, delayDuration: Int) -> Int
}

enum OWTimeMeasuringResult {
    case time(milliseconds: Int)
    case error(message: String)
}

class OWTimeMeasuringService: OWTimeMeasuringServicing {

    enum OWKeys {
        case conversationUIBuildingTime
        case conversationLoadingInitialComments
        case conversationLoadingMoreComments
        case conversationLoadingMoreReplies(commentId: OWCommentId)
        case commentThreadLoadingMoreReplies(commentId: OWCommentId)
        case commentThreadLoadingInitialComments
        case commentCreationPost

        case preConversationLoadingInitialComments
    }

    private var startTimeDictionary = [String: CFAbsoluteTime]()

    func startMeasure(forKey key: OWTimeMeasuringService.OWKeys) {
        startTimeDictionary[key.value] = CFAbsoluteTimeGetCurrent()
    }

    func endMeasure(forKey key: OWTimeMeasuringService.OWKeys) -> OWTimeMeasuringResult {
        guard let startTime = startTimeDictionary[key.value] else {
            return .error(message: "Error: start measure must be called before end measure")
        }

        let endTime = CFAbsoluteTimeGetCurrent()
        let timeElapsed = (endTime - startTime) * 1000

        startTimeDictionary.removeValue(forKey: key.value)

        return .time(milliseconds: Int(timeElapsed))
    }

    func timeMeasuringMilliseconds(forKey key: OWTimeMeasuringService.OWKeys, delayDuration: Int) -> Int {
        let measureResult = self.endMeasure(forKey: key)
        if case OWTimeMeasuringResult.time(let milliseconds) = measureResult,
           milliseconds < delayDuration {
            return milliseconds
        }
        // If end was called before start for some reason, returning 0 milliseconds here
        return 0
    }
}

private extension OWTimeMeasuringService.OWKeys {
    static func == (lhs: OWTimeMeasuringService.OWKeys, rhs: OWTimeMeasuringService.OWKeys) -> Bool {
        switch (lhs, rhs) {
        case (.conversationUIBuildingTime, .conversationUIBuildingTime):
            return true
        case (.conversationLoadingInitialComments, .conversationLoadingInitialComments):
            return true
        case (.conversationLoadingMoreComments, .conversationLoadingMoreComments):
            return true
        case (let .conversationLoadingMoreReplies(lhsId), let .conversationLoadingMoreReplies(rhsId)):
            return lhsId == rhsId
        case (.commentThreadLoadingInitialComments, .commentThreadLoadingInitialComments):
            return true
        case (let .commentThreadLoadingMoreReplies(lhsId), let .commentThreadLoadingMoreReplies(rhsId)):
            return lhsId == rhsId
        case (.preConversationLoadingInitialComments, .preConversationLoadingInitialComments):
            return true
        default:
            return false
        }
    }

    var value: String {
        switch self {
        case .conversationUIBuildingTime:
            return "conversationUIBuildingTime"
        case .conversationLoadingInitialComments:
            return "conversationLoadingInitialComments"
        case .conversationLoadingMoreComments:
            return "conversationLoadingMoreComments"
        case .conversationLoadingMoreReplies(let commentId):
            return "conversationLoadingMoreReplies_\(commentId)"
        case .commentThreadLoadingInitialComments:
            return "commentThreadLoadingInitialComments"
        case .commentThreadLoadingMoreReplies(commentId: let commentId):
            return "commentThreadLoadingMoreReplies_\(commentId)"
        case .preConversationLoadingInitialComments:
            return "preConversationLoadingInitialComments"
        case .commentCreationPost:
            return "commentCreationPost"
        }
    }

    var description: String {
        switch self {
        case .conversationUIBuildingTime:
            return "Time for building initial UI in conversation view"
        case .conversationLoadingInitialComments:
            return "Time for loading initial comments in conversation view"
        case .conversationLoadingMoreComments:
            return "Time for loading more comments in conversation view"
        case .conversationLoadingMoreReplies:
            return "Time for loading more replies in conversation view"
        case .commentThreadLoadingInitialComments:
            return "Time for loading initial comments in comment thread view"
        case .commentThreadLoadingMoreReplies:
            return "Time for loading more replies in comment thread view"
        case .preConversationLoadingInitialComments:
            return "Time for loading initial comments in pre conversation view"
        case .commentCreationPost:
            return "Time for posting new comment in comment creation view"
        }
    }
}
