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
