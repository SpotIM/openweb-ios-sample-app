//
//  OWNavigationAppearanceSettings.swift
//  OpenWebSDK
//
//  Created by Refael Sommer on 04/11/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

import UIKit

@available(iOS 13.0, *)
class OWNavigationAppearanceSettings {
    var appearance: UINavigationBarAppearance
    var scrollEdgeAppearance: UINavigationBarAppearance
    var navigationBarTintColor: UIColor?
    var navigationBarBackgroundColor: UIColor?

    init(from navigationBar: UINavigationBar) {
        self.appearance = UINavigationBarAppearance(barAppearance: navigationBar.standardAppearance)
        self.scrollEdgeAppearance = UINavigationBarAppearance(barAppearance: navigationBar.scrollEdgeAppearance ?? navigationBar.standardAppearance)
        self.navigationBarTintColor = navigationBar.tintColor
        self.navigationBarBackgroundColor = navigationBar.backgroundColor
    }

    func apply(to navigationBar: UINavigationBar?) {
        navigationBar?.standardAppearance = self.appearance
        navigationBar?.scrollEdgeAppearance = self.scrollEdgeAppearance
        navigationBar?.tintColor = self.navigationBarTintColor
        navigationBar?.backgroundColor = self.navigationBarBackgroundColor
    }
}
