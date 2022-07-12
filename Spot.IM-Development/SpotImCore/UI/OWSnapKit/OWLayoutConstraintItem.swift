//
//  OWLayoutConstraintItem.swift
//  SpotImCore
//
//  Created by Alon Haiut on 06/02/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit

protocol OWLayoutConstraintItem: AnyObject {}

extension OWConstraintLayoutGuide : OWLayoutConstraintItem {}

extension UIView : OWLayoutConstraintItem {}

private var constraintsKey: UInt8 = 0

extension OWLayoutConstraintItem {
    
    func prepare() {
        if let view = self as? UIView {
            view.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    var superview: UIView? {
        if let view = self as? UIView {
            return view.superview
        }
        
        if let guide = self as? OWConstraintLayoutGuide {
            return guide.owningView
        }
        
        return nil
    }
    
    var constraints: [OWConstraint] {
        return self.constraintsSet.allObjects as! [OWConstraint]
    }
    
    func add(constraints: [OWConstraint]) {
        let constraintsSet = self.constraintsSet
        for constraint in constraints {
            constraintsSet.add(constraint)
        }
    }
    
    func remove(constraints: [OWConstraint]) {
        let constraintsSet = self.constraintsSet
        for constraint in constraints {
            constraintsSet.remove(constraint)
        }
    }
    
    private var constraintsSet: NSMutableSet {
        let constraintsSet: NSMutableSet
        
        if let existing = objc_getAssociatedObject(self, &constraintsKey) as? NSMutableSet {
            constraintsSet = existing
        } else {
            constraintsSet = NSMutableSet()
            objc_setAssociatedObject(self, &constraintsKey, constraintsSet, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        
        return constraintsSet
    }
}

