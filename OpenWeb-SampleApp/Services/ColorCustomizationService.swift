//
//  ColorCustomizationService.swift
//  OpenWeb-Development
//
//  Created by  Nogah Melamed on 27/12/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation
import UIKit
import OpenWebSDK

protocol ColorCustomizationServicing {
    static func setColorCustomization()
}

class ColorCustomizationService: ColorCustomizationServicing {

    static func setColorCustomization() {
        let style = UserDefaultsProvider.shared.get(key: .colorCustomizationStyleIndex, defaultValue: SettingsColorCustomizationStyle.defaultIndex)
        let customizations = OpenWeb.manager.ui.customizations

        switch style {
        case 1: // style 1
            customizations.customizedTheme = OWTheme(
                skeletonColor: OWColor(lightColor: .blue, darkColor: .red),
                skeletonShimmeringColor: OWColor(lightColor: .purple, darkColor: .systemPink),
                primarySeparatorColor: OWColor(lightColor: .green, darkColor: .yellow),
                secondarySeparatorColor: OWColor(lightColor: .cyan, darkColor: .magenta),
                tertiarySeparatorColor: OWColor(lightColor: .brown, darkColor: .orange),
                primaryTextColor: OWColor(lightColor: .black, darkColor: .white),
                secondaryTextColor: OWColor(lightColor: .red, darkColor: .blue),
                tertiaryTextColor: OWColor(lightColor: .gray, darkColor: .systemTeal),
                primaryBackgroundColor: OWColor(lightColor: .systemPink, darkColor: .purple),
                secondaryBackgroundColor: OWColor(lightColor: .yellow, darkColor: .green),
                tertiaryBackgroundColor: OWColor(lightColor: .magenta, darkColor: .cyan),
                surfaceColor: OWColor(lightColor: .blue, darkColor: .green),
                primaryBorderColor: OWColor(lightColor: .orange, darkColor: .brown),
                secondaryBorderColor: OWColor(lightColor: .white, darkColor: .black),
                loaderColor: OWColor(lightColor: .brown, darkColor: .yellow),
                brandColor: OWColor(lightColor: .cyan, darkColor: .black))
        case 2: // Custom theme
            // get saved theme from user defaults
            let theme = UserDefaultsProvider.shared.get(key: .colorCustomizationCustomTheme, defaultValue: OWTheme())
            customizations.customizedTheme = theme
        default:
            break
        }
    }
}
