//
//  UIView+Extensions.swift
//  OpenWebSDK
//
//  Created by Alon Haiut on 06/02/2022.
//  Copyright © 2022 OpenWeb. All rights reserved.
//

import UIKit

extension UIView {
    var OWSnp: OWConstraintViewDSL {
        return OWConstraintViewDSL(view: self)
    }
}
