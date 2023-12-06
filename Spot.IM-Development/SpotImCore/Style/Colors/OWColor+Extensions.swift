//
//  OWColor+Extensions.swift
//  SpotImCore
//
//  Created by Alon Haiut on 03/11/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit

extension OWColor {
    enum OWType: CaseIterable {
        case skeletonColor
        case skeletonShimmeringColor
        case foreground2Color
        /// Light: L3, Dark: D2
        case separatorColor1
        /// Light: L2, Dark: D2
        case separatorColor2
        /// Light: L1, Dark: D1
        case separatorColor3
        /// Light: L6, Dark: G1
        case textColor1
        /// Light: L5, Dark: D3
        case textColor2
        /// Light: L6, Dark: D4
        case textColor3
        /// Light: G2, Dark: G1
        case textColor4
        /// Light: L5, Dark: D4
        case textColor5
        /// Light: L4, Dark: D2
        case textColor6
        /// Light: G5, Dark: DMG5
        case textColor7
        /// Light: L1.withAlphaComponent(0.03), Dark: D1.withAlphaComponent(0.1)
        case backgroundColor1
        /// Light: G1, Dark: L6
        case backgroundColor2
        /// Light: G1, Dark: G2
        case backgroundColor4
        /// Light: L1ALT, Dark: D1ALT
        case backgroundColor5 // Used only in pre conversation compact style
        /// Light: L1, Dark: D1
        case borderColor1
        /// Light: L2, Dark: D1
        case borderColor2
        /// Light: D3, Dark: L3
        case borderColor3
        /// Light: G3, Dark: G3
        case green
        /// Changes from server according to current spot id
        case brandColor
        /// Light: L6, Dark: D4
        case cursorColor
        case shadowColor
        /// Light: G2, Dark: D3
        case typingDotsColor
        /// Light: L2, Dark: D2
        case loaderColor

        var `default`: OWColor {
            switch self {
            case .skeletonColor:
                return OWColor(lightColor: UIColor(red: 210.0/255.0, green: 210.0/255.0, blue: 210.0/255.0, alpha: 1.0),
                               darkColor: UIColor(red: 93.0/255.0, green: 93.0/255.0, blue: 93.0/255.0, alpha: 1.0))
            case .skeletonShimmeringColor:
                return OWColor(lightColor: UIColor(red: 235.0/255.0, green: 235.0/255.0, blue: 235.0/255.0, alpha: 1.0),
                               darkColor: UIColor(red: 110.0/255.0, green: 110.0/255.0, blue: 110.0/255.0, alpha: 1.0))
            case .foreground2Color:
                return OWColor(lightColor: UIColor(red: 168.0/255.0, green: 171.0/255.0, blue: 174.0/255.0, alpha: 1.0),
                               darkColor: UIColor(red: 182.0/255.0, green: 185.0/255.0, blue: 187.0/255.0, alpha: 1.0))
            case .separatorColor1:
                return OWColor(lightColor: OWDesignColors.L3,
                               darkColor: OWDesignColors.D2)
            case .separatorColor2:
                return OWColor(lightColor: OWDesignColors.L2,
                               darkColor: OWDesignColors.D2)
            case .separatorColor3:
                return OWColor(lightColor: OWDesignColors.L1,
                               darkColor: OWDesignColors.D1)
            case .textColor1:
                return OWColor(lightColor: OWDesignColors.L6,
                               darkColor: OWDesignColors.G1)
            case .textColor2:
                return OWColor(lightColor: OWDesignColors.L5,
                               darkColor: OWDesignColors.D3)
            case .textColor3:
                return OWColor(lightColor: OWDesignColors.L6,
                               darkColor: OWDesignColors.D4)
            case .textColor4:
                return OWColor(lightColor: OWDesignColors.G2,
                               darkColor: OWDesignColors.G1)
            case .textColor5:
                return OWColor(lightColor: OWDesignColors.L5,
                               darkColor: OWDesignColors.D4)
            case .textColor6:
                return OWColor(lightColor: OWDesignColors.L4,
                               darkColor: OWDesignColors.D2)
            case .textColor7:
                return OWColor(lightColor: OWDesignColors.G5,
                               darkColor: OWDesignColors.DMG5)
            case .backgroundColor1:
                return OWColor(lightColor: OWDesignColors.L1.withAlphaComponent(0.03),
                               darkColor: OWDesignColors.D1.withAlphaComponent(0.1))
            case .backgroundColor2:
                return OWColor(lightColor: OWDesignColors.G1,
                               darkColor: OWDesignColors.L6)
            case .backgroundColor4:
                return OWColor(lightColor: OWDesignColors.G1,
                               darkColor: OWDesignColors.G2)
            case .backgroundColor5:
                return OWColor(lightColor: OWDesignColors.L1ALT,
                               darkColor: OWDesignColors.D1ALT)
            case .borderColor1:
                return OWColor(lightColor: OWDesignColors.L1,
                               darkColor: OWDesignColors.D1)
            case .borderColor2:
                return OWColor(lightColor: OWDesignColors.L2,
                               darkColor: OWDesignColors.D1)
            case .borderColor3:
                return OWColor(lightColor: OWDesignColors.D3,
                               darkColor: OWDesignColors.L3)
            case .green:
                return OWColor(lightColor: OWDesignColors.G3,
                               darkColor: OWDesignColors.G3)
            case .cursorColor:
                return OWColor(lightColor: OWDesignColors.L6,
                               darkColor: OWDesignColors.D4)
            case .brandColor:
                return OWColor(lightColor: UIColor(red: 39.0/255, green: 120.0/255, blue: 206.0/255, alpha: 1.0),
                               darkColor: UIColor(red: 39.0/255, green: 120.0/255, blue: 206.0/255, alpha: 1.0))

            case .shadowColor:
                return OWColor(lightColor: UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 0.49),
                               darkColor: UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 0.49))

            case .typingDotsColor:
                return OWColor(lightColor: OWDesignColors.G2,
                               darkColor: OWDesignColors.D3)

            case .loaderColor:
                return OWColor(lightColor: OWDesignColors.L2,
                               darkColor: OWDesignColors.D2)

            }
        }

        var shouldUpdateRxObservable: Bool {
            switch self {
            case .brandColor: return true
            default: return false
            }
        }
    }
}

extension OWColor {
    func color(forThemeStyle style: OWThemeStyle) -> UIColor {
        switch style {
        case .light:
            return lightColor
        case .dark:
            return lightColor
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
        lightColor = color
    }

    fileprivate mutating func setDarkThemeColor(_ color: UIColor) {
        lightColor = color
    }
}
