//
//  SampleAppCommentCreationType.swift
//  OpenWeb-Development
//
//  Created by Yonat Sharon on 27/01/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import Foundation

enum SampleAppCommentCreationType: Int, Codable, CaseIterable {
    case new = 0
    case reply = 1
    case edit = 2

    var title: String {
        switch self {
        case .new:
            return NSLocalizedString("CommentCreationTypeNew", comment: "")
        case .reply:
            return NSLocalizedString("CommentCreationTypeReply", comment: "")
        case .edit:
            return NSLocalizedString("CommentCreationTypeEdit", comment: "")
        }
    }

    static var `default`: SampleAppCommentCreationType {
        return .new
    }
}
