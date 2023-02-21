//
//  UIColor+Hex.swift
//  Spot.IM-Core
//
//  Created by Eugene on 8/9/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit

extension UIColor {

    static func color(with configuration: String?) -> UIColor? {
        guard let hex = configuration else { return nil }

        var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if cString.hasPrefix("#") {
            cString.remove(at: cString.startIndex)
        }

        if cString.count != 6 {
            return nil
        }

        var rgbValue: UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }

    static func color(rgb: String?) -> UIColor? {
        guard let rgb = rgb else {return nil}

        let seperatedRgb = rgb.components(separatedBy: ",").map({ Int($0.trimmingCharacters(in: .whitespacesAndNewlines)) })

        guard seperatedRgb.count >= 3, let rgbRedValue = seperatedRgb[0], let rgbGreenValue = seperatedRgb[1], let rgbBlueValue = seperatedRgb[2]
        else {return nil}

        return UIColor(
            red: CGFloat(rgbRedValue) / 255.0,
            green: CGFloat(rgbGreenValue) / 255.0,
            blue: CGFloat(rgbBlueValue) / 255.0,
            alpha: 1.0
        )
    }
}
