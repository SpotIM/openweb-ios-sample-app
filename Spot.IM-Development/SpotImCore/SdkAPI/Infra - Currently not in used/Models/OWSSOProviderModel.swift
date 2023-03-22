//
//  OWSSOProviderModel.swift
//  SpotImCore
//
//  Created by Alon Haiut on 19/03/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public struct OWSSOProviderModel {
    public let userId: String
}

#else
struct OWSSOProviderModel {
    let userId: String
}
#endif
