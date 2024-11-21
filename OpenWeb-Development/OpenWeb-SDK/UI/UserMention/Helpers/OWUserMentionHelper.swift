//
//  OWUserMentionHelper.swift
//  OpenWebSDK
//
//  Created by Refael Sommer on 14/03/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

import Foundation

class OWUserMentionHelper {
    static var mentionsEnabled = true

    private struct Metrics {
        static let mentionString = "@"
        static let mentionCharecter: Character = "@"
        static let jsonRegexPattern = "\\@\\{(.*?)\\}"
    }

    static func setupInitialMentionsIfNeeded(userMentionVM: OWUserMentionViewViewModeling,
                                             commentCreationType: OWCommentCreationTypeInternal,
                                             servicesProvider: OWSharedServicesProviding,
                                             postId: OWPostId?) {
        guard OWUserMentionHelper.mentionsEnabled else { return }
        let commentsCacheService = servicesProvider.commentsInMemoryCacheService()
        switch commentCreationType {
        case .comment:
            guard let postId,
                  let commentCreationCache = commentsCacheService[.comment(postId: postId)] else { return }
            userMentionVM.inputs.initialMentions.onNext(commentCreationCache.commentUserMentions)
        case .replyToComment(originComment: let originComment):
            guard let postId,
                  let originCommentId = originComment.id,
                  let commentCreationCache = commentsCacheService[.reply(postId: postId, commentId: originCommentId)] else { return }
            userMentionVM.inputs.initialMentions.onNext(commentCreationCache.commentUserMentions)
        case .edit(comment: let comment):
            guard let postId,
                  let commentId = comment.id,
                  let commentCreationCache = commentsCacheService[.edit(postId: postId, commentId: commentId)] else { return }
            userMentionVM.inputs.initialMentions.onNext(commentCreationCache.commentUserMentions)
        }
    }

    static func replaceTextWithRangeIsInBounds(of text: String, replaceText: String, range: NSRange) -> Bool {
        return (replaceText.isEmpty && (range.location + range.length) <= text.utf16.count) ||
        (replaceText.utf16.count + range.location + range.length < text.utf16.count) ||
        (range.length == 0 && range.location <= text.utf16.count)
    }

    static func getUserMentionTextData(replaceData: OWTextViewReplaceData, text: String) -> OWUserMentionTextData? {
        let utf8Range = replaceData.range
        if replaceTextWithRangeIsInBounds(of: text, replaceText: replaceData.text, range: utf8Range) {
            let startIndex = text.utf16.index(text.utf16.startIndex, offsetBy: utf8Range.lowerBound)
            let endIndex = text.utf16.index(startIndex, offsetBy: utf8Range.length)
            let stringRange = startIndex..<endIndex
            let textData = OWUserMentionTextData(text: text, cursorRange: stringRange, replacingText: replaceData.text)
            return textData
        }
        return nil
    }

