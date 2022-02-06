//
//  OWConstraintItem.swift
//  SpotImCore
//
//  Created by Alon Haiut on 06/02/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit

class OWConstraintItem {
    
    internal weak var target: AnyObject?
    internal let attributes: OWConstraintAttributes
    
    internal init(target: AnyObject?, attributes: OWConstraintAttributes) {
        self.target = target
        self.attributes = attributes
    }
    
    internal var layoutConstraintItem: OWLayoutConstraintItem? {
        return self.target as? OWLayoutConstraintItem
    }
    
}

func ==(lhs: OWConstraintItem, rhs: OWConstraintItem) -> Bool {
    // pointer equality
    guard lhs !== rhs else {
        return true
    }
    
    // must both have valid targets and identical attributes
    guard let target1 = lhs.target,
          let target2 = rhs.target,
          target1 === target2 && lhs.attributes == rhs.attributes else {
            return false
    }
    
    return true
}

