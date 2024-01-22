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
        /// Light: L3, Dark: D2
        case separatorColor1
        /// Light: L2, Dark: D2
        case separatorColor2
        /// Light: L1, Dark: D1
        case separatorColor3
        /// Light: L2, Dark: D1
        case separatorColor4
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
        /// Light: L1, Dark: D1
        case backgroundColor3
        /// Light: G1, Dark: G2
        case backgroundColor4
        /// Light: L1ALT, Dark: D1ALT
        case backgroundColor5 // Used only in pre conversation compact style
        case backgroundColor6 // Used only in landscape screens
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
        case typingDotsColor
        case loaderColor
        /// Light: G4, Dark: DM/G4
        case errorColor

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
            case .separatorColor3:
                return OWColor(lightThemeColor: OWDesignColors.L1,
                               darkThemeColor: OWDesignColors.D1)
            case .separatorColor4:
                return OWColor(lightThemeColor: OWDesignColors.L2,
                               darkThemeColor: OWDesignColors.D1)
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
            case .textColor5:
                return OWColor(lightThemeColor: OWDesignColors.L5,
                               darkThemeColor: OWDesignColors.D4)
            case .textColor6:
                return OWColor(lightThemeColor: OWDesignColors.L4,
                               darkThemeColor: OWDesignColors.D2)
            case .textColor7:
                return OWColor(lightThemeColor: OWDesignColors.G5,
                               darkThemeColor: OWDesignColors.DMG5)
            case .backgroundColor1:
                return OWColor(lightThemeColor: OWDesignColors.L1.withAlphaComponent(0.03),
                               darkThemeColor: OWDesignColors.D1.withAlphaComponent(0.1))
            case .backgroundColor2:
                return OWColor(lightThemeColor: OWDesignColors.G1,
                               darkThemeColor: OWDesignColors.L6)
            case .backgroundColor3:
                return OWColor(lightThemeColor: OWDesignColors.L1,
                               darkThemeColor: OWDesignColors.D1)
            case .backgroundColor4:
                return OWColor(lightThemeColor: OWDesignColors.G1,
                               darkThemeColor: OWDesignColors.G2)
            case .backgroundColor5:
                return OWColor(lightThemeColor: OWDesignColors.L1ALT,
                               darkThemeColor: OWDesignColors.D1ALT)
            case .backgroundColor6:
                return OWColor(lightThemeColor: UIColor(red: 247.0/255, green: 247.0/255, blue: 248.0/255, alpha: 1.0),
                               darkThemeColor: UIColor(red: 19.0/255, green: 19.0/255, blue: 19.0/255, alpha: 1.0))
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
            case .cursorColor:
                return OWColor(lightThemeColor: OWDesignColors.L6,
                               darkThemeColor: OWDesignColors.D4)
            case .brandColor:
                return OWColor(lightThemeColor: UIColor(red: 39.0/255, green: 120.0/255, blue: 206.0/255, alpha: 1.0),
                               darkThemeColor: UIColor(red: 39.0/255, green: 120.0/255, blue: 206.0/255, alpha: 1.0))

            case .shadowColor:
                return OWColor(lightThemeColor: UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 0.49),
                               darkThemeColor: UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 0.49))

            case .typingDotsColor:
                return OWColor(lightThemeColor: OWDesignColors.G2,
                               darkThemeColor: OWDesignColors.D3)

            case .loaderColor:
                return OWColor(lightThemeColor: OWDesignColors.L2,
                               darkThemeColor: OWDesignColors.D2)

            case .errorColor:
                return OWColor(lightThemeColor: OWDesignColors.G4,
                               darkThemeColor: OWDesignColors.DMG4)
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
