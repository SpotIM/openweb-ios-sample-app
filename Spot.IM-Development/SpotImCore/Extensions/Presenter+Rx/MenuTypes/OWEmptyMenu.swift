//
//  OWEmptyMenu.swift
//  SpotImCore
//
//  Created by Alon Shprung on 04/06/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

enum OWEmptyMenu: String, OWMenuTypeProtocol {
    var identifier: String {
        return self.rawValue
    }

    case ok
}
