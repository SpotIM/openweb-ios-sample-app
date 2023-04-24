//
//  OWCommunityQuestionsStyle.swift
//  SpotImCore
//
//  Created by Alon Haiut on 31/01/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public enum OWCommunityQuestionsStyle: Codable {
    case none
    case regular
}

#else
enum OWCommunityQuestionsStyle: Codable {
    case none
    case regular
}
#endif
