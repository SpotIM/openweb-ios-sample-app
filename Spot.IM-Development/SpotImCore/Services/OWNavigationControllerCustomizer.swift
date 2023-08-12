//
//  OWNavigationControllerCustomizer.swift
//  SpotImCore
//
//  Created by Alon Haiut on 11/08/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift

protocol OWNavigationControllerCustomizing {
    func activeNavigationController(navigationController: UINavigationController)
    func isLargeTitlesEnabled() -> Bool
    func shouldCustomizeNavigationController() -> Bool
}

class OWNavigationControllerCustomizer: OWNavigationControllerCustomizing {

    struct Metrics {
        static let animationTimeForLargeTitle: Double = 0.15
    }

    fileprivate let disposeBag = DisposeBag()
    fileprivate let servicesProvider: OWSharedServicesProviding
    fileprivate let customizationsLayer: OWCustomizations
    fileprivate weak var activeNavigationController: UINavigationController?

    init(servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared,
         customizationsLayer: OWCustomizations = OpenWeb.manager.ui.customizations) {
        self.servicesProvider = servicesProvider
        self.customizationsLayer = customizationsLayer
        setupObservers()
    }

    func activeNavigationController(navigationController: UINavigationController) {
        activeNavigationController = navigationController
        let currentThemeStyle = servicesProvider.themeStyleService().currentStyle
        setupNavController(style: currentThemeStyle) // Setup navigation controller right away
    }

    func isLargeTitlesEnabled() -> Bool {
        if case OWNavigationBarEnforcement.style(let style) = customizationsLayer.navigationBarEnforcement,
           style == .largeTitles {
            return true
        } else {
            return false
        }
    }

    func shouldCustomizeNavigationController() -> Bool {
        let shouldKeepOriginal = customizationsLayer.navigationBarEnforcement == .keepOriginal
        return !shouldKeepOriginal
    }
}

fileprivate extension OWNavigationControllerCustomizer {

    func setupObservers() {
        servicesProvider.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] style in
                guard let self = self,
                      let _ = self.activeNavigationController else { return }

                self.setupNavController(style: style)
            })
            .disposed(by: disposeBag)
    }

    func setupNavController(style: OWThemeStyle) {
        guard let navController = activeNavigationController else { return }

        navController.navigationBar.prefersLargeTitles = self.isLargeTitlesEnabled()

        let navigationBarBackgroundColor = OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: style)
        navController.navigationBar.tintColor = OWColorPalette.shared.color(type: .textColor1, themeStyle: style)

        // Setup Title
        let navigationTitleTextAttributes = [
            NSAttributedString.Key.font: OWFontBook.shared.font(typography: .titleSmall),
            NSAttributedString.Key.foregroundColor: OWColorPalette.shared.color(type: .textColor1, themeStyle: style)
        ]

        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = navigationBarBackgroundColor
            appearance.titleTextAttributes = navigationTitleTextAttributes

            // Setup Back button
            let backButtonAppearance = UIBarButtonItemAppearance(style: .plain)
            backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
            appearance.backButtonAppearance = backButtonAppearance

            navController.navigationBar.standardAppearance = appearance
            navController.navigationBar.scrollEdgeAppearance = navController.navigationBar.standardAppearance
        } else {
            navController.navigationBar.backgroundColor = navigationBarBackgroundColor
            navController.navigationBar.titleTextAttributes = navigationTitleTextAttributes
        }
    }
}
