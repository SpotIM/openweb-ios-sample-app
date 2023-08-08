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

            beforeEach {
                disposeBag = DisposeBag()
            }

            afterEach {
                disposeBag = nil
            }

            context("using the regular api") {
                it("should save and get value") {
                    let userDefaults = OWUserDefaults(userDefaults: UserDefaults(suiteName: UUID().uuidString)!)
                    let key = OWUserDefaults.OWKey<Int>.testKey
                    let value = 123456

                    userDefaults.save(value: value, forKey: key)
                    let retrievedValue: Int? = userDefaults.get(key: key)

                    expect(retrievedValue).to(equal(value))
                }

                it("should get default value") {
                    let userDefaults = OWUserDefaults(userDefaults: UserDefaults(suiteName: UUID().uuidString)!)
                    let key = OWUserDefaults.OWKey<Int>.testKey
                    let defaultValue = 987654

                    let retrievedValue: Int = userDefaults.get(key: key, defaultValue: defaultValue)

                    expect(retrievedValue).to(equal(defaultValue))
                }

                it("should remove value") {
                    let userDefaults = OWUserDefaults(userDefaults: UserDefaults(suiteName: UUID().uuidString)!)
                    let key = OWUserDefaults.OWKey<Int>.testKey
                    let value = 123456
                    userDefaults.save(value: value, forKey: key)

                    let intermediateRetrievedValue: Int? = userDefaults.get(key: key)
                    expect(intermediateRetrievedValue).to(equal(123456))

                    userDefaults.remove(key: key)
                    let retrievedValue: Int? = userDefaults.get(key: key)

                    expect(retrievedValue).to(beNil())
                }
            }

            context("using the reactive api") {
                it("should observe values") {
                    let userDefaults = OWUserDefaults(userDefaults: UserDefaults(suiteName: UUID().uuidString)!)
                    let key = OWUserDefaults.OWKey<Int>.testKey
                    let value = 123456
                    userDefaults.save(value: value, forKey: key)

                    let observable = userDefaults.values(key: key)
                    let result = try? observable.toBlocking().first()

                    expect(result).to(equal(value))
                }

                it("should set values") {
                    let userDefaults = OWUserDefaults(userDefaults: UserDefaults(suiteName: UUID().uuidString)!)
                    let key = OWUserDefaults.OWKey<Int>.testKey
                    let value = 123456
                    let observable = Observable<Int>.just(value)

                    observable.bind(to: userDefaults.setValues(key: key)).disposed(by: disposeBag)
                    let retrievedValue: Int? = userDefaults.get(key: key)

                    expect(retrievedValue).to(equal(value))
                }

                it("should observe values with default value") {
                    let userDefaults = OWUserDefaults(userDefaults: UserDefaults(suiteName: UUID().uuidString)!)
                    let key = OWUserDefaults.OWKey<Int>.testKey
                    let defaultValue = 987654
                    let observable = userDefaults.values(key: key, defaultValue: defaultValue)

                    let result = try? observable.toBlocking().first()

                    expect(result).to(equal(defaultValue))
                }
            }
        }
    }
}
