//
//  UIView+Roundings.swift
//  Spot.IM-Core
//
//  Created by Eugene on 7/26/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit

extension UIView {

    func makeViewRound() {
        addCornerRadius(bounds.width / 2)
    }

    func addCornerRadius(_ radius: CGFloat, corners: CACornerMask = [.layerMaxXMaxYCorner,
                                                                     .layerMaxXMinYCorner,
                                                                     .layerMinXMaxYCorner,
                                                                     .layerMinXMinYCorner]) {
        layer.cornerRadius = radius
        layer.masksToBounds = true
    }

}