    static func updateMentionRanges(with textData: OWUserMentionTextData, mentionsData: OWUserMentionData) -> OWUserMentionTextData? {
        guard OWUserMentionHelper.mentionsEnabled else { return nil }
        guard let replacingText = textData.replacingText else { return nil }
        let cursorRange = NSRange(textData.cursorRange, in: textData.text)
        var mentions: [OWUserMentionObject] = mentionsData.mentions.filter { cursorRange.location >= $0.range.location + $0.range.length }
        let mentionsToCheck = mentionsData.mentions.filter { cursorRange.location <= $0.range.location }
        var mentionsToDelete: [OWUserMentionObject] = mentionsData.mentions.filter { cursorRange.location < $0.range.location + $0.range.length }
        for mention in mentionsToCheck {
            guard let mentionRange = Range(NSRange(location: mention.range.location + 1, length: mention.range.length - 1), in: textData.text),
               !(textData.cursorRange ~= mentionRange),
                textData.cursorRange.upperBound <= mentionRange.lowerBound  else {
                    if let mentionRange = Range(NSRange(location: mention.range.location + 1, length: mention.range.length - 1), in: textData.text),
                       textData.cursorRange ~= mentionRange {
                        mentionsToDelete.removeAll(where: { $0.id == mention.id })
                    } else {
                        mentionsToDelete.append(mention)
                    }
                    continue
                }
            // Update mentionRange since replacing text before this mention
            let distance = textData.text.utf16.distance(from: textData.cursorRange.lowerBound, to: textData.cursorRange.upperBound)
            let addToRange = -distance + replacingText.utf16.count
            let updatedMentionRange: NSRange = {
                var range = mention.range
                range.location += addToRange
                range.length = mention.text.utf16.count
                return range
            }()
            mention.range = updatedMentionRange
            mentions.append(mention)
            mentionsToDelete.removeAll(where: { $0.id == mention.id })
        }

        mentionsData.mentions = mentions

        if let mention = mentionsToDelete.first,
           let mentionRange = Range(mention.range, in: textData.text) {
            var text = textData.text
            mention.range.length -= 1 // already deleted by textView
            if let cursorUpdatedRange = Range(mention.range, in: text) {
                let updatedTextData = OWUserMentionTextData(text: textData.text, cursorRange: cursorUpdatedRange, replacingText: "")
                _ = updateMentionRanges(with: updatedTextData, mentionsData: mentionsData)
                text.removeSubrange(mentionRange)
                let cursorLocation = cursorUpdatedRange.lowerBound..<cursorUpdatedRange.lowerBound
                return OWUserMentionTextData(text: text, cursorRange: cursorLocation, replacingText: nil)
            }
        }
        return nil
    }

    static func modifiedCursorRange(from cursorRange: Range<String.Index>, mentions: [OWUserMentionObject], text: String) -> Range<String.Index>? {
        guard !mentions.isEmpty, !text.isEmpty else { return nil }
        var cursorNSRange = NSRange(cursorRange, in: text)
        let mentionsToCheck: [OWUserMentionObject] = mentions.filter {
            NSIntersectionRange(cursorNSRange, $0.range).length > 0
        }
        for mention in mentionsToCheck {
            let cursorEndIndex = cursorNSRange.location + cursorNSRange.length
            let mentionEndIndex = mention.range.location + mention.range.length
            if cursorRange.lowerBound == cursorRange.upperBound,
               cursorNSRange.location != mention.range.location {
                cursorNSRange.location = mentionEndIndex
            } else {
                if cursorNSRange.location > mention.range.location {
                    cursorNSRange.location = mention.range.location
                }
                if cursorEndIndex < mentionEndIndex {
                    cursorNSRange.length += mentionEndIndex - cursorEndIndex
                }
            }
        }
        let range = Range(cursorNSRange, in: text)
        return range != cursorRange ? range : nil
    }

    static func getAttributedText(for textViewText: String,
                                  mentionsData: OWUserMentionData,
                                  currentMentionRange: Range<String.Index>?) -> NSAttributedString? {
        guard !textViewText.isEmpty else { return nil }

        let attributedText: NSMutableAttributedString = NSMutableAttributedString(string: textViewText)

        let brandColor = OWColorPalette.shared.color(type: .brandColor, themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle)

        for mention in mentionsData.mentions {
            if (mention.range.location + mention.range.length) <= attributedText.length {
                attributedText.addAttribute(NSAttributedString.Key.foregroundColor,
                                            value: brandColor,
                                            range: mention.range)
            }
        }

        if let currentMentionRange {
            let range = NSRange(currentMentionRange, in: textViewText)
            attributedText.addAttribute(NSAttributedString.Key.foregroundColor,
                                        value: brandColor,
                                        range: range)
        }
        return attributedText
    }

