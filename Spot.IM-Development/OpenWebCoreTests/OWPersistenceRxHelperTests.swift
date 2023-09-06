//
//  OWPersistenceRxHelperTests.swift
//  OpenWebCoreTests
//
//  Created by Philip Kluz on 2023-08-05.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import XCTest
import RxSwift
import Quick
import Nimble

@testable import SpotImCore

fileprivate enum OWTestKey: String, OWRawableKey {
    typealias T = String // swiftlint:disable:this type_name
    case key
}

class OWPersistenceRxHelperTests: QuickSpec {

    override func spec() {
        describe("Testing persistence rx helper") {

            var disposeBag: DisposeBag!
            // `sut` stands for `Subject Under Test`
            var sut: OWPersistenceRxHelper!
            var randomGenerator: RandomGenerator!
            var expectedValue: Int!
            var results: [Int]!
            var decoder: JSONDecoder!
            var encoder: JSONEncoder!

            let defaultValue = 123456
            let key = OWRxHelperKey<Int>(key: OWTestKey.key)

            beforeEach {
                randomGenerator = RandomGenerator()
                expectedValue = randomGenerator.randomInt()
                results = []
                disposeBag = DisposeBag()
                decoder = JSONDecoder()
                encoder = JSONEncoder()
                sut = OWPersistenceRxHelper(decoder: decoder, encoder: encoder)
            }

            context("1. when no defaults are not provided") {
                beforeEach {
                    sut.observable(key: key,
                                   value: try? encoder.encode(expectedValue),
                                   defaultValue: nil)
                    .subscribe { event in
                        results.append(event)
                    }
                    .disposed(by: disposeBag)
                }

                it("should provide an observable with no default value") {
                    expect(results).toEventually(equal([expectedValue]))
                }

                it("should provide an observable with data") {
                    let newValue = randomGenerator.randomInt()
                    sut.onNext(key: key, data: try? encoder.encode(newValue))
                    expect(results).toEventually(equal([expectedValue, newValue]))
                }
            }

            context("2. when default value is provided") {

                beforeEach {
                    sut.observable(key: key,
                                   value: try? encoder.encode(expectedValue),
                                   defaultValue: defaultValue)
                    .subscribe { event in
                        results.append(event)
                    }
                    .disposed(by: disposeBag)
                }

                it("should provide an observable with a default value") {
                    expect(results).to(equal([expectedValue]))
                }

                it("should provide an observable with an expected value") {
                    let newValue = randomGenerator.randomInt()
                    sut.onNext(key: key, data: try? encoder.encode(newValue))
                    expect(results).toEventually(equal([expectedValue, newValue]))
                }
            }
        }
    }
}
