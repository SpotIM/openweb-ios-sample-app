//
//  OWCustomizationElements+Codable.swift
//  OpenWeb-Showcase
//
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import Foundation
import OpenWebSDK
import UIKit

struct CodableColorElement: Codable {
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
            subtitle: (try? container.decode(CodableColorElement.self, forKey: .subtitle))?.toModel() ?? .init(),
            detail: (try? container.decode(CodableColorElement.self, forKey: .detail))?.toModel() ?? .init(),
            background: (try? container.decode(CodableColorElement.self, forKey: .background))?.toModel() ?? .init(),
            overlayBackground: (try? container.decode(CodableColorElement.self, forKey: .overlayBackground))?.toModel() ?? .init(),
            cardBackground: (try? container.decode(CodableColorElement.self, forKey: .cardBackground))?.toModel() ?? .init(),
            border: (try? container.decode(CodableColorElement.self, forKey: .border))?.toModel() ?? .init(),
            sectionDivider: (try? container.decode(CodableColorElement.self, forKey: .sectionDivider))?.toModel() ?? .init(),
            contentDivider: (try? container.decode(CodableColorElement.self, forKey: .contentDivider))?.toModel() ?? .init(),
            divider: (try? container.decode(CodableColorElement.self, forKey: .divider))?.toModel() ?? .init(),
            skeletonGradientEdge: (try? container.decode(CodableColorElement.self, forKey: .skeletonGradientEdge))?.toModel() ?? .init(),
            skeletonGradientCenter: (try? container.decode(CodableColorElement.self, forKey: .skeletonGradientCenter))?.toModel() ?? .init(),
            loader: (try? container.decode(CodableColorElement.self, forKey: .loader))?.toModel() ?? .init(),
            brand: (try? container.decode(CodableColorElement.self, forKey: .brand))?.toModel() ?? .init(),
            voteUpSelected: (try? container.decode(CodableColorElement.self, forKey: .voteUpSelected))?.toModel() ?? .init(),
            voteDownSelected: (try? container.decode(CodableColorElement.self, forKey: .voteDownSelected))?.toModel() ?? .init(),
            voteUpUnselected: (try? container.decode(CodableColorElement.self, forKey: .voteUpUnselected))?.toModel() ?? .init(),
            voteDownUnselected: (try? container.decode(CodableColorElement.self, forKey: .voteDownUnselected))?.toModel() ?? .init()
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
        try container.encode(CodableColorElement(from: subtitle), forKey: .subtitle)
        try container.encode(CodableColorElement(from: detail), forKey: .detail)
        try container.encode(CodableColorElement(from: background), forKey: .background)
        try container.encode(CodableColorElement(from: overlayBackground), forKey: .overlayBackground)
        try container.encode(CodableColorElement(from: cardBackground), forKey: .cardBackground)
        try container.encode(CodableColorElement(from: border), forKey: .border)
        try container.encode(CodableColorElement(from: sectionDivider), forKey: .sectionDivider)
        try container.encode(CodableColorElement(from: contentDivider), forKey: .contentDivider)
        try container.encode(CodableColorElement(from: divider), forKey: .divider)
        try container.encode(CodableColorElement(from: skeletonGradientEdge), forKey: .skeletonGradientEdge)
        try container.encode(CodableColorElement(from: skeletonGradientCenter), forKey: .skeletonGradientCenter)
        try container.encode(CodableColorElement(from: loader), forKey: .loader)
        try container.encode(CodableColorElement(from: brand), forKey: .brand)
        try container.encode(CodableColorElement(from: voteUpSelected), forKey: .voteUpSelected)
        try container.encode(CodableColorElement(from: voteDownSelected), forKey: .voteDownSelected)
        try container.encode(CodableColorElement(from: voteUpUnselected), forKey: .voteUpUnselected)
        try container.encode(CodableColorElement(from: voteDownUnselected), forKey: .voteDownUnselected)
    }
}
