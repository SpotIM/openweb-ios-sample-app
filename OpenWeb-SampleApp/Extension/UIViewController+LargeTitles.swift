//
//  UIViewController+LargeTitles.swift
//  OpenWeb-Development
//
//  Created by Alon Haiut on 17/08/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import UIKit

extension UIViewController {
    func applyLargeTitlesIfNeeded() {
        if let navBar = navigationController?.navigationBar, navBar.prefersLargeTitles {
            navigationItem.largeTitleDisplayMode = .always
        }
    }
}
