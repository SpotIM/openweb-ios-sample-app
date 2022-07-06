//
//  OWConstraintViewDSL.swift
//  SpotImCore
//
//  Created by Alon Haiut on 06/02/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit


struct OWConstraintViewDSL: OWConstraintAttributesDSL {
    
    @discardableResult
    func prepareConstraints(_ closure: (_ make: OWConstraintMaker) -> Void) -> [OWConstraint] {
        return OWConstraintMaker.prepareConstraints(item: self.view, closure: closure)
    }
    
    func makeConstraints(_ closure: (_ make: OWConstraintMaker) -> Void) {
        OWConstraintMaker.makeConstraints(item: self.view, closure: closure)
    }
    
    func remakeConstraints(_ closure: (_ make: OWConstraintMaker) -> Void) {
        OWConstraintMaker.remakeConstraints(item: self.view, closure: closure)
    }
    
    func updateConstraints(_ closure: (_ make: OWConstraintMaker) -> Void) {
        OWConstraintMaker.updateConstraints(item: self.view, closure: closure)
    }
    
    func removeConstraints() {
        OWConstraintMaker.removeConstraints(item: self.view)
    }
    
    var contentHuggingHorizontalPriority: Float {
        get {
            return self.view.contentHuggingPriority(for: .horizontal).rawValue
        }
        nonmutating set {
            self.view.setContentHuggingPriority(OWLayoutPriority(rawValue: newValue), for: .horizontal)
        }
    }
    
    var contentHuggingVerticalPriority: Float {
        get {
            return self.view.contentHuggingPriority(for: .vertical).rawValue
        }
        nonmutating set {
            self.view.setContentHuggingPriority(OWLayoutPriority(rawValue: newValue), for: .vertical)
        }
    }
    
    var contentCompressionResistanceHorizontalPriority: Float {
        get {
            return self.view.contentCompressionResistancePriority(for: .horizontal).rawValue
        }
        nonmutating set {
            self.view.setContentCompressionResistancePriority(OWLayoutPriority(rawValue: newValue), for: .horizontal)
        }
    }
    
    var contentCompressionResistanceVerticalPriority: Float {
        get {
            return self.view.contentCompressionResistancePriority(for: .vertical).rawValue
        }
        nonmutating set {
            self.view.setContentCompressionResistancePriority(OWLayoutPriority(rawValue: newValue), for: .vertical)
        }
    }
    
    var target: AnyObject? {
        return self.view
    }
    
    private let view: UIView
    
    init(view: UIView) {
        self.view = view
    }
}

