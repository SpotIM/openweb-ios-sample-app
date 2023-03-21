//
//  OWCompactContentType.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 21/03/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

enum OWCompactContentType {
    case comment(type: OWCompactCommentType)
    case emptyConversation
    case closedAndEmpty
    case skelaton
}
