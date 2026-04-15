//
//  ShowcaseScreenConfigurator.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 24/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI
@_spi(Muting) import OpenWebSDK

enum ShowcaseScreenConfigurator {
    static let mutedUsersProvider = ShowcaseMutedUsersProvider()

    static func applyShowcaseSettings() {
        // MARK: SDK Usage
        OpenWeb.manager.ui.customizations.addElementCallback { element, source, themeStyle, postId in
            if SDKSetting(SettingsItems.enableCustomUICallback).wrappedValue {
                CustomUICallback.customize(element, themeStyle: themeStyle)
            }
        }
        OpenWeb.manager.helpers.mutedUsersProvider = mutedUsersProvider
        SDKSetting(SettingsItems.customThemeColors).wrappedValue.applyToSDK()
    }
}
