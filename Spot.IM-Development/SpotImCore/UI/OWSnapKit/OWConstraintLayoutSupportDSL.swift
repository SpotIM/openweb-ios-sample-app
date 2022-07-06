//
//  OWConstraintLayoutSupportDSL.swift
//  SpotImCore
//
//  Created by Alon Haiut on 06/02/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit

struct OWConstraintLayoutSupportDSL: OWConstraintDSL {
    
    var target: AnyObject? {
        return self.support
    }
    
    private let support: OWLayoutSupport
    
    init(support: OWLayoutSupport) {
        self.support = support
    }
    
    var top: OWConstraintItem {
        return OWConstraintItem(target: self.target, attributes: OWConstraintAttributes.top)
    }
    
    var bottom: OWConstraintItem {
        return OWConstraintItem(target: self.target, attributes: OWConstraintAttributes.bottom)
    }
    
    var height: OWConstraintItem {
        return OWConstraintItem(target: self.target, attributes: OWConstraintAttributes.height)
    }
}
