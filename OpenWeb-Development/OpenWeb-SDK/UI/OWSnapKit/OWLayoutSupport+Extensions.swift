//
//  OWLayoutSupport+Extensions.swift
//  OpenWebSDK
//
//  Created by Alon Haiut on 06/02/2022.
//  Copyright © 2022 OpenWeb. All rights reserved.
//

import UIKit

extension OWLayoutSupport {
    var OWSnp: OWConstraintLayoutSupportDSL {
        return OWConstraintLayoutSupportDSL(support: self)
    }
}
