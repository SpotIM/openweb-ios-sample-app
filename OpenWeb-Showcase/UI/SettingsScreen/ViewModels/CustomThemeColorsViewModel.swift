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

    func isEnabled(_ keyPath: WritableKeyPath<CodableTheme, CodableColor?>) -> Bool {
        theme[keyPath: keyPath] != nil
    }

    func toggle(_ keyPath: WritableKeyPath<CodableTheme, CodableColor?>) {
        if theme[keyPath: keyPath] != nil {
            theme[keyPath: keyPath] = nil
        } else {
            theme[keyPath: keyPath] = CodableColor()
        }
    }

    func lightColor(_ keyPath: WritableKeyPath<CodableTheme, CodableColor?>) -> Color {
        guard let color = theme[keyPath: keyPath] else { return .black }
        return Color(hex: color.lightHex)
    }

    func darkColor(_ keyPath: WritableKeyPath<CodableTheme, CodableColor?>) -> Color {
        guard let color = theme[keyPath: keyPath] else { return .black }
        return Color(hex: color.darkHex)
    }

    func setLightColor(_ color: Color, for keyPath: WritableKeyPath<CodableTheme, CodableColor?>) {
        theme[keyPath: keyPath]?.lightHex = color.hexString
    }

    func setDarkColor(_ color: Color, for keyPath: WritableKeyPath<CodableTheme, CodableColor?>) {
        theme[keyPath: keyPath]?.darkHex = color.hexString
    }
}
