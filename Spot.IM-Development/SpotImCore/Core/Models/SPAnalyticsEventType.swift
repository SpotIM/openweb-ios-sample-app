//
//  SPAnalyticsEventType.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 20/07/2021.
//  Copyright © 2021 Spot.IM. All rights reserved.
//

import Foundation

public enum SPAnalyticsEventType: Equatable {
    case loaded
    case viewed
    case mainViewed
    case messageContextMenuClicked
    case userProfileClicked
    case myProfileClicked
    case loginClicked
    case reading
    case loadMoreRepliesClicked
    case hideMoreRepliesClicked
    case appInit
    case appOpened
    case appClosed
    case sortByOpened
    case sortByClicked
    case createMessageClicked
    case backClicked
    case loadMoreComments
    case engineStatus
}

