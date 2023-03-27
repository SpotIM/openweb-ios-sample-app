//
//  OWSSOStartModel.swift
//  SpotImCore
//
//  Created by Alon Haiut on 19/03/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public struct OWSSOStartModel {
    public let codeA: String
}

#else
struct OWSSOStartModel {
    let codeA: String
}
#endif
