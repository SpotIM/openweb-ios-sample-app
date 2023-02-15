//
//  NavigationController+Appearance.swift
//  Spot.IM-Core
//
//  Created by Eugene on 8/8/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit

extension UINavigationBar {

    func applyLightAppearance(with barColor: UIColor? = nil) {
        shadowImage = UIImage()
        isTranslucent = false
        tintColor = .charcoalGrey
        titleTextAttributes = [
            NSAttributedString.Key.font: UIFont.preferred(style: .medium, of: 20.0),
            NSAttributedString.Key.foregroundColor: UIColor.charcoalGrey
        ]
        barTintColor = barColor ?? .almostWhite
        backgroundColor = barColor ?? .almostWhite
        let image = UIImage(spNamed: "defaultBackButtonIcon", supportDarkMode: true)
        backIndicatorImage = image
        backIndicatorTransitionMaskImage = image
    }

    func applyDarkAppearance(with barColor: UIColor? = nil) {
        shadowImage = UIImage()
        isTranslucent = false
        tintColor = .white
        titleTextAttributes = [
            NSAttributedString.Key.font: UIFont.preferred(style: .medium, of: 20.0),
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]
        barTintColor = barColor ?? .marineBlue
        backgroundColor = barColor ?? .marineBlue
        let image = UIImage(spNamed: "darkModeBackButtonIcon", supportDarkMode: true)
        backIndicatorImage = image
        backIndicatorTransitionMaskImage = image
    }
}
