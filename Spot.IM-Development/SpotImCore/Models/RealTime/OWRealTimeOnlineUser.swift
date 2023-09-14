//
//  OWRealTimeOnlineUser.swift
//  SpotImCore
//
//  Created by Revital Pisman on 06/08/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

struct OWRealTimeOnlineUser: Decodable {
    let userId: String
    let displayName: String
    let userName: String
    let registered: Bool
    let imageId: String
}
