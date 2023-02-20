//
//  UIFont+Extensions.swift
//  Spot.IM-Core
//
//  Created by Andriy Fedin on 11/07/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit

internal extension UIFont {

    static func preferred(style: SPFontStyle, of size: CGFloat) -> UIFont {
        if let customFontFamily = SpotIm.customFontFamily {
            return customFont(customFontFamily: customFontFamily, style: style, of: size)
        }

        return openSans(style: style, of: size)
    }

    static func customFont(customFontFamily: String, style: SPFontStyle, of size: CGFloat) -> UIFont {
        let fontName = "\(customFontFamily)-\(style.rawValue)"
        return UIFont(name: fontName, size: size) ?? openSans(style: style, of: size)
    }

    static func openSans(style: SPFontStyle, of size: CGFloat) -> UIFont {
        let openSans = name(of: .openSans, with: style)
        return UIFont(name: openSans, size: size) ?? systemFont(ofSize: size)
    }

    private static func name(of family: SPFontFamily, with style: SPFontStyle) -> String {
        return "\(family.rawValue)-\(style.rawValue)"
    }

    // load framework font in application
    static let loadAllFonts: () = {
        registerFontWith(filenameString: "OpenSans-Regular.ttf")
        registerFontWith(filenameString: "OpenSans-Light.ttf")
        registerFontWith(filenameString: "OpenSans-Medium.ttf")
        registerFontWith(filenameString: "OpenSans-Bold.ttf")
        registerFontWith(filenameString: "OpenSans-Italic.ttf")
    }()

    // MARK: - Make custom font bundle register to framework
    static func registerFontWith(filenameString: String) {
        let frameworkBundle = Bundle.openWeb
        guard
            let pathForResourceString = frameworkBundle.path(forResource: filenameString, ofType: nil)
            else { return }

        guard
            let fontData = NSData(contentsOfFile: pathForResourceString),
            let dataProvider = CGDataProvider(data: fontData)
            else { return }

        let fontRef = CGFont(dataProvider)
        var errorRef: Unmanaged<CFError>?
        if CTFontManagerRegisterGraphicsFont(fontRef!, &errorRef) == false {
            // https://stackoverflow.com/a/43368507/583425 - memory leak fix
            let message = errorRef.debugDescription
            errorRef?.release()
            let logText = "Failed to register font - error: \(message)"
                + "\nRegister graphics font failed"
                + "\nThis font may have already been registered in the main bundle."
            OWSharedServicesProvider.shared.logger().log(level: .error, logText)
        }
    }
}

internal enum SPFontStyle: String {
    case regular = "Regular"
    case light = "Light"
    case medium = "Medium"
    case bold = "Bold"
    case italic = "Italic"
}

internal enum SPFontFamily: String {
    case openSans = "OpenSans"
}

