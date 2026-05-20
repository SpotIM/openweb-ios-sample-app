//
//  OWCustomizationElements+Codable.swift
//  OpenWeb-Showcase
//
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import Foundation
import OpenWebSDK
import UIKit

struct CodableElement: Codable {
    var color: CodableUIColor?

    init(from element: OWCustomizationElement) {
        color = element.color.map(CodableUIColor.init)
    }

    func toModel() -> OWCustomizationElement {
        OWCustomizationElement(color: color?.toUIColor())
    }
}

struct CodableTextElement: Codable {
    var fontFamily: String?
    var fontWeightValue: CGFloat?
    var color: CodableUIColor?

    init(from element: OWCustomizationTextElement) {
        fontFamily = element.fontFamily
        fontWeightValue = element.fontWeight?.rawValue
        color = element.color.map(CodableUIColor.init)
    }

    func toModel() -> OWCustomizationTextElement {
        OWCustomizationTextElement(
            fontFamily: fontFamily,
            fontWeight: fontWeightValue.map { UIFont.Weight(rawValue: $0) },
            color: color?.toUIColor()
        )
    }
}

extension OWCustomizationElements: @retroactive Codable {
    enum CodingKeys: String, CodingKey {
        case navigationTitle, commenterName, commentBody, inputText, avatarText, commentActions
        case subtitle, detail, background, overlayBackground, cardBackground, border
        case sectionDivider, contentDivider, divider
        case skeletonGradientEdge, skeletonGradientCenter, loader, brand
        case voteUpSelected, voteDownSelected, voteUpUnselected, voteDownUnselected
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            navigationTitle: (try? container.decode(CodableTextElement.self, forKey: .navigationTitle))?.toModel() ?? .init(),
            commenterName: (try? container.decode(CodableTextElement.self, forKey: .commenterName))?.toModel() ?? .init(),
            commentBody: (try? container.decode(CodableTextElement.self, forKey: .commentBody))?.toModel() ?? .init(),
            inputText: (try? container.decode(CodableTextElement.self, forKey: .inputText))?.toModel() ?? .init(),
            avatarText: (try? container.decode(CodableTextElement.self, forKey: .avatarText))?.toModel() ?? .init(),
            commentActions: (try? container.decode(CodableTextElement.self, forKey: .commentActions))?.toModel() ?? .init(),
            subtitle: (try? container.decode(CodableElement.self, forKey: .subtitle))?.toModel() ?? .init(),
            detail: (try? container.decode(CodableElement.self, forKey: .detail))?.toModel() ?? .init(),
            background: (try? container.decode(CodableElement.self, forKey: .background))?.toModel() ?? .init(),
            overlayBackground: (try? container.decode(CodableElement.self, forKey: .overlayBackground))?.toModel() ?? .init(),
            cardBackground: (try? container.decode(CodableElement.self, forKey: .cardBackground))?.toModel() ?? .init(),
            border: (try? container.decode(CodableElement.self, forKey: .border))?.toModel() ?? .init(),
            sectionDivider: (try? container.decode(CodableElement.self, forKey: .sectionDivider))?.toModel() ?? .init(),
            contentDivider: (try? container.decode(CodableElement.self, forKey: .contentDivider))?.toModel() ?? .init(),
            divider: (try? container.decode(CodableElement.self, forKey: .divider))?.toModel() ?? .init(),
            skeletonGradientEdge: (try? container.decode(CodableElement.self, forKey: .skeletonGradientEdge))?.toModel() ?? .init(),
            skeletonGradientCenter: (try? container.decode(CodableElement.self, forKey: .skeletonGradientCenter))?.toModel() ?? .init(),
            loader: (try? container.decode(CodableElement.self, forKey: .loader))?.toModel() ?? .init(),
            brand: (try? container.decode(CodableElement.self, forKey: .brand))?.toModel() ?? .init(),
            voteUpSelected: (try? container.decode(CodableElement.self, forKey: .voteUpSelected))?.toModel() ?? .init(),
            voteDownSelected: (try? container.decode(CodableElement.self, forKey: .voteDownSelected))?.toModel() ?? .init(),
            voteUpUnselected: (try? container.decode(CodableElement.self, forKey: .voteUpUnselected))?.toModel() ?? .init(),
            voteDownUnselected: (try? container.decode(CodableElement.self, forKey: .voteDownUnselected))?.toModel() ?? .init()
        )
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(CodableTextElement(from: navigationTitle), forKey: .navigationTitle)
        try container.encode(CodableTextElement(from: commenterName), forKey: .commenterName)
        try container.encode(CodableTextElement(from: commentBody), forKey: .commentBody)
        try container.encode(CodableTextElement(from: inputText), forKey: .inputText)
        try container.encode(CodableTextElement(from: avatarText), forKey: .avatarText)
        try container.encode(CodableTextElement(from: commentActions), forKey: .commentActions)
        try container.encode(CodableElement(from: subtitle), forKey: .subtitle)
        try container.encode(CodableElement(from: detail), forKey: .detail)
        try container.encode(CodableElement(from: background), forKey: .background)
        try container.encode(CodableElement(from: overlayBackground), forKey: .overlayBackground)
        try container.encode(CodableElement(from: cardBackground), forKey: .cardBackground)
        try container.encode(CodableElement(from: border), forKey: .border)
        try container.encode(CodableElement(from: sectionDivider), forKey: .sectionDivider)
        try container.encode(CodableElement(from: contentDivider), forKey: .contentDivider)
        try container.encode(CodableElement(from: divider), forKey: .divider)
        try container.encode(CodableElement(from: skeletonGradientEdge), forKey: .skeletonGradientEdge)
        try container.encode(CodableElement(from: skeletonGradientCenter), forKey: .skeletonGradientCenter)
        try container.encode(CodableElement(from: loader), forKey: .loader)
        try container.encode(CodableElement(from: brand), forKey: .brand)
        try container.encode(CodableElement(from: voteUpSelected), forKey: .voteUpSelected)
        try container.encode(CodableElement(from: voteDownSelected), forKey: .voteDownSelected)
        try container.encode(CodableElement(from: voteUpUnselected), forKey: .voteUpUnselected)
        try container.encode(CodableElement(from: voteDownUnselected), forKey: .voteDownUnselected)
    }
}
