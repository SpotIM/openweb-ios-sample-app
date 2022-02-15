//
//  OWConstraintMakerRelatable+Extensions.swift
//  SpotImCore
//
//  Created by Alon Haiut on 06/02/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit

extension OWConstraintMakerRelatable {
  
    @discardableResult
    func equalToSuperview<T: OWConstraintRelatableTarget>(_ closure: (UIView) -> T, _ file: String = #file, line: UInt = #line) -> OWConstraintMakerEditable {
        guard let other = self.description.item.superview else {
            fatalError("OWSnapKit - Expected superview but found nil when attempting make constraint `equalToSuperview`.")
        }
        return self.relatedTo(closure(other), relation: .equal, file: file, line: line)
    }
  
    @discardableResult
    func lessThanOrEqualToSuperview<T: OWConstraintRelatableTarget>(_ closure: (UIView) -> T, _ file: String = #file, line: UInt = #line) -> OWConstraintMakerEditable {
        guard let other = self.description.item.superview else {
            fatalError("OWSnapKit - Expected superview but found nil when attempting make constraint `lessThanOrEqualToSuperview`.")
        }
        return self.relatedTo(closure(other), relation: .lessThanOrEqual, file: file, line: line)
    }
  
    @discardableResult
    func greaterThanOrEqualTo<T: OWConstraintRelatableTarget>(_ closure: (UIView) -> T, _ file: String = #file, line: UInt = #line) -> OWConstraintMakerEditable {
        guard let other = self.description.item.superview else {
            fatalError("OWSnapKit - Expected superview but found nil when attempting make constraint `greaterThanOrEqualToSuperview`.")
        }
        return self.relatedTo(closure(other), relation: .greaterThanOrEqual, file: file, line: line)
    }
}
