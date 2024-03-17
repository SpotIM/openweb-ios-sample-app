//
//  OWUserMentionHelper.swift
//  SpotImCore
//
//  Created by Refael Sommer on 14/03/2024.
//  Copyright © 2024 Spot.IM. All rights reserved.
//

import Foundation

class OWUserMentionHelper {
    fileprivate struct Metrics {
        static let mentionString = "@"
        static let mentionCharecter: Character = "@"
        static let jsonRegexPattern = "\\@\\{(.*?)\\}"
    }

    static func getUserMentionTextData(replaceData: OWTextViewReplaceData, text: String) -> OWUserMentionTextData {
        let utf8Range = replaceData.range
        let startIndex = text.utf16.index(text.utf16.startIndex, offsetBy: utf8Range.lowerBound)
        let endIndex = text.utf16.index(startIndex, offsetBy: utf8Range.length)
        let stringRange = startIndex..<endIndex
        let textData = OWUserMentionTextData(text: text, cursorRange: stringRange, replacingText: replaceData.text)
        return textData
    }

    static func updateMentionRanges(with textData: OWUserMentionTextData, mentionsData: OWUserMentionData) {
        guard let replacingText = textData.replacingText,
              let cursorRange = textData.text.nsRange(from: textData.cursorRange) else { return }
        var mentions: [OWUserMentionObject] = mentionsData.mentions.filter { cursorRange.location >= $0.range.location + $0.range.length }
        let mentionsToCheck = mentionsData.mentions.filter { cursorRange.location <= $0.range.location }
        for mention in mentionsToCheck {
            if let mentionRange = Range(NSRange(location: mention.range.location + 1, length: mention.range.length - 1), in: textData.text),
               !(textData.cursorRange ~= mentionRange) {
                // update mention that replace is affecting
                if textData.cursorRange.upperBound <= mentionRange.lowerBound { // Update mentionRange since replacing text before this mention
                    let distance = textData.text.utf16.distance(from: textData.cursorRange.lowerBound, to: textData.cursorRange.upperBound)
                    let addToRange = -distance + replacingText.utf16.count
                    let updatedMentionRange: NSRange = {
                        var range = mention.range
                        range.location += addToRange
                        range.length = mention.text.utf16.count
                        return range
                    }()
                    mention.range = updatedMentionRange
                }
                mentions.append(mention)
            }
        }
        mentionsData.mentions = mentions
    }

    static func getAttributedText(for textViewText: String,
                                  mentionsData: OWUserMentionData,
                                  currentMentionRange: Range<String.Index>?) -> NSAttributedString? {
        guard !textViewText.isEmpty else { return nil }

        let attributedText: NSMutableAttributedString = NSMutableAttributedString(string: textViewText)

        let brandColor = OWColorPalette.shared.color(type: .brandColor, themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle)

        for mention in mentionsData.mentions {
            attributedText.addAttribute(NSAttributedString.Key.foregroundColor,
                                        value: brandColor,
                                        range: mention.range)
        }

        if let currentMentionRange = currentMentionRange,
           let range = textViewText.nsRange(from: currentMentionRange) {
            attributedText.addAttribute(NSAttributedString.Key.foregroundColor,
                                        value: brandColor,
                                        range: range)
        }
        return attributedText
    }

    static func addUserMention(to mentionsData: OWUserMentionData, textData: OWUserMentionTextData, id: String, displayName: String) {
        let textToCursor = textData.textToCursor
        let mentionDisplayText = Metrics.mentionString + displayName
        guard let indexOfMention = textToCursor.lastIndex(of: Metrics.mentionCharecter) else { return }
        let textWithMention = String(textToCursor[..<indexOfMention]) + mentionDisplayText
        let range = indexOfMention..<textWithMention.endIndex
        guard let selectedRange = textWithMention.nsRange(from: range) else { return }
        let userMentionObject = OWUserMentionObject(userId: id, text: mentionDisplayText, range: selectedRange)

        let replaceRange = range.lowerBound..<textToCursor.utf16.endIndex
        if replaceRange.upperBound < textData.text.utf16.endIndex {
            let mentions = mentionsData.mentions.filter { $0.range.location >= textToCursor.utf16.count }
            for mention in mentions {
                let replacedLength = textToCursor.utf16.distance(from: replaceRange.lowerBound, to: replaceRange.upperBound)
                // replacedLength + 1 is due to the space added when tapping a user mention
                mention.range.location += mentionDisplayText.utf16.count - replacedLength + 1
                mention.range.length = mention.text.utf16.count
            }
            // Add new mention in the right position
            let index = mentionsData.mentions.count - mentions.count
            mentionsData.mentions.insert(userMentionObject, at: index)
        } else {
            mentionsData.mentions.append(userMentionObject)
        }
        mentionsData.tappedMentionString = textWithMention
    }

