//
//  OWCommentThreadPerformActionType.swift
//  OpenWebSDK
//
//  Created by Alon Shprung on 22/11/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation

public enum OWCommentThreadPerformActionType: Codable {
    case none
    case changeRank(from: Int, to: Int)
    case reply
    case report
}
