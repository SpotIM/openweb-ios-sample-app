//
//  OWNavigationController.swift
//  SpotImCore
//
//  Created by Alon Haiut on 08/09/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift

protocol OWNavigationControllerProtocol {
    var dismissed: Observable<Void> { get }
    func clear()
}

class OWNavigationController: UINavigationController, OWNavigationControllerProtocol {

    // We need to create a shared nav controller so it will stay in the memory, Router layer "holds" nav controller in a weak reference
    static let shared: OWNavigationController = {
        let navController = OWNavigationController()
        navController.setupNavControllerUI()
        return navController
    }()

    fileprivate let _dismissed = PublishSubject<Void>()
    var dismissed: Observable<Void> {
        return _dismissed
            .asObservable()
    }

    func clear() {
        self.setViewControllers([], animated: false)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isBeingDismissed {
            _dismissed.onNext()
        }
    }
}

fileprivate extension OWNavigationController {
    func setupNavControllerUI() {
        let themeService = OWSharedServicesProvider.shared.themeStyleService()
        let currentThemeStyle = themeService.currentStyle

        self.navigationBar.isTranslucent = true
        let navigationBarBackgroundColor = OWColorPalette.shared.color(type: .systemBackground, themeStyle: currentThemeStyle)

        // Setup Title font
        let navigationTitleTextAttributes = [
            // Currently this is intentionally to match the SampleApp design. Later on we can have a dedicated design to the nav bar in present mode
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18, weight: .bold),
            NSAttributedString.Key.foregroundColor: OWColorPalette.shared.color(type: .systemText, themeStyle: currentThemeStyle)
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

            self.navigationBar.standardAppearance = appearance
            self.navigationBar.scrollEdgeAppearance = self.navigationBar.standardAppearance
        } else {
            self.navigationBar.backgroundColor = navigationBarBackgroundColor
            self.navigationBar.titleTextAttributes = navigationTitleTextAttributes
        }
    }
}
