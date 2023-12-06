//
//  OWColor.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 06/12/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import UIKit

public struct OWColor {
    public var lightColor: UIColor
    public var darkColor: UIColor

    public init(lightColor: UIColor, darkColor: UIColor) {
        self.lightColor = lightColor
        self.darkColor = darkColor
    }
}
