//
//  UIImage+SPExtensions.swift
//  Spot.IM-Core
//
//  Created by Andriy Fedin on 25/06/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit

internal extension UIImage {

    /// Load an image from Spot.IM bundle. The image is loaded for current interface style (light or dark).
    /// Dark images should have "-dark" postfix in the Asset catalog.
    /// It's possible to override interface style by providing a value to "style" parameter.
    /// - Parameter spNamed: image name in the bundle.
    /// - Parameter style: override current style setting with this parameter.
    convenience init?(spNamed: String, for style: SPUserInterfaceStyle? = nil) {
        var imageName = spNamed

        if style != .light && SPUserInterfaceStyle.isDarkMode {
            imageName = spNamed.dark
        }

        self.init(named: imageName, in: Bundle.spot, compatibleWith: nil)
    }

}

fileprivate extension String {

    var dark: String {
        appending("-dark")
    }

}
