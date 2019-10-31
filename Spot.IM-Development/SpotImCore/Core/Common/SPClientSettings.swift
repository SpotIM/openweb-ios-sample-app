//
//  SPClientSettings.swift
//  Spot.IM-Core
//
//  Created by Andriy Fedin on 18/06/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit

public struct SPClientSettings {
    
    internal private(set) static var spotKey: String?

    public static func setup(spotKey: String?) {
        if self.spotKey != spotKey {
            self.spotKey = spotKey
            UIFont.loadAllFonts
            
            SPAnalyticsHolder.default.log(event: .appOpened, source: .mainPage)
            
            SPDefaultConfigProvider.getConfig { (conf, _) in
                SPConfigDataSource.config = conf
                
            }
        }
    }

    public static var overrideUserInterfaceStyle: SPUserInterfaceStyle? = {
        if UserDefaults.standard.bool(forKey: "demo.isCustomDarkModeEnabled") {
            return SPUserInterfaceStyle(rawValue: UserDefaults.standard.integer(forKey: "demo.interfaceStyle"))
        }
        return nil
    }()
    public static var darkModeBackgroundColor: UIColor = .mineShaft
}

public enum SPUserInterfaceStyle: Int {

    case light
    case dark

    @available(iOS 12.0, *)
    var nativeValue: UIUserInterfaceStyle {
        switch self {
        case .dark:
            return .dark
        default:
            return .light
        }
    }

    static var current: SPUserInterfaceStyle {
        if let style = SPClientSettings.overrideUserInterfaceStyle {
            return style
        } else if #available(iOS 13, *) {
            return UIScreen.main.traitCollection.userInterfaceStyle == .dark ? .dark : .light
        } else {
            return .light
        }
    }

    static var isDarkMode: Bool {
        return SPUserInterfaceStyle.current == .dark
    }
}
