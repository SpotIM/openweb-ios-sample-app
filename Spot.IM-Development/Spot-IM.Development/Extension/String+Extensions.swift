//
//  String+Extensions.swift
//  Spot-IM.Development
//
//  Created by Itay Dressler on 15/08/2019.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation
import UIKit

extension String {
    enum TruncationPosition {
        case head
        case middle
        case tail
    }
    
    func truncated(limit: Int, position: TruncationPosition = .tail, leader: String = "...") -> String {
        guard self.count > limit else { return self }
        
        switch position {
        case .head:
            return leader + self.suffix(limit)
        case .middle:
            let headCharactersCount = Int(ceil(Float(limit - leader.count) / 2.0))
            
            let tailCharactersCount = Int(floor(Float(limit - leader.count) / 2.0))
            
            return "\(self.prefix(headCharactersCount))\(leader)\(self.suffix(tailCharactersCount))"
        case .tail:
            return self.prefix(limit) + leader
        }
    }
    
    var blueRoundedButton: UIButton {
        return self.button(color: ColorPalette.shared.color(type: .blue))
    }
    
    var darkGrayRoundedButton: UIButton {
        return self.button(color: ColorPalette.shared.color(type: .darkGrey))
    }
    
    func button(color: UIColor) -> UIButton {
        return self
            .button
            .adjustsFontSizeToFitWidth
            .backgroundColor(color)
            .textColor(ColorPalette.shared.color(type: .extraLightGrey))
            .corner(radius: 16)
            .withHorizontalPadding(10)
            .font(FontBook.paragraphBold)
    }
}
