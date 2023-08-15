//
//  OWUserDefaultsTests.swift
//  OpenWebCoreTests
//
//  Created by Philip Kluz on 2023-08-01.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import XCTest
import RxSwift
import Quick
import Nimble

@testable import SpotImCore

class OWUserDefaultsTests: QuickSpec {

    override func spec() {
        describe("Testing user defaults") {
            var disposeBag: DisposeBag!
            var userDefaults: OWUserDefaults!
            var randomGenerator: RandomGenerator!
            var results: [Int]!

            let defaultValue = 123456
            let key: OWUserDefaults.OWKey<Int> = .testKey

            beforeEach {
                results = []
                disposeBag = DisposeBag()
                userDefaults = OWUserDefaults(userDefaults: UserDefaults(suiteName: UUID().uuidString)!)
                randomGenerator = RandomGenerator()

                userDefaults.values(key: key, defaultValue: defaultValue)
                    .subscribe(onNext: { value in
                        results.append(value)
                    })
                    .disposed(by: disposeBag)
            }

            afterEach {}

            context("1. using the regular api") {
                it("should save and get value") {
                    let randomValue = randomGenerator.randomInt()
                    userDefaults.save(value: randomValue, forKey: key)
                    expect(userDefaults.get(key: key)).to(equal(randomValue))
                }

                it("should get default value") {
                    expect(userDefaults.get(key: key, defaultValue: defaultValue)).to(equal(defaultValue))
                }

                it("should remove value") {
                    let randomValue = randomGenerator.randomInt()
                    userDefaults.save(value: randomValue, forKey: key)
                    expect(userDefaults.get(key: key)).to(equal(randomValue))
                    userDefaults.remove(key: key)
                    expect(userDefaults.get(key: key)).to(beNil())
                }
            }

            context("2. using the reactive api") {
                it("should observe default values") {
                    expect(results).toEventually(equal([defaultValue]))
                }

                it("should set values") {
                    let firstRandomValue = randomGenerator.randomInt()
                    let secondRandomValue = randomGenerator.randomInt()
                    userDefaults.save(value: firstRandomValue, forKey: key)
                    userDefaults.save(value: secondRandomValue, forKey: key)
                    expect(results).toEventually(equal([defaultValue, firstRandomValue, secondRandomValue]))
                }
            }
        }
    }
}
