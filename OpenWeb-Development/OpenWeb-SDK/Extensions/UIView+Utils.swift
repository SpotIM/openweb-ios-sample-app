//
//  UIView+Utils.swift
//  OpenWebSDK
//
//  Created by Eugene on 7/26/19.
//  Copyright © 2019 OpenWeb. All rights reserved.
//

import UIKit

extension UIView {

    func addSubviews(_ views: UIView...) {
        views.forEach { addSubview($0) }
    }
}
