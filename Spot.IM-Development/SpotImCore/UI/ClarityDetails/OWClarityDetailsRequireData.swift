//
//  OWClarityDetailsRequireData.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 12/11/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public struct OWClarityDetailsRequireData: Codable {
    public let commentId: OWCommentId
    public let type: OWClarityDetailsType
}
#else
struct OWClarityDetailsRequireData: Codable {
    let commentId: OWCommentId
    let type: OWClarityDetailsType
}
#endif
