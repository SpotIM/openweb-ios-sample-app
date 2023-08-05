//
//  UIStatusBarStyle+Extensions.swift
//  SpotImCore
//
//  Created by Alon Haiut on 01/08/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit

extension UIStatusBarStyle {
    init(reverseFrom themeStyle: OWThemeStyle) {
        switch themeStyle {
        case .dark:
            self = .lightContent
        case .light:
            if #available(iOS 13.0, *) {
                self = .darkContent
            } else {
                self = .default
            }
        }
    }
}
