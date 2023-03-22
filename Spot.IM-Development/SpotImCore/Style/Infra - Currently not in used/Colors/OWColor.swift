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
        case borderColor1
        case borderColor2
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
                return OWColor(lightThemeColor: DesignSystemColors.L3,
                               darkThemeColor: DesignSystemColors.D2)
            case .separatorColor2:
                return OWColor(lightThemeColor: DesignSystemColors.L2,
                               darkThemeColor: DesignSystemColors.D2)
            case .textColor1:
                return OWColor(lightThemeColor: DesignSystemColors.L6,
                               darkThemeColor: DesignSystemColors.G1)
            case .textColor2:
                return OWColor(lightThemeColor: DesignSystemColors.L5,
                               darkThemeColor: DesignSystemColors.D3)
            case .textColor3:
                return OWColor(lightThemeColor: DesignSystemColors.L6,
                               darkThemeColor: DesignSystemColors.D4)
            case .textColor4:
                return OWColor(lightThemeColor: DesignSystemColors.G2,
                               darkThemeColor: DesignSystemColors.G1)
            case .backgroundColor1:
                return OWColor(lightThemeColor: DesignSystemColors.L1.withAlphaComponent(0.03),
                               darkThemeColor: DesignSystemColors.D1.withAlphaComponent(0.1))
            case .backgroundColor2:
                return OWColor(lightThemeColor: DesignSystemColors.G1,
                               darkThemeColor: DesignSystemColors.L6)
            case .backgroundColor3:
                return OWColor(lightThemeColor: DesignSystemColors.L1,
                               darkThemeColor: UIColor(red: 31.0/255.0, green: 31.0/255.0, blue: 31.0/255.0, alpha: 1.0))
            case .borderColor1:
                return OWColor(lightThemeColor: DesignSystemColors.L1,
                               darkThemeColor: DesignSystemColors.D1)
            case .borderColor2:
                return OWColor(lightThemeColor: DesignSystemColors.L2,
                               darkThemeColor: DesignSystemColors.D1)
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

// TODO: New file ?
struct DesignSystemColors {
    static let G1: UIColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
    static let G2: UIColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1)
    static let G3: UIColor = UIColor(red: 53/255, green: 185/255, blue: 64/255, alpha: 1)
    static let G4: UIColor = UIColor(red: 219/255, green: 55/255, blue: 55/255, alpha: 1)
    static let G5: UIColor = UIColor(red: 57/255, green: 104/255, blue: 255/255, alpha: 1)
    static let G6: UIColor = UIColor(red: 250/255, green: 187/255, blue: 9/255, alpha: 1)
    static let L1: UIColor = UIColor(red: 7/255, green: 7/255, blue: 7/255, alpha: 0.05)
    static let L2: UIColor = UIColor(red: 7/255, green: 7/255, blue: 7/255, alpha: 0.10)
    static let L3: UIColor = UIColor(red: 7/255, green: 7/255, blue: 7/255, alpha: 0.20)
    static let L4: UIColor = UIColor(red: 7/255, green: 7/255, blue: 7/255, alpha: 0.30)
    static let L5: UIColor = UIColor(red: 7/255, green: 7/255, blue: 7/255, alpha: 0.65)
    static let L6: UIColor = UIColor(red: 7/255, green: 7/255, blue: 7/255, alpha: 1)
    static let D1: UIColor = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 0.20)
    static let D2: UIColor = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 0.30)
    static let D3: UIColor = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 0.65)
    static let D4: UIColor = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1)
}
