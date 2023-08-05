//
//  OWUserDefaultsRxTests.swift
//  OpenWebCoreTests
//
//  Created by Philip Kluz on 2023-08-02.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import XCTest
import RxSwift
import RxTest
import RxBlocking
@testable import SpotImCore

final class OWUserDefaultsRxTests: XCTestCase {
    
    var userDefaults: OWUserDefaultsProtocol!
    var disposeBag: DisposeBag!
    
    override func setUpWithError() throws {
        disposeBag = DisposeBag()
    }

    override func tearDownWithError() throws {
        disposeBag = nil
    }
    
    func testValues() {
        let userDefaults = OWUserDefaults(userDefaults: UserDefaults(suiteName: UUID().uuidString)!)
        let key = OWUserDefaults.OWKey<Int>.testKey
        let value = 123456
        userDefaults.save(value: value, forKey: key)
        
        let observable = userDefaults.values(key: key)
        let result = try? observable.toBlocking().first()
        
        XCTAssertEqual(result, value)
    }
    
    func testSetValues() {
        let userDefaults = OWUserDefaults(userDefaults: UserDefaults(suiteName: UUID().uuidString)!)
        let key = OWUserDefaults.OWKey<Int>.testKey
        let value = 123456
        let observable = Observable<Int>.just(value)
        
        observable.bind(to: userDefaults.setValues(key: key)).disposed(by: disposeBag)
        let retrievedValue: Int? = userDefaults.get(key: key)
        
        XCTAssertEqual(retrievedValue, value)
    }
    
    func testValuesWithDefaultValue() {
        let userDefaults = OWUserDefaults(userDefaults: UserDefaults(suiteName: UUID().uuidString)!)
        let key = OWUserDefaults.OWKey<Int>.testKey
        let defaultValue = 987654
        let observable = userDefaults.values(key: key, defaultValue: defaultValue)
        
        let result = try? observable.toBlocking().first()
        
        XCTAssertEqual(result, defaultValue)
    }
}
