//
//  UIView+Utils.swift
//  Spot.IM-Core
//
//  Created by Eugene on 7/26/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit

extension UIView {

    func addSubviews(_ views: UIView...) {
        views.forEach { addSubview($0) }
    }

    var isVisibleToUser: Bool {
        guard let windowHeight = window?.frame.size.height else {
            return false
        }

        let absoluteY = convert(CGPoint.zero, to: nil).y

        return absoluteY < windowHeight
    }
}
