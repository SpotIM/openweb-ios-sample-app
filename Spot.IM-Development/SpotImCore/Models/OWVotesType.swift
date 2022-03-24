//
//  OWVotesType.swift
//  SpotImCore
//
//  Created by Alon Shprung on 03/03/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

enum OWVotesType: String, Decodable {
    case like
    case updown
    case recommend
    case heart
}
