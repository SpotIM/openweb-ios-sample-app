//
//  ColorPalette.swift
//  Spot-IM.Development
//
//  Created by Alon Haiut on 10/05/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit

// Internal colors inside the SampleApp.
// Should be changed once we have a design for the internal app which will eventually become public, but for now some nice colors

protocol ColorPaletteProtocol {
    func color(type: ColorModel.ColorType, themeStyle: ThemeStyle) -> UIColor
    func color(type: ColorModel.ColorType) -> UIColor
}

class ColorPalette: ColorPaletteProtocol {
    var colors = [ColorModel.ColorType: ColorModel]()
    
    static let shared: ColorPaletteProtocol = ColorPalette()
    
    private init() {
        // Initialize default colors
        for type in ColorModel.ColorType.allCases {
            colors[type] = type.default
        }
    }
    
    func color(type: ColorModel.ColorType) -> UIColor {
        return color(type: type, themeStyle: .light)
    }
    
    func color(type: ColorModel.ColorType, themeStyle: ThemeStyle) -> UIColor {
        guard let color = colors[type] else {
            // We should never get here. I chose to work with non-optional so as a default value we will return "clear"
            return .clear
        }
        
        return color.color(forThemeStyle: themeStyle)
    }
}
