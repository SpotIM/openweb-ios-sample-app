//
//  SettingsSDKApplicable.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 17/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import OpenWebSDK

// MARK: - SDKApplicable

extension CustomizationsViewModel.SortOptionSetting: SDKApplicable {
    func applyToSDK() {
        let strategy: OWInitialSortStrategy = switch self {
        case .server: .useServerConfig
        case .best: .use(sortOption: .best)
        case .newest: .use(sortOption: .newest)
        case .oldest: .use(sortOption: .oldest)
        }

        // MARK: OpenWeb SDK
        OpenWeb.manager.ui.customizations.sorting.initialOption = strategy
    }
}

extension CustomizationsViewModel.ActionColorSetting: SDKApplicable {
    func applyToSDK() {
        let color: OWCommentActionsColor = switch self {
        case .default: .default
        case .brandColor: .brandColor
        }

        // MARK: OpenWeb SDK
        OpenWeb.manager.ui.customizations.commentActions.color = color
    }
}

extension CustomizationsViewModel.ActionFontSetting: SDKApplicable {
    func applyToSDK() {
        let fontStyle: OWCommentActionsFontStyle = switch self {
        case .default: .default
        case .semiBold: .semiBold
        }

        // MARK: OpenWeb SDK
        OpenWeb.manager.ui.customizations.commentActions.fontStyle = fontStyle
    }
}

extension CustomizationsViewModel.FontFamilySetting: SDKApplicable {
    func applyToSDK() {
        let fontFamily: OWFontGroupFamily = switch self {
        case .default: .default
        case .custom: .custom(fontFamily: "Georgia")
        }

        // MARK: OpenWeb SDK
        OpenWeb.manager.ui.customizations.fontFamily = fontFamily
    }
}
