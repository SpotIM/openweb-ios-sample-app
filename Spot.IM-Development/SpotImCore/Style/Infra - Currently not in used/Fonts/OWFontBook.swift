//
//  OWFontBook.swift
//  SpotImCore
//
//  Created by Alon Haiut on 19/02/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import UIKit

protocol OWFontBookProtocol {
    func font(typography: OWFontTypography, forceOpenWebFont: Bool) -> UIFont
}

extension OWFontBookProtocol {
    func font(typography: OWFontTypography, forceOpenWebFont: Bool = false) -> UIFont {
        return font(typography: typography, forceOpenWebFont: forceOpenWebFont)
    }
}

protocol OWFontBookProtocolConfigurable {
    func configure(fontFamilyGroup: OWFontGroupFamily)
}

class OWFontBook: OWFontBookProtocol, OWFontBookProtocolConfigurable {

    static let shared: OWFontBookProtocol & OWFontBookProtocolConfigurable = OWFontBook()
    fileprivate let servicesProvider: OWSharedServicesProviding
    fileprivate var fontFamilyGroup: OWFontGroupFamily = .default

    private init(servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.servicesProvider = servicesProvider
        self.load(family: .default) // Load OpenWeb defualt font
    }

    func font(typography: OWFontTypography, forceOpenWebFont: Bool) -> UIFont {
        let style = typography.fontStyle
        let size = typography.defaultSize
        let defaultFont = openWebFont(style: style, size: size)

        guard !forceOpenWebFont else {
            return adjust(font: defaultFont, typography: typography)
        }

        guard let font = font(family: self.fontFamilyGroup, style: typography.fontStyle, size: typography.defaultSize) else {
            let logText = "Failed to generate \(self.fontFamilyGroup.fontFamilyName) font for style \(style.rawValue) for size \(size.description) - recovering by returning OpenWeb font"
            OWSharedServicesProvider.shared.logger().log(level: .error, logText)
            return adjust(font: defaultFont, typography: typography)
        }

        return adjust(font: font, typography: typography)
    }

    func configure(fontFamilyGroup: OWFontGroupFamily) {
        self.fontFamilyGroup = fontFamilyGroup
    }
}

fileprivate extension OWFontBook {
    func openWebFont(style: OWFontStyle, size: CGFloat) -> UIFont {
        // As of today, we are using OpenSans as our defualt font
        guard let font = font(family: OWFontGroupFamily.default, style: style, size: size) else {
            let logText = "Failed to generate OpenWeb font for style \(style.rawValue) for size \(size.description) - recovering by returning system font"
            OWSharedServicesProvider.shared.logger().log(level: .error, logText)
            return UIFont.systemFont(ofSize: size)
        }

        return font
    }

    func font(family: OWFontGroupFamily, style: OWFontStyle, size: CGFloat) -> UIFont? {
        // As of today, we are using OpenSans as our defualt font
        let fontFilename = fontFilename(family: family, style: style)

        return UIFont(name: fontFilename, size: size)
    }

    func load(family: OWFontGroupFamily, insideOpenWebSDK: Bool = true) {
        for style in OWFontStyle.allCases {
            let fontFilename = fontFilename(family: family, style: style)
            register(fontFilename: "\(fontFilename).ttf", insideOpenWebSDK: insideOpenWebSDK)
        }
    }

    func adjust(font: UIFont, typography: OWFontTypography) -> UIFont {
        let dynamicFont = adjustDynamic(font: font, style: typography.textStyle)
        let requestedDynamicSize = dynamicFont.pointSize

        if case .fixed(let maxSize) = typography.maxSizeEnforcement, requestedDynamicSize > maxSize {
            return font.withSize(maxSize)
        } else if case .fixed(let minSize) = typography.minSizeEnforcement, requestedDynamicSize < minSize {
            return font.withSize(minSize)
        } else {
            return dynamicFont
        }
    }

    func adjustDynamic(font: UIFont, style: UIFont.TextStyle) -> UIFont {
        return UIFontMetrics(forTextStyle: style).scaledFont(for: font)
    }

    func fontFilename(family: OWFontGroupFamily, style: OWFontStyle) -> String {
        let fontFamilyName = family.fontFamilyName
        return "\(fontFamilyName)-\(style.rawValue)"
    }

    func register(fontFilename: String, insideOpenWebSDK: Bool) {
        let frameworkBundle = insideOpenWebSDK ? Bundle.openWeb : Bundle.main

        guard let pathForResourceString = frameworkBundle.path(forResource: fontFilename, ofType: nil),
            let fontData = NSData(contentsOfFile: pathForResourceString),
            let dataProvider = CGDataProvider(data: fontData)
        else {
            let logText = "Failed to register font - couldn't find the path to the font"
            OWSharedServicesProvider.shared.logger().log(level: .error, logText)
            return
        }

        let fontRef = CGFont(dataProvider)
        var errorRef: Unmanaged<CFError>?
        if CTFontManagerRegisterGraphicsFont(fontRef!, &errorRef) == false {
            let message = errorRef.debugDescription
            errorRef?.release()
            let logText = "Failed to register font - error: \(message)"
                + "\nRegister graphics font failed"
                + "\nThis font may have already been registered."
            OWSharedServicesProvider.shared.logger().log(level: .error, logText)
        }
    }
}
