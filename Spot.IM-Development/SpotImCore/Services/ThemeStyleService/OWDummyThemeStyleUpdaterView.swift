//
//  OWDummyThemeStyleUpdaterView.swift
//  SpotImCore
//
//  Created by Alon Haiut on 11/12/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit

class OWDummyThemeStyleUpdaterView: UIView, OWThemeStyleUpdaterProtocol {

    struct Metrics {
        static let defaultSize: CGFloat = 1.0
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init() {
        super.init(frame: .zero)
        self.backgroundColor = .clear
        if #available(iOS 12.0, *) {
            updateThemeStyleService(userInterfaceStyle: traitCollection.userInterfaceStyle)
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if #available(iOS 12.0, *) {
            updateThemeStyleService(userInterfaceStyle: traitCollection.userInterfaceStyle)
        }
    }
}
