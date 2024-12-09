//
//  OWUserMentionTests.swift
//  OpenWebCoreTests
//
//  Created by yonat Sharon on 2024-11-24.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import XCTest
import RxSwift
import Quick
import Nimble

@testable import OpenWebSDK

class OWUserMentionTests: QuickSpec {

    override func spec() {
        describe("Testing user mentions") {
            let text = "Hello @First Mention, how are you @Jane Doe? I'm fine @Alice Wonderland ♥️"
            let nsText = NSString(string: text)
            let mentions: [OWUserMentionObject] = [
                OWUserMentionObject(id: "1", userId: "1", text: "@First Mention", range: nsText.range(of: "@First Mention")),
                OWUserMentionObject(id: "2", userId: "2", text: "@Jane Doe", range: nsText.range(of: "@Jane Doe")),
                OWUserMentionObject(id: "3", userId: "3", text: "@Alice Wonderland", range: nsText.range(of: "@Alice Wonderland")),
            ]

            beforeEach {}
            afterEach {}

            context("don't modify selected range that doesn't cut mentions") {
                it("should not modify range when outside any mention") {
                    expect(OWUserMentionHelper.modifiedCursorRange(from: text.range(1 ..< 1), mentions: mentions, text: text))
                        .to(beNil())
                    expect(OWUserMentionHelper.modifiedCursorRange(from: text.range(0 ..< 5), mentions: mentions, text: text))
                        .to(beNil())
                }

                it("should not modify range when on the edge of mention") {
                    let startEdge = mentions[0].range.lowerBound
                    let endEdge = mentions[0].range.upperBound
                    expect(OWUserMentionHelper.modifiedCursorRange(from: text.range(startEdge ..< startEdge), mentions: mentions, text: text))
                        .to(beNil())
                    expect(OWUserMentionHelper.modifiedCursorRange(from: text.range(endEdge ..< endEdge), mentions: mentions, text: text))
                        .to(beNil())
                }

                it("should not modify range the contains whole mention") {
                    expect(OWUserMentionHelper.modifiedCursorRange(from: text.range(of: "@First Mention")!, mentions: mentions, text: text))
                        .to(beNil())
                    expect(OWUserMentionHelper.modifiedCursorRange(from: text.startIndex ..< text.endIndex, mentions: mentions, text: text))
                        .to(beNil())
                }
            }

            context("modify selected range that cuts through mentions") {
                let insideMentionIndex = mentions[0].range.lowerBound + 3

                it("should move cursor from middle of mention to end of mention") {
                    let insideMentionRange = text.range(insideMentionIndex ..< insideMentionIndex)
                    let endOfMentionRange = text.range(mentions[0].range.upperBound ..< mentions[0].range.upperBound)
                    expect(OWUserMentionHelper.modifiedCursorRange(from: insideMentionRange, mentions: mentions, text: text))
                        .to(equal(endOfMentionRange))
                }

                it("should move extend selection ending inside mention to end of mention") {
                    expect(OWUserMentionHelper.modifiedCursorRange(from: text.range(0 ..< insideMentionIndex), mentions: mentions, text: text))
                        .to(equal(text.range(0 ..< mentions[0].range.upperBound)))
                }

                it("should move extend selection starting inside mention to start of mention") {
                    let afterMentionIndex = mentions[0].range.upperBound + 3
                    expect(OWUserMentionHelper.modifiedCursorRange(from: text.range(insideMentionIndex ..< afterMentionIndex), mentions: mentions, text: text))
                        .to(equal(text.range(mentions[0].range.lowerBound ..< afterMentionIndex)))
                }
            }
        }
    }
}

extension StringProtocol {
    func range(_ range: Range<Int>) -> Range<String.Index> {
        let start = index(startIndex, offsetBy: range.lowerBound, limitedBy: endIndex) ?? startIndex
        let end = index(start, offsetBy: range.count, limitedBy: endIndex) ?? endIndex
        return start ..< end
    }
}
