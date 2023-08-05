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
@testable import SpotImCore

class OWPersistenceRxHelperTests: XCTestCase {
    
    private enum OWTestKey: String, OWRawableKey {
        typealias T = String
        
        case key1
        case key2
        case key3
        case key4
    }

    var disposeBag: DisposeBag!
    
    override func setUpWithError() throws {
        disposeBag = DisposeBag()
    }

    override func tearDownWithError() throws {
        disposeBag = nil
    }
    
    func testObservableWithData() {
        let persistenceHelper = OWPersistenceRxHelper(decoder: JSONDecoder(), encoder: JSONEncoder())
        let key = OWRxHelperKey<String>(key: OWTestKey.key1)
        let expectedValue = UUID().uuidString
        let data = try? JSONEncoder().encode(expectedValue)
        let observable = persistenceHelper.observable(key: key, value: data, defaultValue: nil)
        
        let result = try! observable.toBlocking().first()
        
        XCTAssertEqual(result, expectedValue)
    }
    
    func testObservableWithDefaultValue() {
        let persistenceHelper = OWPersistenceRxHelper(decoder: JSONDecoder(), encoder: JSONEncoder())
        let key = OWRxHelperKey<String>(key: OWTestKey.key2)
        let defaultValue = UUID().uuidString
        let observable = persistenceHelper.observable(key: key, value: nil, defaultValue: defaultValue)
        
        let result = try! observable.toBlocking().first()
        
        XCTAssertEqual(result, defaultValue)
    }
    
    func testOnNext() {
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
        
        XCTAssertEqual(observer.events, [.next(0, expectedValue)])
    }
}