    static func addUserMention(to mentionsData: OWUserMentionData, textData: OWUserMentionTextData, id: String, displayName: String, randomGenerator: OWRandomGeneratorProtocol) {
        guard OWUserMentionHelper.mentionsEnabled else { return }
        let textToCursor = textData.textToCursor
        let mentionDisplayText = Metrics.mentionString + displayName
        guard let indexOfMention = textToCursor.lastIndex(of: Metrics.mentionCharecter) else { return }
        let textWithMention = String(textToCursor[..<indexOfMention]) + mentionDisplayText
        let range = indexOfMention..<textWithMention.endIndex
        let selectedRange = NSRange(range, in: textWithMention)
        let userMentionObject = OWUserMentionObject(id: randomGenerator.generateSuperiorUUID(),
                                                    userId: id,
                                                    text: mentionDisplayText,
                                                    range: selectedRange)
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

    static func getUserMentionTextDataAfterTapped(mentionsData: OWUserMentionData,
                                                  textAfterMention: String) -> OWUserMentionTextData? {
        guard OWUserMentionHelper.mentionsEnabled else { return nil }
        guard let tappedMentionString = mentionsData.tappedMentionString
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
        guard OWUserMentionHelper.mentionsEnabled else { return text }
        var text = text
        var rangeLocationAccumulate = 0
        for mention in mentions {
            let mentionJsonString = mention.jsonString
            var range = NSRange(location: mention.range.location, length: mention.range.length)
            range.location += rangeLocationAccumulate
            text = text.replacingOccurrences(of: mention.text, with: mentionJsonString, range: Range(range, in: text))
            rangeLocationAccumulate += mentionJsonString.utf16.count - mention.text.utf16.count
        }
        return text
    }

    static func addUserMentionDisplayNames(to text: String, mentions: [OWUserMentionObject]?) -> String {
        guard OWUserMentionHelper.mentionsEnabled else { return text }
        guard let mentions else { return text }
        var text = text
        for mention in mentions {
            text = text.replacingOccurrences(of: mention.jsonString, with: mention.text)
        }
        return text
    }

    /// This function creates an array of OWUserMentionObjects and also inserts the user mentions display names - @JohnSmith into the OWComment text instead of the user mention content json ids @{"id"="xxxxxxxxxx"} found in the comment text
    @discardableResult static func createUserMentions(from comment: inout OWComment) -> [OWUserMentionObject] {
        guard OWUserMentionHelper.mentionsEnabled else { return [] }
        guard var text = comment.text?.text else { return [] }
        let jsonRanges = parseJsonsInText(text: text)
        var userMentions: [OWUserMentionObject] = []
        var rangeLocationAccumulate = 0
        let originalText = text
        for (contentId, jsonRange) in jsonRanges {
            if let userMention = comment.userMentions[contentId] {
                var mentionRange = NSRange(jsonRange, in: originalText)
                var jsonNSRange = mentionRange
                let displayName = Metrics.mentionString + userMention.displayName
                mentionRange.length = displayName.utf16.count
                mentionRange.location += rangeLocationAccumulate
                jsonNSRange.location += rangeLocationAccumulate
                let owUserMention = OWUserMentionObject(id: contentId, userId: userMention.userId, text: displayName, range: mentionRange)
                let jsonString = owUserMention.jsonString
                rangeLocationAccumulate += owUserMention.text.utf16.count - jsonString.utf16.count
                text = text.replacingOccurrences(of: jsonString, with: owUserMention.text, range: Range(jsonNSRange, in: text))
                userMentions.append(owUserMention)
            }
        }
        comment.text?.text = text
        return userMentions
    }

    // Parsing jsons @{} in text with comment content ids
    private static func parseJsonsInText(text: String) -> [(String, Range<String.Index>)] {
        guard OWUserMentionHelper.mentionsEnabled else { return [] }
        var results = [(String, Range<String.Index>)]()
        do {
            let regex = try NSRegularExpression(pattern: Metrics.jsonRegexPattern, options: [])
            regex.enumerateMatches(in: text, range: NSRange(location: 0, length: text.utf16.count)) { result, _, _ in
                if let r = result?.range(at: 0), let range = Range(r, in: text) {
                    let json = String(text[range]).dropFirst()
                    do {
                        if let data = json.data(using: .utf16),
                           let dict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                           let contentId = dict["id"] as? String {
                            results.append((contentId, range))
                        }
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
        } catch {
            print(error.localizedDescription)
        }
        return results
    }

    static func filterUserMentions(in text: String, userMentions: [OWUserMentionObject], readMoreRange: NSRange?) -> [OWUserMentionObject] {
        guard OWUserMentionHelper.mentionsEnabled else { return [] }
        guard let readMoreRange else { return userMentions }
        let utf16Count = text.utf16.count
        var filtered = userMentions.filter { $0.range.location <= utf16Count }
        if let last = filtered.last {
            filtered.removeLast()
            let last = OWUserMentionObject(id: last.id, userId: last.userId, text: last.text, range: last.range)
            if (last.range.location + last.range.length) >= utf16Count - readMoreRange.length {
                let subtract = utf16Count - (last.range.location + last.range.length) - readMoreRange.length
                last.range.length += subtract
            }
            guard last.range.length > 0 else { return filtered }
            filtered.append(last)
        }
        return filtered
    }

    static func addMockCommentWithUserMention(comment: inout OWComment) {
        comment.userMentions["b4edd1995e6bdc7fc7bf3f6d95fcc97b"] = OWComment.Content.UserMention(id: "b4edd1995e6bdc7fc7bf3f6d95fcc97b", userId: "1234", displayName: "Alon")
        comment.userMentions["f42518e26df91e6af00fb62ce8a39a2f"] = OWComment.Content.UserMention(id: "f42518e26df91e6af00fb62ce8a39a2f", userId: "4567", displayName: "Alon")
        let user1 = SPUser()
        user1.id = "1234"
        user1.userId = "1234"
        user1.displayName = "Refael Sommer"

        let user2 = SPUser()
        user2.id = "4567"
        user2.userId = "4567"
        user2.displayName = "Alon Haiut"

        comment.users = comment.users ?? [:]
        comment.users?["1234"] = user1
        comment.users?["4567"] = user2
        // swiftlint:disable line_length
        comment.text?.text = "Test 🦋⃤♡⃤🌈⃤  mentions @{\"id\": \"b4edd1995e6bdc7fc7bf3f6d95fcc97b\"} and mention @{\"id\": \"f42518e26df91e6af00fb62ce8a39a2f\"} and third @{\"id\": \"f42518e26df91e6af00fb62ce8a39a2f\"} Test @{\"id\": \"b4edd1995e6bdc7fc7bf3f6d95fcc97b\"} and mention @{\"id\": \"f42518e26df91e6af00fb62ce8a39a2f\"} 🦋⃤♡⃤🌈⃤  and third @{\"id\": \"f42518e26df91e6af00fb62ce8a39a2f\"} Test mentions @{\"id\": \"b4edd1995e6bdc7fc7bf3f6d95fcc97b\"} and mention @{\"id\": \"f42518e26df91e6af00fb62ce8a39a2f\"} and third @{\"id\": \"f42518e26df91e6af00fb62ce8a39a2f\"} Test mentions @{\"id\": \"b4edd1995e6bdc7fc7bf3f6d95fcc97b\"} and mention @{\"id\": \"f42518e26df91e6af00fb62ce8a39a2f\"} and third @{\"id\": \"f42518e26df91e6af00fb62ce8a39a2f\"} Test mentions @{\"id\": \"b4edd1995e6bdc7fc7bf3f6d95fcc97b\"} and mention @{\"id\": \"f42518e26df91e6af00fb62ce8a39a2f\"} and third @{\"id\": \"f42518e26df91e6af00fb62ce8a39a2f\"}"
        // swiftlint:enable line_length
    }
}
