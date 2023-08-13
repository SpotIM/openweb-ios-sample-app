//
//  OWUserDefaultsTests.swift
//  OpenWebCoreTests
//
//  Created by Philip Kluz on 2023-08-01.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import XCTest
import RxSwift
import RxTest
import RxBlocking
import Quick
import Nimble

@testable import SpotImCore

final class OWUserDefaultsTests: QuickSpec {

    override func spec() {
        describe("OWUserDefaults") {
            var disposeBag: DisposeBag!
            var userDefaults: OWUserDefaults!
            var expectedValue: Int!
            var results: [Int]!

            let defaultValue = 123456
            let key: OWUserDefaults.OWKey<Int> = .testKey

            beforeEach {
                results = []
                expectedValue = Int.random(in: 0..<999_999)
                disposeBag = DisposeBag()
                userDefaults = OWUserDefaults(userDefaults: UserDefaults(suiteName: UUID().uuidString)!)
                userDefaults.values(key: key, defaultValue: defaultValue).subscribe { results.append($0) }.disposed(by: disposeBag)
            }

            afterEach {
                disposeBag = nil
                expectedValue = -1
                userDefaults = nil
            }

            context("using the regular api") {
                it("should save and get value") {
                    userDefaults.save(value: expectedValue, forKey: key)
                    expect(userDefaults.get(key: key)).to(equal(expectedValue))
                }

                it("should get default value") {
                    expect(userDefaults.get(key: key, defaultValue: defaultValue)).to(equal(defaultValue))
                }

                it("should remove value") {
                    userDefaults.save(value: expectedValue, forKey: key)
                    expect(userDefaults.get(key: key)).to(equal(expectedValue))
                    userDefaults.remove(key: key)
                    expect(userDefaults.get(key: key)).to(beNil())
                }
            }

            context("using the reactive api") {
                it("should observe default values") {
                    expect(results).toEventually(equal([defaultValue]))
                }

                it("should set values") {
                    userDefaults.save(value: expectedValue, forKey: key)
                    expect(results).toEventually(equal([defaultValue, expectedValue]))
                }
            }
        }
    }
}
