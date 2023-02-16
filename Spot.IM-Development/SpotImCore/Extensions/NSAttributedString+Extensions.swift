//
//  NSAttributedString+Extensions.swift
//  Spot.IM-Core
//
//  Created by Andriy Fedin on 09/10/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit

extension NSAttributedString {

    func clippedToLine(index: Int, width: CGFloat, clippedTextSettings: SPClippedTextSettings) -> NSAttributedString {
        guard width > 1 else { return self } // not to spoil everything before UI is layed out

        let path = UIBezierPath(rect: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        let frameSetterRef: CTFramesetter = CTFramesetterCreateWithAttributedString(self as CFAttributedString)
        let frameRef: CTFrame = CTFramesetterCreateFrame(frameSetterRef, CFRangeMake(0, 0), path.cgPath, nil)
        let linesNS: NSArray = CTFrameGetLines(frameRef)

        guard let lines = linesNS as? [CTLine], !lines.isEmpty else { return self }

        var collapsedText: NSAttributedString = NSAttributedString()

        if index >= linesNS.count {
            collapsedText = self
        } else if clippedTextSettings.isCollapsed {
            collapsedText = readMoreAppended(with: index, lines, width)
        } else {
            collapsedText = readLessAppended()
        }

        if clippedTextSettings.isEdited {
            collapsedText = readEditedAppended(
                text: collapsedText,
                fontPointSize: clippedTextSettings.fontPointSize
            )
        }

        return collapsedText

    }

    private func handleCollapsingOfText(index: Int,
                                        width: CGFloat,
                                        isCollapsed: Bool,
                                        linesNS: NSArray,
                                        lines: [CTLine]) -> NSAttributedString {
        if index >= linesNS.count {
            return self
        } else if isCollapsed {
            return readMoreAppended(with: index, lines, width)
        } else {
            return readLessAppended()
        }
    }

    private func readMoreAppended(with index: Int, _ lines: [CTLine], _ width: CGFloat) -> NSAttributedString {

        let slice = lines[0...index - 1]
        var lastLineLength = 0
        var totalLength = slice.reduce(into: 0) { (tempCount, line) in
            lastLineLength = CTLineGetGlyphCount(line)
            tempCount += lastLineLength
        }

        var attribs = self.attributes(at: totalLength - 1, effectiveRange: nil)

        let ellipsis = NSAttributedString(
            string: " ... ",
            attributes: attribs)

        attribs[.foregroundColor] = UIColor.clearBlue

        let readMore = NSMutableAttributedString(
            string: LocalizationManager.localizedString(key: "Read More"),
            attributes: attribs)

        readMore.insert(ellipsis, at: 0)

        let readMoreWidth = readMore.width(withConstrainedHeight: .greatestFiniteMagnitude)

        // check wether additional last line clipping is needed
        let lastLineRange = NSRange(location: totalLength - lastLineLength, length: lastLineLength)
        let lastLine = attributedSubstring(from: lastLineRange)
        let lastLineWidth = lastLine.width(withConstrainedHeight: .greatestFiniteMagnitude)

        if lastLineWidth + readMoreWidth > width {
            totalLength -= lastLineLength / 2
        }

        let clippedSelf = attributedSubstring(from: NSRange(location: 0, length: totalLength))
        let trimmedSelf = clippedSelf.attributedStringByTrimming(charSet: .whitespacesAndNewlines)
        let mutableSelf = trimmedSelf.mutableCopy() as? NSMutableAttributedString
        mutableSelf?.append(readMore)

        return mutableSelf ?? self
    }

    private func readLessAppended() -> NSAttributedString {
        var attribs = self.attributes(at: length - 1, effectiveRange: nil)
        attribs[.foregroundColor] = UIColor.clearBlue

        let readLess = NSAttributedString(
            string: LocalizationManager.localizedString(key: "Read Less"),
            attributes: attribs)

        let mutableSelf = mutableCopy() as? NSMutableAttributedString
        mutableSelf?.append(readLess)

        return mutableSelf ?? self
    }

    private func readEditedAppended(text: NSAttributedString, fontPointSize: CGFloat) -> NSAttributedString {

        let editedTextAttributes: [NSAttributedString.Key: Any] = [
                       .foregroundColor: UIColor.gray,
                       .font: UIFont.italicSystemFont(ofSize: fontPointSize)
        ]

        let editedText = NSAttributedString(string: LocalizationManager.localizedString(key: "Edited"), attributes: editedTextAttributes)

        let mutableSelf = text.mutableCopy() as? NSMutableAttributedString
        mutableSelf?.append(editedText)

        return mutableSelf ?? self
    }

}

// MARK: - Sizes

extension NSAttributedString {

    func height(withConstrainedWidth width: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)

        return ceil(boundingBox.height)
    }

    func width(withConstrainedHeight height: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)

        return ceil(boundingBox.width)
    }

}

// MARK: - Trimming

internal extension NSAttributedString {

     func attributedStringByTrimming(charSet: CharacterSet) -> NSAttributedString {

        let modifiedString = NSMutableAttributedString(attributedString: self)
        modifiedString.trimCharactersInSet(charSet: charSet)

        return NSAttributedString(attributedString: modifiedString)
     }
}

internal extension NSMutableAttributedString {

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

extension NSMutableParagraphStyle {

    func updateAlignment() {
        if LocalizationManager.currentLanguage?.isRightToLeft ?? false {
            alignment = .right
        } else {
            alignment = .left
        }
    }
}

struct SPClippedTextSettings {
    var isCollapsed: Bool
    var isEdited: Bool
    var fontPointSize: CGFloat = CGFloat(0.0)

    init(collapsed: Bool,
         edited: Bool) {
        self.isCollapsed = collapsed
        self.isEdited = edited
    }
}
