//
//  Debugging.swift
//  SpotImCore
//
//  Created by Alon Haiut on 06/02/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit

extension OWLayoutConstraint {
    override var description: String {
        var description = "<"
        
        description += descriptionForObject(self)
        
        if let firstItem = conditionalOptional(from: self.firstItem) {
            description += " \(descriptionForObject(firstItem))"
        }
        
        if self.firstAttribute != .notAnAttribute {
            description += ".\(descriptionForAttribute(self.firstAttribute))"
        }
        
        description += " \(descriptionForRelation(self.relation))"
        
        if let secondItem = self.secondItem {
            description += " \(descriptionForObject(secondItem))"
        }
        
        if self.secondAttribute != .notAnAttribute {
            description += ".\(descriptionForAttribute(self.secondAttribute))"
        }
        
        if self.multiplier != 1.0 {
            description += " * \(self.multiplier)"
        }
        
        if self.secondAttribute == .notAnAttribute {
            description += " \(self.constant)"
        } else {
            if self.constant > 0.0 {
                description += " + \(self.constant)"
            } else if self.constant < 0.0 {
                description += " - \(abs(self.constant))"
            }
        }
        
        if self.priority.rawValue != 1000.0 {
            description += " ^\(self.priority)"
        }
        
        description += ">"
        
        return description
    }
    
}

private func descriptionForRelation(_ relation: OWLayoutRelation) -> String {
    switch relation {
    case .equal:                return "=="
    case .greaterThanOrEqual:   return ">="
    case .lessThanOrEqual:      return "<="
    @unknown default:           return "unknown"
    }
}

private func descriptionForAttribute(_ attribute: OWLayoutAttribute) -> String {
        switch attribute {
        case .notAnAttribute:       return "notAnAttribute"
        case .top:                  return "top"
        case .left:                 return "left"
        case .bottom:               return "bottom"
        case .right:                return "right"
        case .leading:              return "leading"
        case .trailing:             return "trailing"
        case .width:                return "width"
        case .height:               return "height"
        case .centerX:              return "centerX"
        case .centerY:              return "centerY"
        case .lastBaseline:         return "lastBaseline"
        case .firstBaseline:        return "firstBaseline"
        case .topMargin:            return "topMargin"
        case .leftMargin:           return "leftMargin"
        case .bottomMargin:         return "bottomMargin"
        case .rightMargin:          return "rightMargin"
        case .leadingMargin:        return "leadingMargin"
        case .trailingMargin:       return "trailingMargin"
        case .centerXWithinMargins: return "centerXWithinMargins"
        case .centerYWithinMargins: return "centerYWithinMargins"
        @unknown default:           return "unknown"
    }
}

private func conditionalOptional<T>(from object: Optional<T>) -> Optional<T> {
    return object
}

private func conditionalOptional<T>(from object: T) -> Optional<T> {
    return Optional.some(object)
}

private func descriptionForObject(_ object: AnyObject) -> String {
    let pointerDescription = String(format: "%p", UInt(bitPattern: ObjectIdentifier(object)))
    var desc = ""
    
    desc += type(of: object).description()
    
    if let object = object as? UIView {
        desc += ":\(object.OWSnp.label() ?? pointerDescription)"
    } else if let object = object as? OWLayoutConstraint {
        desc += ":\(object.label ?? pointerDescription)"
    } else {
        desc += ":\(pointerDescription)"
    }
    
    if let object = object as? OWLayoutConstraint, let file = object.constraint?.sourceLocation.0, let line = object.constraint?.sourceLocation.1 {
        desc += "@\((file as NSString).lastPathComponent)#\(line)"
    }
    
    desc += ""
    return desc
}
