//
//  OWCommentThreadSettingsProtocol.swift
//  SpotImCore
//
//  Created by Alon Shprung on 27/02/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public protocol OWCommentThreadSettingsProtocol {
    var performActionType: OWCommentThreadPerformActionType { get }
}
#else
protocol OWCommentThreadSettingsProtocol {
    var performActionType: OWCommentThreadPerformActionType { get }
}
#endif
