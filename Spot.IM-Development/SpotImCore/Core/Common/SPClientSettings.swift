//
//  SPClientSettings.swift
//  Spot.IM-Core
//
//  Created by Andriy Fedin on 18/06/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit
import PromiseKit

public class SPClientSettings {
    
    public static let main: SPClientSettings = {
        let settings = SPClientSettings()
        let apiManager = ApiManager()
        settings.configProvider = SPDefaultConfigProvider(apiManager: apiManager)
        
        return settings
    }()
    
    private(set) var spotKey: String?
    private var configProvider: SPDefaultConfigProvider!
    
    @available(*, deprecated, message: "Use SpotIm.initialize(spotId: String) instead")
    public func setup(spotKey: String?) {
        if self.spotKey != spotKey {
            self.spotKey = spotKey
            UIFont.loadAllFonts
            
            sendAppInitEvent()

            NotificationCenter.default.addObserver(
                    self,
                    selector: #selector(appMovedToForeground),
                    name: UIApplication.willEnterForegroundNotification,
                    object: nil)
            
            firstly {
                configProvider.fetchConfigs()
            }.done { _ in
                
            }.catch { error in
                
            }
        }
    }

    internal func  setup(spotId: String) -> Promise<SpotConfig> {
        self.spotKey = spotId
        UIFont.loadAllFonts
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appMovedToForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil)
        
        return configProvider.fetchConfigs()
    }
    
    internal func sendAppInitEvent() {
        SPAnalyticsHolder.default.log(event: .appInit, source: .mainPage)
    }
    
    @objc
    public func appMovedToForeground(notification: Notification) {
        SPAnalyticsHolder.default.log(event: .appOpened, source: .mainPage)
    }
    
    @available(*, deprecated, message: "Use SpotIm.overrideUserInterfaceStyle instead")
    public static var overrideUserInterfaceStyle: SPUserInterfaceStyle? = {
        if UserDefaults.standard.bool(forKey: "demo.isCustomDarkModeEnabled") {
            return SPUserInterfaceStyle(rawValue: UserDefaults.standard.integer(forKey: "demo.interfaceStyle"))
        }
        return nil
    }()
    
    internal static var darkModeBackgroundColor: UIColor = .mineShaft
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
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
        if let style = SpotIm.overrideUserInterfaceStyle {
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
