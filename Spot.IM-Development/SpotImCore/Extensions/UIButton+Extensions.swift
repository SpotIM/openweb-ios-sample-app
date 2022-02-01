//
//  UIButton+Extensions.swift
//  Spot.IM-Core
//
//  Created by Andriy Fedin on 22/10/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit

internal extension UIButton {

    func setBackgroundColor(color: UIColor, forState: UIControl.State) {

        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        UIGraphicsGetCurrentContext()?.setFillColor(color.cgColor)
        UIGraphicsGetCurrentContext()?.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let colorImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        setBackgroundImage(colorImage, for: forState)
    }

}
