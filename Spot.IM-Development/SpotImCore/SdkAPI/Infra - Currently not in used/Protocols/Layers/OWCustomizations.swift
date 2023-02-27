//
//  OWCustomizations.swift
//  SpotImCore
//
//  Created by Alon Haiut on 08/11/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public protocol OWCustomizations {
    var fontFamily: OWFontGroupFamily { get set }
    var sorting: OWSortingCustomizations { get }
    var themeEnforcement: OWThemeStyleEnforcement { get set }
    func addElementCallback(_ callback: @escaping OWCustomizableElementCallback)
}
#else
protocol OWCustomizations {
    var fontFamily: OWFontGroupFamily { get set }
    var sorting: OWSortingCustomizations { get }
    var themeEnforcement: OWThemeStyleEnforcement { get set }
    func addElementCallback(_ callback: @escaping OWCustomizableElementCallback)
}
#endif
