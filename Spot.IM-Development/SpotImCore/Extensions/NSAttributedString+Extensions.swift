//
//  NSAttributedString+Extensions.swift
//  Spot.IM-Core
//
//  Created by Andriy Fedin on 09/10/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit

extension NSAttributedString {
    func height(withConstrainedWidth width: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = boundingRect(with: constraintRect, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)

        return ceil(boundingBox.size.height)
    }

    func width(withConstrainedHeight height: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)

        return ceil(boundingBox.width)
    }

    func isEmpty() -> Bool {
        let trimmedString = self.string.trimmingCharacters(in: .whitespacesAndNewlines)

        return trimmedString.isEmpty
    }

     func attributedStringByTrimming(charSet: CharacterSet) -> NSAttributedString {

        let modifiedString = NSMutableAttributedString(attributedString: self)
        modifiedString.trimCharactersInSet(charSet: charSet)

        return NSAttributedString(attributedString: modifiedString)
     }

    func getLines(with width: CGFloat) -> [CTLine] {

        let path = UIBezierPath(rect: CGRect(x: 0, y: 0, width: width, height: CGFloat(MAXFLOAT)))
        let frameSetterRef: CTFramesetter = CTFramesetterCreateWithAttributedString(self as CFAttributedString)
        let frameRef: CTFrame = CTFramesetterCreateFrame(frameSetterRef, CFRangeMake(0, 0), path.cgPath, nil)

        let linesNS: NSArray  = CTFrameGetLines(frameRef)

        guard let lines = linesNS as? [CTLine] else { return [] }
        return lines
    }
}

extension NSMutableAttributedString {
     func trimCharactersInSet(charSet: CharacterSet) {
        var range = (string as NSString).rangeOfCharacter(from: charSet)

         // Trim leading characters from character set.
         while range.length != 0 && range.location == 0 {
            replaceCharacters(in: range, with: "")
            range = (string as NSString).rangeOfCharacter(from: charSet)
         }

         // Trim trailing characters from character set.
        range = (string as NSString).rangeOfCharacter(from: charSet, options: .backwards)
         while range.length != 0 && NSMaxRange(range) == length {
            replaceCharacters(in: range, with: "")
            range = (string as NSString).rangeOfCharacter(from: charSet, options: .backwards)
         }
     }
}
