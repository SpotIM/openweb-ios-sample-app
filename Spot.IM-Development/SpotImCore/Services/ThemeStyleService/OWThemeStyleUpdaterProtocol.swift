//
//  OWThemeStyleUpdaterProtocol.swift
//  SpotImCore
//
//  Created by Alon Haiut on 11/12/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit

protocol OWThemeStyleUpdaterProtocol {
    @available(iOS 12.0, *)
    func updateThemeStyleService(userInterfaceStyle: UIUserInterfaceStyle)
}

extension OWThemeStyleUpdaterProtocol {
    @available(iOS 12.0, *)
    func updateThemeStyleService(userInterfaceStyle: UIUserInterfaceStyle) {
        let servicesProvider = OWSharedServicesProvider.shared
        let themeStyleService = servicesProvider.themeStyleService()
        switch userInterfaceStyle {
        case .light:
            themeStyleService.setStyle(style: .light)
        case .dark:
            themeStyleService.setStyle(style: .dark)
        default:
            // Do nothing
            break
        }
    }
}
