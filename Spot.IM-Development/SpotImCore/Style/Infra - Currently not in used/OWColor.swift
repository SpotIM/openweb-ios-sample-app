//
//  OWColor.swift
//  SpotImCore
//
//  Created by Alon Haiut on 03/11/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit

struct OWColor {
    var lightThemeColor: UIColor
    var darkThemeColor: UIColor
    
    enum OWType: CaseIterable {
        case skeletonEncapsulateViewBackgroundColor
        case skeletonColor
        case skeletonShimmeringColor
        case foreground0Color
        case foreground1Color
        case foreground2Color
        case foreground3Color
        case background1Color
        case separatorColor
        case borderColor
        case brandColor
        
        var `default`: OWColor {
            switch self {
            case .skeletonEncapsulateViewBackgroundColor:
                return OWColor(lightThemeColor: .white,
                               darkThemeColor: UIColor(red: 63.0/255.0, green: 63.0/255.0, blue: 63.0/255.0, alpha: 1.0))
            case .skeletonColor:
                return OWColor(lightThemeColor: UIColor(red: 210.0/255.0, green: 210.0/255.0, blue: 210.0/255.0, alpha: 1.0),
                               darkThemeColor: UIColor(red: 93.0/255.0, green: 93.0/255.0, blue: 93.0/255.0, alpha: 1.0))
            case .skeletonShimmeringColor:
                return OWColor(lightThemeColor: UIColor(red: 235.0/255.0, green: 235.0/255.0, blue: 235.0/255.0, alpha: 1.0),
                               darkThemeColor: UIColor(red: 110.0/255.0, green: 110.0/255.0, blue: 110.0/255.0, alpha: 1.0))
            case .foreground0Color:
                return OWColor(lightThemeColor: UIColor(red: 35.0/255.0, green: 35.0/255.0, blue: 35.0/255.0, alpha: 1.0),
                               darkThemeColor: UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0))
            case .foreground1Color:
                return OWColor(lightThemeColor: UIColor(red: 55.0/255.0, green: 62.0/255.0, blue: 68.0/255.0, alpha: 1.0),
                               darkThemeColor: UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0))
            case .foreground2Color:
                return OWColor(lightThemeColor: UIColor(red: 168.0/255.0, green: 171.0/255.0, blue: 174.0/255.0, alpha: 1.0),
                               darkThemeColor: UIColor(red: 182.0/255.0, green: 185.0/255.0, blue: 187.0/255.0, alpha: 1.0))
            case .foreground3Color:
                return OWColor(lightThemeColor: UIColor(red: 123.0/255.0, green: 127.0/255.0, blue: 131.0/255.0, alpha: 1.0),
                               darkThemeColor: UIColor(red: 182.0/255.0, green: 185.0/255.0, blue: 187.0/255.0, alpha: 1.0))
            case .background1Color:
                return OWColor(lightThemeColor: UIColor.white,
                               darkThemeColor: UIColor.white.withAlphaComponent(0.15))
            case .separatorColor:
                return OWColor(lightThemeColor: UIColor(red: 240.0/255.0, green: 241.0/255.0, blue: 241.0/255.0, alpha: 1.0),
                               darkThemeColor: UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 0.15))
            case .borderColor:
                return OWColor(lightThemeColor: UIColor(red: 212.0/255.0, green: 214.0/255.0, blue: 215.0/255.0, alpha: 1.0),
                               darkThemeColor: UIColor.clear)
            case .brandColor:
                return OWColor(lightThemeColor: .black, darkThemeColor: .black)
            }
        }
    }
    
    init(lightThemeColor: UIColor, darkThemeColor: UIColor) {
        self.lightThemeColor = lightThemeColor
        self.darkThemeColor = darkThemeColor
    }
}

extension OWColor {
    func color(forThemeStyle style: OWThemeStyle) -> UIColor {
        switch style {
        case .light:
            return lightThemeColor
        case .dark:
            return darkThemeColor
        }
    }
    
    mutating func setColor(_ color: UIColor, forThemeStyle style: OWThemeStyle) {
        switch style {
        case .light:
            setLightThemeColor(color)
        case .dark:
            setDarkThemeColor(color)
        }
    }
    
    fileprivate mutating func setLightThemeColor(_ color: UIColor) {
        lightThemeColor = color
    }
    
    fileprivate mutating func setDarkThemeColor(_ color: UIColor) {
        darkThemeColor = color
    }
}
