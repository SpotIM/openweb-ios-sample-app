//
//  OWRangeGestureRecognizer.swift
//  SpotImCore
//
//  Created by Refael Sommer on 03/05/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit
import Foundation

class RangeGestureRecognizer: UITapGestureRecognizer {
    var stringRange: String?
    var function: OWBasicCompletion?

    func didTapAttributedText(in label: UILabel, inRange targetRange: NSRange) -> Bool {

        var offsetXDivisor: CGFloat
        switch label.textAlignment {
        case .center: offsetXDivisor = 0.5
        case .right: offsetXDivisor = 1.0
        default: offsetXDivisor = 0.0
        }

        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        guard let attributedText = label.attributedText else { return false }
        let textStorage = NSTextStorage(attributedString: attributedText)

        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)

        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize

        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * offsetXDivisor - textBoundingBox.origin.x,
                                          y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x,
                                                     y: locationOfTouchInLabel.y - textContainerOffset.y)
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)

        return targetRange.location != NSNotFound && NSLocationInRange(indexOfCharacter, targetRange)
    }
}
