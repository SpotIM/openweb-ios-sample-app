//
//  CustomThemeColorsViewModel.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 24/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI
import Combine
import OpenWebSDK

class CustomThemeColorsViewModel: ObservableObject {
    @SDKSetting(SettingsItems.customThemeColors) var theme: OWTheme

    func isEnabled(_ keyPath: WritableKeyPath<OWTheme, UIColor?>) -> Bool {
        theme[keyPath: keyPath] != nil
    }

    func toggle(_ keyPath: WritableKeyPath<OWTheme, UIColor?>) {
        if theme[keyPath: keyPath] != nil {
            theme[keyPath: keyPath] = nil
        } else {
            theme[keyPath: keyPath] = .black
        }
    }

    func lightColor(_ keyPath: WritableKeyPath<OWTheme, UIColor?>) -> Color {
        guard let color = theme[keyPath: keyPath] else { return .black }
        return Color(uiColor: color.lightColor)
    }

    func darkColor(_ keyPath: WritableKeyPath<OWTheme, UIColor?>) -> Color {
        guard let color = theme[keyPath: keyPath] else { return .black }
        return Color(uiColor: color.darkColor)
    }

    func setLightColor(_ color: Color, for keyPath: WritableKeyPath<OWTheme, UIColor?>) {
        guard let existing = theme[keyPath: keyPath] else { return }
        theme[keyPath: keyPath] = UIColor(lightColor: UIColor(color), darkColor: existing.darkColor)
    }

    func setDarkColor(_ color: Color, for keyPath: WritableKeyPath<OWTheme, UIColor?>) {
        guard let existing = theme[keyPath: keyPath] else { return }
        theme[keyPath: keyPath] = UIColor(lightColor: existing.lightColor, darkColor: UIColor(color))
    }
}
