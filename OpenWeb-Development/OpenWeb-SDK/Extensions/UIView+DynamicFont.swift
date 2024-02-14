//
//  UIView+DynamicFont.swift
//  SpotImCore
//
//  Created by Revital Pisman on 12/07/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import UIKit

extension UITextView {
    @discardableResult func font(_ font: UIFont) -> Self {
        self.font = font
        self.adjustsFontForContentSizeCategory = true
        return self
    }
}

extension UILabel {
    @discardableResult func font(_ font: UIFont) -> Self {
        self.font = font
        self.adjustsFontForContentSizeCategory = true
        return self
    }
}

extension UIButton {
    @discardableResult func font(_ font: UIFont) -> Self {
        self.titleLabel?.font = font
        self.titleLabel?.adjustsFontForContentSizeCategory = true
        return self
    }
}
