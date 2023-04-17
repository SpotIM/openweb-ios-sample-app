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
        case foreground2Color
        case separatorColor1
        case separatorColor2
        case textColor1
        case textColor2
        case textColor3
        case textColor4
        case backgroundColor1
        case backgroundColor2
        case backgroundColor3
        case backgroundColor4
        case borderColor1
        case borderColor2
        case borderColor3
        case green
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
            case .foreground2Color:
                return OWColor(lightThemeColor: UIColor(red: 168.0/255.0, green: 171.0/255.0, blue: 174.0/255.0, alpha: 1.0),
                               darkThemeColor: UIColor(red: 182.0/255.0, green: 185.0/255.0, blue: 187.0/255.0, alpha: 1.0))
            case .separatorColor1:
                return OWColor(lightThemeColor: OWDesignColors.L3,
                               darkThemeColor: OWDesignColors.D2)
            case .separatorColor2:
                return OWColor(lightThemeColor: OWDesignColors.L2,
                               darkThemeColor: OWDesignColors.D2)
            case .textColor1:
                return OWColor(lightThemeColor: OWDesignColors.L6,
                               darkThemeColor: OWDesignColors.G1)
            case .textColor2:
                return OWColor(lightThemeColor: OWDesignColors.L5,
                               darkThemeColor: OWDesignColors.D3)
            case .textColor3:
                return OWColor(lightThemeColor: OWDesignColors.L6,
                               darkThemeColor: OWDesignColors.D4)
            case .textColor4:
                return OWColor(lightThemeColor: OWDesignColors.G2,
                               darkThemeColor: OWDesignColors.G1)
            case .backgroundColor1:
                return OWColor(lightThemeColor: OWDesignColors.L1.withAlphaComponent(0.03),
                               darkThemeColor: OWDesignColors.D1.withAlphaComponent(0.1))
            case .backgroundColor2:
                return OWColor(lightThemeColor: OWDesignColors.G1,
                               darkThemeColor: OWDesignColors.L6)
            case .backgroundColor3:
                return OWColor(lightThemeColor: OWDesignColors.L1,
                               darkThemeColor: UIColor(red: 31.0/255.0, green: 31.0/255.0, blue: 31.0/255.0, alpha: 1.0))
            case .backgroundColor4:
                return OWColor(lightThemeColor: OWDesignColors.G1,
                               darkThemeColor: OWDesignColors.G2)
            case .borderColor1:
                return OWColor(lightThemeColor: OWDesignColors.L1,
                               darkThemeColor: OWDesignColors.D1)
            case .borderColor2:
                return OWColor(lightThemeColor: OWDesignColors.L2,
                               darkThemeColor: OWDesignColors.D1)
            case .borderColor3:
                return OWColor(lightThemeColor: OWDesignColors.D3,
                               darkThemeColor: OWDesignColors.L3)
            case .green:
                return OWColor(lightThemeColor: OWDesignColors.G3,
                               darkThemeColor: OWDesignColors.G3)
            case .brandColor:
                return OWColor(lightThemeColor: .black, darkThemeColor: .white)
            }
        }

        var shouldUpdateRxObservable: Bool {
            switch self {
            case .brandColor: return true
            default: return false
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
