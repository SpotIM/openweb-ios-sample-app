//
//  OWCustomizations.swift
//  OpenWebSDK
//
//  Created by Alon Haiut on 08/11/2022.
//  Copyright © 2022 OpenWeb. All rights reserved.
//

import Foundation

public protocol OWCustomizations {
    var fontFamily: OWFontGroupFamily { get set }
    var sorting: OWSortingCustomizations { get }
    var themeEnforcement: OWThemeStyleEnforcement { get set }
    var statusBarEnforcement: OWStatusBarEnforcement { get set }
    var navigationBarEnforcement: OWNavigationBarEnforcement { get set }
    var customizedTheme: OWTheme { get set }
    func addElementCallback(_ callback: @escaping OWCustomizableElementCallback)
}
