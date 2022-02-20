//
//  OWLayoutSupport+Extensions.swift
//  SpotImCore
//
//  Created by Alon Haiut on 06/02/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit

extension OWLayoutSupport {
    var OWSnp: OWConstraintLayoutSupportDSL {
        return OWConstraintLayoutSupportDSL(support: self)
    }
}
