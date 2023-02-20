//
//  UIImage+SPExtensions.swift
//  Spot.IM-Core
//
//  Created by Andriy Fedin on 25/06/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit

internal typealias ImageName = String

internal extension UIImage {

    /// Load an image from Spot.IM bundle. The image is loaded for current interface style (light or dark).
    /// Dark images should have "-dark" postfix in the Asset catalog.
    /// - Parameter spNamed: image name in the bundle.
    /// - Parameter supportDarkMode: default is false to prevent crashes if the developer did not provide an image for dark mode.
    convenience init?(spNamed: ImageName, supportDarkMode: Bool = false) {
        var imageName = spNamed

        if (supportDarkMode && SPUserInterfaceStyle.isDarkMode) {
            imageName = spNamed.dark
        }

        self.init(named: imageName, in: Bundle.openWeb, compatibleWith: nil)
    }
}

fileprivate extension ImageName {
    var dark: String {
        appending("-dark")
    }
}
