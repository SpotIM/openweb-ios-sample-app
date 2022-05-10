//
//  DLog.swift
//  Spot-IM.Development
//
//  Created by Alon Haiut on 10/05/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

// Until we will have a propper logger in the SampleApp, let's use this DLog function instead of print

func DLog(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    #if DEBUG
    var newItems = items
    newItems.insert("OpenWebSampleAPP:", at: 0)
    print(newItems, separator: separator, terminator: terminator)
    #endif
}
