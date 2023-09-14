//
//  OWRealTime.swift
//  SpotImCore
//
//  Created by Revital Pisman on 07/08/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

struct OWRealTime: Decodable {
    let data: OWRealTimeData?
    let nextFetch: Int
    let timestamp: Int
}
