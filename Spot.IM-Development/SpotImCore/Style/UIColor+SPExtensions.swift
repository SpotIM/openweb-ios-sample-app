//
//  UIColor+SPExtensions.swift
//  Spot.IM-Core
//
//  Created by Andriy Fedin on 11/07/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit

internal extension UIColor {
    // for development
    static let lightGreen = #colorLiteral(red: 0.761280286, green: 0.8862745166, blue: 0.6774430323, alpha: 1)
    static let lightBlue = #colorLiteral(red: 0.7590701394, green: 0.96344834, blue: 0.9764705896, alpha: 1)
    static let lighterPink = #colorLiteral(red: 1, green: 0.9147674944, blue: 0.8733279043, alpha: 1)
    static let lightPink = #colorLiteral(red: 1, green: 0.7809498291, blue: 0.9853027483, alpha: 1)

    // from design
    static let darkSkyBlue = #colorLiteral(red: 0.5490196078, green: 0.7450980392, blue: 0.8392156863, alpha: 1)     // #8CBED6
    static let charcoalGrey = #colorLiteral(red: 0.2156862745, green: 0.2431372549, blue: 0.2666666667, alpha: 1)    // #373E44 aka Dark Grey
    static let mineShaft = #colorLiteral(red: 0.137254902, green: 0.137254902, blue: 0.137254902, alpha: 1)       // #232323 aka "black"
    static let mineShaft2 = #colorLiteral(red: 0.2274509804, green: 0.2274509804, blue: 0.2274509804, alpha: 1)      // #232323 aka "black"
    static let clearBlue = #colorLiteral(red: 0.1882352941, green: 0.4980392157, blue: 0.8862745098, alpha: 1)       // #307FE2
    static let iceBlue = #colorLiteral(red: 0.9411764706, green: 0.9450980392, blue: 0.9450980392, alpha: 1)         // #F0F1F1
    static let mediumGreen = #colorLiteral(red: 0.2078431373, green: 0.7215686275, blue: 0.2509803922, alpha: 1)     // #35B840
    static let steelGrey = #colorLiteral(red: 0.4823529412, green: 0.4980392157, blue: 0.5137254902, alpha: 1)       // #7B7F83
    static let coolGrey = #colorLiteral(red: 0.6588235294, green: 0.6705882353, blue: 0.6823529412, alpha: 1)        // #A8ABAE
    static let lightBlueGrey = #colorLiteral(red: 0.831372549, green: 0.8392156863, blue: 0.8431372549, alpha: 1)   // #D4D6D7
    static let paleBlue = #colorLiteral(red: 0.8509803922, green: 0.9137254902, blue: 0.9333333333, alpha: 1)        // #D9E9EE
    static let marineBlue = #colorLiteral(red: 0.003921568627, green: 0.2, blue: 0.4, alpha: 1)      // #013366
    static let marineBlue2 = #colorLiteral(red: 0.003921568627, green: 0.2, blue: 0.4, alpha: 1)     // #00245a
    static let cloudyBlue = #colorLiteral(red: 0.7647058824, green: 0.7725490196, blue: 0.7803921569, alpha: 1)      // #C3C5C7
    static let almostWhite = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)     // #F7F7F7
    static let lightGreyBlue = #colorLiteral(red: 0.7137254902, green: 0.7254901961, blue: 0.7333333333, alpha: 1)   // #B6B9BB
    static let almostBlack = #colorLiteral(red: 0.137254902, green: 0.137254902, blue: 0.137254902, alpha: 1)     // #353535
    static let grayishBrown = #colorLiteral(red: 0.4549019608, green: 0.4549019608, blue: 0.4549019608, alpha: 1)    // #747474
    static let openWebBrandColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1) // #000000 Full black

    private static var defaultBrandColor: UIColor {
        UIColor.openWebBrandColor
    }

    static var brandColor: UIColor {
        UIColor.color(with: SPConfigsDataSource.appConfig?.initialization?.brandColor) ?? UIColor.defaultBrandColor
    }

    static var spBackground0: UIColor {
        SPUserInterfaceStyle.isDarkMode ? SPClientSettings.darkModeBackgroundColor : white
    }
    static var spBackground1: UIColor {
        SPUserInterfaceStyle.isDarkMode ? white.withAlphaComponent(0.15) : white
    }

    static var spAvatarBG: UIColor {
        SPUserInterfaceStyle.isDarkMode ? black : paleBlue
     }

    static var spInactiveButtonBG: UIColor {
        SPUserInterfaceStyle.isDarkMode ? mineShaft2 : cloudyBlue
    }

    static var spForeground0: UIColor { SPUserInterfaceStyle.isDarkMode ? almostWhite : almostBlack }
    static var spForeground1: UIColor { SPUserInterfaceStyle.isDarkMode ? almostWhite : charcoalGrey }
    static var spForeground2: UIColor { SPUserInterfaceStyle.isDarkMode ? lightGreyBlue : coolGrey }
    static var spForeground3: UIColor { SPUserInterfaceStyle.isDarkMode ? lightGreyBlue : steelGrey }
    static var spForeground4: UIColor { SPUserInterfaceStyle.isDarkMode ? almostWhite : steelGrey }

    static var buttonTitle: UIColor { SPUserInterfaceStyle.isDarkMode ? lightBlueGrey : steelGrey }

    static var spBorder: UIColor {
        SPUserInterfaceStyle.isDarkMode ? clear : lightBlueGrey
    }

    static var spSeparator: UIColor {
        SPUserInterfaceStyle.isDarkMode ? mineShaft2 : iceBlue
    }

    static var spSeparator2: UIColor {
        SPUserInterfaceStyle.isDarkMode ? white.withAlphaComponent(0.15) : iceBlue
    }

    static var spSeparator3: UIColor {
        SPUserInterfaceStyle.isDarkMode ? steelGrey : white.withAlphaComponent(0.1)
    }

    static var spSeparator4: UIColor {
        SPUserInterfaceStyle.isDarkMode ? spBackground0.darkerBy60Percent : iceBlue
    }

    static var spSeparator5: UIColor {
        SPUserInterfaceStyle.isDarkMode ? mineShaft2 : white.withAlphaComponent(0.1)
    }

    static var commentStatusIndicatorText: UIColor {
        SPUserInterfaceStyle.isDarkMode ? .coolGrey : .steelGrey
    }

    static var commentStatusIndicatorBackground: UIColor {
        SPUserInterfaceStyle.isDarkMode ? white.withAlphaComponent(0.15) : .iceBlue
    }

    static var commentLabelBackgroundOpacity: CGFloat {
        SPUserInterfaceStyle.isDarkMode ? 0.2 : 0.1
    }

    static var commentLabelSelectedBackgroundOpacity: CGFloat {
        SPUserInterfaceStyle.isDarkMode ? 0.7 : 1
    }

    static var commentLabelBorderOpacity: CGFloat {
        SPUserInterfaceStyle.isDarkMode ? 0.7 : 0.4
    }

    private var darkerBy60Percent: UIColor {
        return darkerColor(by: 0.4, resultAlpha: 1)
    }

    private func darkerColor(by percent: CGFloat, resultAlpha alpha: CGFloat) -> UIColor {
        var h: CGFloat = 0, s: CGFloat = 0
        var b: CGFloat = 0, a: CGFloat = 0

        guard getHue(&h, saturation: &s, brightness: &b, alpha: &a)
            else {return self}

        return UIColor(hue: h,
                       saturation: s,
                       brightness: b * percent,
                       alpha: alpha == -1 ? a : alpha)
    }
}
