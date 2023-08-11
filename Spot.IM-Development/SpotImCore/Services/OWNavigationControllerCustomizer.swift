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
}

class OWNavigationControllerCustomizer: OWNavigationControllerCustomizing {

    struct Metrics {
        static let animationTimeForLargeTitle: Double = 0.15
    }

    fileprivate let disposeBag = DisposeBag()
    fileprivate let servicesProvider: OWSharedServicesProviding
    fileprivate let customizationsLayer: OWCustomizationsInternalProtocol
    fileprivate weak var activeNavigationController: UINavigationController?

    // swiftlint:disable force_cast
    init(servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared,
         customizationsLayer: OWCustomizationsInternalProtocol = OpenWeb.manager.ui.customizations as! OWCustomizationsInternalProtocol) {
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
        return true
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

        if self.isLargeTitlesEnabled() {
            navController.navigationBar.prefersLargeTitles = true
        }

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
