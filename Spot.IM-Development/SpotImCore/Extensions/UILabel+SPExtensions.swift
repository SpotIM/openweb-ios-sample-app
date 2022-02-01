//
//  UILabel+SPExtensions.swift
//  Spot.IM-Core
//
//  Created by Andriy Fedin on 08/10/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit

internal extension UILabel {

    /// Index of character in contained attributed string at requested coordinates
    /// - Parameter point: coordinates in the frame of the label
    func indexOfAttributedTextCharacterAtPoint(point: CGPoint, text: NSAttributedString = NSAttributedString(string: "")) -> Int {
        guard let attributedText = self.attributedText else { return NSNotFound }
        let textStorage = NSTextStorage(attributedString: attributedText)
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)
        let textContainer = NSTextContainer(size: CGSize(width: frame.width, height: CGFloat.greatestFiniteMagnitude) )
        textContainer.lineFragmentPadding = 0
        textContainer.maximumNumberOfLines = numberOfLines
        textContainer.lineBreakMode = lineBreakMode
        layoutManager.addTextContainer(textContainer)

        let index = layoutManager.characterIndex(
            for: point,
            in: textContainer,
            fractionOfDistanceBetweenInsertionPoints: nil
        )

        return index
    }

}
