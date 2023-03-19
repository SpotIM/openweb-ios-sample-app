//
//  OWSSOCompletionModel.swift
//  SpotImCore
//
//  Created by Alon Haiut on 19/03/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public struct OWSSOCompletionModel {
    public let userId: String
}

#else
struct OWSSOCompletionModel {
    let userId: String
}
#endif