    static func getUserMentionTextDataAfterTapped(mentionsData: OWUserMentionData, currentMentionRange: Range<String.Index>?, textViewText: String) -> OWUserMentionTextData? {
        guard let currentMentionRange = currentMentionRange,
              let tappedMentionString = mentionsData.tappedMentionString,
              let textAfterMention = String(textViewText.utf16[currentMentionRange.upperBound...])
        else { return nil }
        let tappedMentionWithSpace = tappedMentionString + " "
        let utf8Range = NSRange(location: 0, length: tappedMentionWithSpace.utf16.count)
        let text = tappedMentionWithSpace + textAfterMention
        let startIndex = tappedMentionWithSpace.utf16.index(tappedMentionWithSpace.utf16.startIndex, offsetBy: utf8Range.lowerBound)
        let endIndex = tappedMentionWithSpace.utf16.index(startIndex, offsetBy: utf8Range.length)
        let stringRange = endIndex..<endIndex
        return OWUserMentionTextData(text: text, cursorRange: stringRange, replacingText: nil)
    }

    static func addUserMentionIds(to text: String, mentions: [OWUserMentionObject]) -> String {
        var text = text
        var rangeLocationAccumulate = 0
        for mention in mentions {
            let mentionJsonString = mention.jsonString
            mention.range.location += rangeLocationAccumulate
            text = text.replacingOccurrences(of: mention.text, with: mentionJsonString, range: Range(mention.range, in: text))
            rangeLocationAccumulate += mentionJsonString.utf16.count - mention.text.utf16.count
        }
        return text
    }

    static func addUserMentionDisplayNames(to text: String, mentions: [OWUserMentionObject]?) -> String {
        guard let mentions = mentions else { return text }
        var text = text
        for mention in mentions {
            text = text.replacingOccurrences(of: mention.jsonString, with: mention.text)
        }
        return text
    }

    static func createUserMentions(from comment: inout OWComment) -> [OWUserMentionObject] {
        guard var text = comment.text?.text else { return [] }
        let jsonRanges = parseJsonsInText(text: text)
        var userMentions: [OWUserMentionObject] = []
        for (contentId, range) in jsonRanges {
            if let userMention = comment.userMentions[contentId],
               let user = comment.users?[userMention.userId],
               let displayName = user.displayName,
               var nsRange = text.nsRange(from: range) {
                let displayName = "@" + displayName
                nsRange.length = displayName.utf16.count
                let owUserMention = OWUserMentionObject(id: contentId, userId: userMention.userId, text: displayName, range: nsRange)
                text = text.replacingOccurrences(of: owUserMention.jsonString, with: owUserMention.text, range: range)
                userMentions.append(owUserMention)
            }
        }
        comment.text?.text = text
        return userMentions
    }

    // Parsing jsons @{} in text with ids
    fileprivate static func parseJsonsInText(text: String) -> [(String, Range<String.Index>)] {
        var results = [(String, Range<String.Index>)]()
        do {
            let regex = try NSRegularExpression(pattern: Metrics.jsonRegexPattern, options: [])
            regex.enumerateMatches(in: text, range: NSRange(location: 0, length: text.utf16.count)) { result, _, _ in
                if let r = result?.range(at: 1), let range = Range(r, in: text) {
                    let json = "{" + String(text[range]) + "}"
                    if let data = json.data(using: .utf16) {
                        do {
                            if let dict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                                if let contentId = dict["id"] as? String {
                                    results.append((contentId, range))
                                }
                            }
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                }
            }
        } catch { }
        return results
    }
}
