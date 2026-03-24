//
//  CodableColor.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 24/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI
import OpenWebSDK

struct CodableColor: Codable, Equatable {
    var lightHex: String
    var darkHex: String

    var owColor: OWColor {
        OWColor(lightColor: UIColor(Color(hex: lightHex)), darkColor: UIColor(Color(hex: darkHex)))
    }

    init(light: Color = .black, dark: Color = .black) {
        lightHex = light.hexString
        darkHex = dark.hexString
    }
}
