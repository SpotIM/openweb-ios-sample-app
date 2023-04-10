//
//  OWCommentPresentationData.swift
//  SpotImCore
//
//  Created by Alon Shprung on 21/03/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

enum OWCommentPresentationRepliesThreadState: Equatable {
    case collapsed
    case showFirst(numberOfReplies: Int)

    func getVisibleRepliesCount() -> Int {
        switch self {
        case .collapsed:
            return 0
        case .showFirst(let numberOfReplies):
            return numberOfReplies
        }
    }
}

class OWCommentPresentationData {
    let id: String
    var repliesThreadState: OWCommentPresentationRepliesThreadState
    var repliesIds: [String]
    let totalRepliesCount: Int
    var repliesOffset: Int
    var repliesPresentation: [OWCommentPresentationData]

    init(
        id: String,
        repliesThreadState: OWCommentPresentationRepliesThreadState = .showFirst(numberOfReplies: 2),
        repliesIds: [String] = [],
        totalRepliesCount: Int,
        repliesOffset: Int,
        repliesPresentation: [OWCommentPresentationData] = []) {

        self.id = id
        self.repliesThreadState = repliesThreadState
        self.repliesIds = repliesIds
        self.totalRepliesCount = totalRepliesCount
        self.repliesOffset = repliesOffset
        self.repliesPresentation = repliesPresentation
    }
}

extension OWCommentPresentationData: Equatable {
    static func == (lhs: OWCommentPresentationData, rhs: OWCommentPresentationData) -> Bool {
        return lhs.id == rhs.id &&
        lhs.repliesThreadState == rhs.repliesThreadState &&
        lhs.repliesIds == rhs.repliesIds &&
        lhs.repliesPresentation == rhs.repliesPresentation &&
        lhs.repliesOffset == rhs.repliesOffset
    }
}
