//
//  CustomThemeColorsViewModel.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 24/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI
import Combine

class CustomThemeColorsViewModel: ObservableObject {
    @SDKSetting(SettingsItems.customThemeColors) var theme: CodableTheme

    func isEnabled(_ keyPath: WritableKeyPath<CodableTheme, CodableUIColor?>) -> Bool {
        theme[keyPath: keyPath] != nil
    }

    func toggle(_ keyPath: WritableKeyPath<CodableTheme, CodableUIColor?>) {
        if theme[keyPath: keyPath] != nil {
            theme[keyPath: keyPath] = nil
        } else {
            theme[keyPath: keyPath] = CodableUIColor(from: .black)
        }
    }

    func lightColor(_ keyPath: WritableKeyPath<CodableTheme, CodableUIColor?>) -> Color {
        guard let color = theme[keyPath: keyPath] else { return .black }
        return Color(uiColor: color.lightColor.toUIColor())
    }

    func darkColor(_ keyPath: WritableKeyPath<CodableTheme, CodableUIColor?>) -> Color {
        guard let color = theme[keyPath: keyPath] else { return .black }
        return Color(uiColor: color.darkColor.toUIColor())
    }

    func setLightColor(_ color: Color, for keyPath: WritableKeyPath<CodableTheme, CodableUIColor?>) {
        theme[keyPath: keyPath]?.lightColor = CodableUIColor.ColorComponents(from: UIColor(color))
    }

    func setDarkColor(_ color: Color, for keyPath: WritableKeyPath<CodableTheme, CodableUIColor?>) {
        theme[keyPath: keyPath]?.darkColor = CodableUIColor.ColorComponents(from: UIColor(color))
    }
}
