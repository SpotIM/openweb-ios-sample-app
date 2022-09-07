//
//  OWError.swift
//  SpotImCore
//
//  Created by Alon Haiut on 05/09/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public enum OWError: Error {
    public var description: String {
        return ""
    }
}
#else
enum OWError: Error {
    var description: String {
        return ""
    }
}
#endif
