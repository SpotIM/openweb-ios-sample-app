//
//  ShowcaseScreenConfigurator.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 24/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI
import OpenWebSDK

enum ShowcaseScreenConfigurator {
    static func applyShowcaseSettings() {
        OpenWeb.manager.ui.customizations.addElementCallback { element, source, themeStyle, postId in
            if SDKSetting(SettingsItems.enableCustomUICallback).wrappedValue {
                CustomUICallback.customize(element, themeStyle: themeStyle)
            }
        }
        SDKSetting(SettingsItems.customThemeColors).wrappedValue.applyToSDK()
    }
}
