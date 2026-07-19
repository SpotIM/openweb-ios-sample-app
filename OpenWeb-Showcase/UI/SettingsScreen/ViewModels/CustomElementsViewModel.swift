//
//  CustomElementsViewModel.swift
//  OpenWeb-Showcase
//
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI
import Combine
import OpenWebSDK

protocol OWColorCustomizing {
    var color: UIColor? { get set }
}

extension OWCustomizationElement: OWColorCustomizing {}
extension OWCustomizationTextElement: OWColorCustomizing {}

class CustomElementsViewModel: NSObject, ObservableObject {
    @SDKSetting(SettingsItems.customElements) var elements: OWCustomizationElements

    // MARK: - Text Element Helpers

    func fontFamily(for keyPath: WritableKeyPath<OWCustomizationElements, OWCustomizationTextElement>) -> String? {
        elements[keyPath: keyPath].fontFamily
    }

    func setFontFamily(_ name: String?, for keyPath: WritableKeyPath<OWCustomizationElements, OWCustomizationTextElement>) {
        elements[keyPath: keyPath].fontFamily = name
    }

    func fontWeight(for keyPath: WritableKeyPath<OWCustomizationElements, OWCustomizationTextElement>) -> UIFont.Weight? {
        elements[keyPath: keyPath].fontWeight
    }

    func setFontWeight(_ weight: UIFont.Weight?, for keyPath: WritableKeyPath<OWCustomizationElements, OWCustomizationTextElement>) {
        elements[keyPath: keyPath].fontWeight = weight
    }

    // MARK: - Color Helpers (generic)

    func isColorEnabled<T: OWColorCustomizing>(_ keyPath: WritableKeyPath<OWCustomizationElements, T>) -> Bool {
        elements[keyPath: keyPath].color != nil
    }

    func toggleColor<T: OWColorCustomizing>(_ keyPath: WritableKeyPath<OWCustomizationElements, T>) {
        if elements[keyPath: keyPath].color != nil {
            elements[keyPath: keyPath].color = nil
        } else {
            elements[keyPath: keyPath].color = .tintColor
        }
    }

    func lightColor<T: OWColorCustomizing>(_ keyPath: WritableKeyPath<OWCustomizationElements, T>) -> Color {
        guard let color = elements[keyPath: keyPath].color else { return .black }
        return Color(uiColor: color.lightColor)
    }

    func darkColor<T: OWColorCustomizing>(_ keyPath: WritableKeyPath<OWCustomizationElements, T>) -> Color {
        guard let color = elements[keyPath: keyPath].color else { return .black }
        return Color(uiColor: color.darkColor)
    }

    func setLightColor<T: OWColorCustomizing>(_ color: Color, for keyPath: WritableKeyPath<OWCustomizationElements, T>) {
        guard let existing = elements[keyPath: keyPath].color else { return }
        elements[keyPath: keyPath].color = UIColor(lightColor: UIColor(color), darkColor: existing.darkColor)
    }

    func setDarkColor<T: OWColorCustomizing>(_ color: Color, for keyPath: WritableKeyPath<OWCustomizationElements, T>) {
        guard let existing = elements[keyPath: keyPath].color else { return }
        elements[keyPath: keyPath].color = UIColor(lightColor: existing.lightColor, darkColor: UIColor(color))
    }
}

// MARK: - Display Helpers

extension CustomElementsViewModel {
    static let textElementProperties: [(keyPath: WritableKeyPath<OWCustomizationElements, OWCustomizationTextElement>, name: String)] = [
        (\.navigationTitle, "Navigation Title"),
        (\.commenterName, "Commenter Name"),
        (\.commentBody, "Comment Body"),
        (\.inputText, "Input Text"),
        (\.avatarText, "Avatar Text"),
        (\.commentActions, "Comment Actions"),
    ]

    static let colorElementProperties: [(keyPath: WritableKeyPath<OWCustomizationElements, OWCustomizationElement>, name: String)] = [
        (\.subtitle, "Subtitle"),
        (\.detail, "Detail"),
        (\.background, "Background"),
        (\.overlayBackground, "Overlay Background"),
        (\.cardBackground, "Card Background"),
        (\.border, "Border"),
        (\.sectionDivider, "Section Divider"),
        (\.contentDivider, "Content Divider"),
        (\.divider, "Divider"),
        (\.skeletonGradientEdge, "Skeleton Gradient Edge"),
        (\.skeletonGradientCenter, "Skeleton Gradient Center"),
        (\.loader, "Loader"),
        (\.brand, "Brand"),
        (\.voteUpSelected, "Vote Up Selected"),
        (\.voteDownSelected, "Vote Down Selected"),
        (\.voteUpUnselected, "Vote Up Unselected"),
        (\.voteDownUnselected, "Vote Down Unselected"),
    ]

    static let fontWeightOptions: [(weight: UIFont.Weight?, name: String)] = [
        (nil, "Default"),
        (.ultraLight, "Ultra Light"),
        (.thin, "Thin"),
        (.light, "Light"),
        (.regular, "Regular"),
        (.medium, "Medium"),
        (.semibold, "Semibold"),
        (.bold, "Bold"),
        (.heavy, "Heavy"),
        (.black, "Black"),
    ]
}
