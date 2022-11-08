//
//  OWColorPalette.swift
//  SpotImCore
//
//  Created by Alon Haiut on 03/11/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit

protocol OWColorPaletteProtocol {
    func color(type: OWColor.OWType, themeStyle: OWThemeStyle) -> UIColor
}

protocol OWColorPaletteConfigurable {
    func setColor(_ color: UIColor, forType type: OWColor.OWType, forThemeStyle themeStyle: OWThemeStyle)
}

class OWColorPalette: OWColorPaletteProtocol, OWColorPaletteConfigurable {
    var colors = [OWColor.OWType: OWColor]()
    
    static let shared: OWColorPaletteProtocol & OWColorPaletteConfigurable = OWColorPalette()
    
    private init() {
        // Initialize default colors
        for type in OWColor.OWType.allCases {
            colors[type] = type.default
        }
    }
    
    func color(type: OWColor.OWType, themeStyle: OWThemeStyle) -> UIColor {
        guard let color = colors[type] else {
            // We should never get here. I chose to work with non-optional so as a default value we will return "clear"
            return .clear
        }
        
        return color.color(forThemeStyle: themeStyle)
    }
    
    func setColor(_ color: UIColor, forType type: OWColor.OWType, forThemeStyle themeStyle: OWThemeStyle) {
        guard var encapsulateColor = colors[type] else { return }
        encapsulateColor.setColor(color, forThemeStyle: themeStyle)
        colors[type] = encapsulateColor // We are working with structs here, so we need to re set the encapsulated color for this key
    }
}
