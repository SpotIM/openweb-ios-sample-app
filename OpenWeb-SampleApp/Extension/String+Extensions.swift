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
            .corner(radius: 5) // swiftlint:disable:this no_magic_numbers
            .withHorizontalPadding(10) // swiftlint:disable:this no_magic_numbers
            .font(FontBook.paragraphBold)
    }
}
