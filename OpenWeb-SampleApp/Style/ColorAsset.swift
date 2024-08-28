//
//  ColorAsset.swift
//  OpenWeb-SampleApp
//
//  Created by Alon Haiut on 26/08/2024.
//

/*
 New infrastrucutre for colors.
 Use this file once we will have design for the whole SampleApp
*/

import UIKit

enum ColorAsset {
    case L4
    case L5
    case L6
}

extension ColorAsset {
    var color: UIColor {
        switch self {
        case .L4:
            return UIColor(named: "L4")!
        case .L5:
            return UIColor(named: "L5")!
        case .L6:
            return UIColor(named: "L6")!
        }
    }
}

