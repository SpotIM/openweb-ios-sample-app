//
//  OWCommentCreationTypeInternal+Extensions.swift
//  OpenWeb-Development
//
//  Created by Refael Sommer on 11/12/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

extension OWCommentCreationTypeInternal {
    func attributedStringForReplyTo(displayName: String) -> NSAttributedString {
        let boldUserNameAttrs = [NSAttributedString.Key.font: OWFontBook.shared.font(typography: .bodyContext)]
        switch self {
        case .edit:
            let editingReplyText = String(format: OWLocalize.string("EditingReply"), displayName)
            let attributedString = NSMutableAttributedString(string: editingReplyText)
            if let rangeOfName = attributedString.string.range(of: displayName) {
                attributedString.addAttributes(boldUserNameAttrs, range: NSRange(rangeOfName, in: attributedString.string))
            }
            return attributedString
        default:
            let replyText = OWLocalize.string("ReplyingTo")
            let attributedString = NSMutableAttributedString(string: replyText)
            let boldUserNameString = NSMutableAttributedString(string: displayName, attributes: boldUserNameAttrs)
            attributedString.append(boldUserNameString)
            return attributedString
        }
    }
}
