//
//  UIView+Animations.swift
//  SpotImCore
//
//  Created by Rotem Itzhak on 11/12/2019.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit

extension UIView {
    func fadeTransition(_ duration: CFTimeInterval) {
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.type = .fade
        animation.duration = duration
        layer.add(animation, forKey: CATransitionType.fade.rawValue)
    }
}
