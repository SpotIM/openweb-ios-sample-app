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

    case key1
    case key2
    case key3
    case key4
}

final class OWPersistenceRxHelperTests: QuickSpec {

    override func spec() {
        describe("OWPersistenceRxHelper") {
            var disposeBag: DisposeBag!

            beforeEach {
                disposeBag = DisposeBag()
            }

            afterEach {
                disposeBag = nil
            }

            it("should provide an observable with data") {
                let persistenceHelper = OWPersistenceRxHelper(decoder: JSONDecoder(), encoder: JSONEncoder())
                let key = OWRxHelperKey<String>(key: OWTestKey.key1)
                let expectedValue = UUID().uuidString
                let data = try? JSONEncoder().encode(expectedValue)
                let observable = persistenceHelper.observable(key: key, value: data, defaultValue: nil)

                let result = try? observable.toBlocking().first()

                expect(result).to(equal(expectedValue))
            }

            it("should provide an observable with a default value") {
                let persistenceHelper = OWPersistenceRxHelper(decoder: JSONDecoder(), encoder: JSONEncoder())
                let key = OWRxHelperKey<String>(key: OWTestKey.key2)
                let defaultValue = UUID().uuidString
                let observable = persistenceHelper.observable(key: key, value: nil, defaultValue: defaultValue)

                let result = try? observable.toBlocking().first()

                expect(result).to(equal(defaultValue))
            }

            it("should notify observers on onNext") {
                let scheduler = TestScheduler(initialClock: 0)
                let persistenceHelper = OWPersistenceRxHelper(decoder: JSONDecoder(), encoder: JSONEncoder())
                let key = OWRxHelperKey<String>(key: OWTestKey.key4)
                let expectedValue = UUID().uuidString
                let data = try? JSONEncoder().encode(expectedValue)
                let observable = persistenceHelper.observable(key: key, value: nil)
                let observer = scheduler.createObserver(String.self)

                observable.subscribe(observer).disposed(by: disposeBag)

                persistenceHelper.onNext(key: key, data: data)
                scheduler.start()

                let expectedEvents: [Recorded<Event<String>>] = [
                    .next(0, expectedValue)
                ]

                expect(observer.events).to(equal(expectedEvents))
            }
        }
    }
}
