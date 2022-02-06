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
        if LocalizationManager.currentLanguage == .hebrew {
            return openSansHebrew(style: style, of: size)
        } else {
            return roboto(style: style, of: size)
        }
    }
    
    static func customFont(customFontFamily:String, style: SPFontStyle, of size: CGFloat) -> UIFont {
        let fontName = "\(customFontFamily)-\(style.rawValue)"
        return UIFont(name: fontName, size: size) ?? roboto(style: style, of: size)
    }
    
    static func roboto(style: SPFontStyle, of size: CGFloat) -> UIFont {
        let robotoName = name(of: .roboto, with: style)
        
        return UIFont(name: robotoName, size: size) ?? systemFont(ofSize: size)
    }

    static func openSans(style: SPFontStyle, of size: CGFloat) -> UIFont {
        let openSansName = name(of: .openSans, with: style)
        
        return UIFont(name: openSansName, size: size) ?? systemFont(ofSize: size)
    }
    
    static func arialHebrew(style: SPFontStyle, of size: CGFloat) -> UIFont {
        var style = style
        if style == .regular || style == .medium {
            style = .empty
        }
        
        let arialHebrew = name(of: .arialHebrew, with: style)
        let font = UIFont(name: arialHebrew, size: size)
        
        return font ?? systemFont(ofSize: size)
    }
    
    static func openSansHebrew(style: SPFontStyle, of size: CGFloat) -> UIFont {
        var style = style
        if style == .medium {
            style = .bold
        }
        let openSansHebrew = name(of: .openSansHebrew, with: style)
        return UIFont(name: openSansHebrew, size: size) ?? systemFont(ofSize: size)
    }
    
    private static func name(of family: SPFontFamily, with style: SPFontStyle) -> String {
        return "\(family.rawValue)-\(style.rawValue)"
    }

    // load framework font in application
    static let loadAllFonts: () = {
        registerFontWith(filenameString: "Roboto-Bold.ttf")
        registerFontWith(filenameString: "Roboto-Medium.ttf")
        registerFontWith(filenameString: "Roboto-Regular.ttf")
        registerFontWith(filenameString: "Roboto-Italic.ttf")
        registerFontWith(filenameString: "OpenSans-RegularItalic.ttf")
        registerFontWith(filenameString: "ArialHebrew-Bold.ttf")
        registerFontWith(filenameString: "ArialHebrew.ttf")
        registerFontWith(filenameString: "ArialHebrew-Light.ttf")
        registerFontWith(filenameString: "OpenSansHebrew-Bold.ttf")
        registerFontWith(filenameString: "OpenSansHebrew-ExtraBold.ttf")
        registerFontWith(filenameString: "OpenSansHebrew-Light.ttf")
        registerFontWith(filenameString: "OpenSansHebrew-Regular.ttf")
    }()

    // MARK: - Make custom font bundle register to framework
    static func registerFontWith(filenameString: String) {
        let frameworkBundle = Bundle.spot
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
            OWLogger.error(
                "Failed to register font - error: \(message)"
                + "\nRegister graphics font failed"
                + "\nThis font may have already been registered in the main bundle."
            )
        }
    }
}

internal enum SPFontStyle: String {
    case regular = "Regular"
    case medium = "Medium"
    case bold = "Bold"
    case regularItalic = "Italic"
    case empty = ""
}

internal enum SPFontFamily: String {
    case roboto = "Roboto"
    case openSans = "OpenSans"
    case arialHebrew = "ArialHebrew"
    case openSansHebrew = "OpenSansHebrew"
}

