//
//  UIImage+SPExtensions.swift
//  OpenWebSDK
//
//  Created by Andriy Fedin on 25/06/19.
//  Copyright © 2019 OpenWeb. All rights reserved.
//

// Alon - TODO // Remove this old extension and create a better way to work with images

import UIKit

internal typealias OWImageName = String

internal extension UIImage {

    /// Load an image from OpenWeb bundle. The image is loaded for current interface style (light or dark).
    /// Dark images should have "-dark" postfix in the Asset catalog.
    /// - Parameter spNamed: image name in the bundle.
    /// - Parameter supportDarkMode: default is false to prevent crashes if the developer did not provide an image for dark mode.
    convenience init?(spNamed: OWImageName, supportDarkMode: Bool = false) {
        var imageName = spNamed

        if supportDarkMode && SPUserInterfaceStyle.isDarkMode {
            imageName = spNamed.dark
        }

        self.init(named: imageName, in: Bundle.openWeb, compatibleWith: nil)
    }
}

fileprivate extension OWImageName {
    var dark: String {
        appending("-dark")
    }
}
