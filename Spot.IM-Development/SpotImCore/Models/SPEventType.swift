//
//  SPEventType.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 20/07/2021.
//  Copyright © 2021 Spot.IM. All rights reserved.
//

import Foundation

public enum SPEventType: String {
    case loaded
    case viewed
    case mainViewed
    case messageContextMenuClicked
    case messageContextMenuClosed
    case userProfileClicked
    case myProfileClicked
    case loginClicked
    case reading
    case loadMoreRepliesClicked
    case hideMoreRepliesClicked
    case commentReadMoreClicked
    case commentReadLessClicked
    case appInit
    case appOpened
    case appClosed
    case sortByOpened
    case sortByClicked
    case createMessageClicked
    case commentPostClicked
    case createMessageSuccessfully
    case backClicked
    case loadMoreComments
    case engineStatus
    case communityGuidelinesLinkClicked
    case commentShareClicked
    case commentReportClicked
    case commentDeleteClicked
    case commentRankUpButtonClicked
    case commentRankDownButtonClicked
    case commentRankUpButtonUndo
    case commentRankDownButtonUndo
    case fullConversationAdCloseClicked
    case commentEdited
}

