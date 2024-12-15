//
//  String+Extensions.swift
//  OpenWeb-Development
//
//  Created by Itay Dressler on 15/08/2019.
//  Copyright © 2019 OpenWeb. All rights reserved.
//

import Foundation
import UIKit

extension String {
    var blueRoundedButton: UIButton {
        return self.button(color: ColorPalette.shared.color(type: .blue))
    }

    var darkGrayRoundedButton: UIButton {
        return self.button(color: ColorPalette.shared.color(type: .darkGrey))
    }

    func button(color: UIColor) -> UIButton {
        return self
            .button
            .adjustsFontSizeToFitWidth
            .backgroundColor(color)
            .textColor(ColorPalette.shared.color(type: .white))
            .corner(radius: 5)
            .withHorizontalPadding(10)
            .font(FontBook.paragraphBold)
    }
}
