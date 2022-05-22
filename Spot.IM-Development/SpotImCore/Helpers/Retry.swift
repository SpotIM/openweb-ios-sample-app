//
//  Retry.swift
//  SpotImCore
//
//  Created by Alon Haiut on 22/05/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

enum Retry<T> {
    case value(T)
    case retry
}
