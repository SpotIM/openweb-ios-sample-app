//
//  SampleAppNavigationController.swift
//  OpenWeb-Development
//
//  Created by Alon Haiut on 31/07/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import UIKit

class SampleAppNavigationController: UINavigationController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return topViewController?.preferredStatusBarStyle ?? .default
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return self.topViewController?.supportedInterfaceOrientations ?? .allButUpsideDown
    }

    static var shared = {
        return SampleAppNavigationController()
    }()

    init() {
        super.init(nibName: nil, bundle: nil)
        self.setupNavigationBarStyle()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension SampleAppNavigationController {
    func setupNavigationBarStyle() {
        let navigationBarBackgroundColor = ColorPalette.shared.color(type: .background)
        self.navigationBar.tintColor = ColorPalette.shared.color(type: .text)

        // Setup Title font
        let navigationTitleTextAttributes = [
            NSAttributedString.Key.font: FontBook.secondaryHeadingBold,
            NSAttributedString.Key.foregroundColor: ColorPalette.shared.color(type: .text)
        ]

        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = navigationBarBackgroundColor
        appearance.titleTextAttributes = navigationTitleTextAttributes

        // Setup Back button
        let backButtonAppearance = UIBarButtonItemAppearance(style: .plain)
        backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
        appearance.backButtonAppearance = backButtonAppearance

        self.navigationBar.standardAppearance = appearance
        self.navigationBar.scrollEdgeAppearance = self.navigationBar.standardAppearance
     }
}
