//
//  OWModalPresentationStyle+Extensions.swift
//  SpotImCore
//
//  Created by Alon Haiut on 11/09/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit

extension OWModalPresentationStyle {
    var toOSModalPresentationStyle: UIModalPresentationStyle  {
        switch self {
        case.fullScreen:
            return .fullScreen
        case.pageSheet:
            return .pageSheet
        }
    }
}
