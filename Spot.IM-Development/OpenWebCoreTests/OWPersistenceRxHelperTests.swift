//
//  OWPersistenceRxHelperTests.swift
//  OpenWebCoreTests
//
//  Created by Philip Kluz on 2023-08-05.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import XCTest
import RxSwift
import RxTest
import RxBlocking
import Quick
import Nimble

@testable import SpotImCore

fileprivate enum OWTestKey: String, OWRawableKey {
    typealias T = String // swiftlint:disable:this type_name
    case key
}

final class OWPersistenceRxHelperTests: QuickSpec {

    override func spec() {
        describe("OWPersistenceRxHelper") {
            var disposeBag: DisposeBag!
            var persistenceHelper: OWPersistenceRxHelper!
            var expectedValue: Int!
            var results: [Int]!

            let defaultValue = 123456
            let key = OWRxHelperKey<Int>(key: OWTestKey.key)

            context("no default providing") {
                beforeEach {
                    expectedValue = Int.random(in: 0..<999_999)
                    results = []
                    disposeBag = DisposeBag()
                    persistenceHelper = OWPersistenceRxHelper(decoder: JSONDecoder(), encoder: JSONEncoder())
                    persistenceHelper.observable(key: key, value: try? JSONEncoder().encode(expectedValue), defaultValue: nil).subscribe { event in
                        results.append(event)
                    }.disposed(by: disposeBag)
                }

                afterEach {}

                it("should provide an observable with no default value") {
                    expect(results).toEventually(equal([expectedValue]))
                }

                it("should provide an observable with data") {
                    let newValue = Int.random(in: 0..<999_999)
                    persistenceHelper.onNext(key: key, data: try? JSONEncoder().encode(newValue))
                    expect(results).toEventually(equal([expectedValue, newValue]))
                }
            }

            context("default providing") {

                beforeEach {
                    expectedValue = Int.random(in: 0..<999_999)
                    results = []
                    disposeBag = DisposeBag()
                    persistenceHelper = OWPersistenceRxHelper(decoder: JSONDecoder(), encoder: JSONEncoder())
                    persistenceHelper.observable(key: key, value: try? JSONEncoder().encode(expectedValue), defaultValue: defaultValue).subscribe { event in
                        results.append(event)
                    }.disposed(by: disposeBag)
                }

                it("should provide an observable with a default value") {
                    expect(results).to(equal([expectedValue]))
                }

                it("should provide an observable with an expected value") {
                    let newValue = Int.random(in: 0..<999_999)
                    persistenceHelper.onNext(key: key, data: try? JSONEncoder().encode(newValue))
                    expect(results).toEventually(equal([expectedValue, newValue]))
                }
            }
        }
    }
}
