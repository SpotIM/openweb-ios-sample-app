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
@testable import SpotImCore

final class OWUserDefaultsTests: XCTestCase {
    
    func testSaveAndGet() {
        let userDefaults = OWUserDefaults(userDefaults: UserDefaults(suiteName: UUID().uuidString)!)
        let key = OWUserDefaults.OWKey<Int>.testKey
        let value = 123456
        
        userDefaults.save(value: value, forKey: key)
        let retrievedValue: Int? = userDefaults.get(key: key)
        
        XCTAssertEqual(retrievedValue, value)
    }
    
    func testGetDefaultValue() {
        let userDefaults = OWUserDefaults(userDefaults: UserDefaults(suiteName: UUID().uuidString)!)
        let key = OWUserDefaults.OWKey<Int>.testKey
        let defaultValue = 987654
        
        let retrievedValue: Int = userDefaults.get(key: key, defaultValue: defaultValue)
        
        XCTAssertEqual(retrievedValue, defaultValue)
    }
    
    func testRemove() {
        let userDefaults = OWUserDefaults(userDefaults: UserDefaults(suiteName: UUID().uuidString)!)
        let key = OWUserDefaults.OWKey<Int>.testKey
        let value = 123456
        userDefaults.save(value: value, forKey: key)
        
        let intermediateRetrievedValue: Int? = userDefaults.get(key: key)
        XCTAssertEqual(intermediateRetrievedValue, 123456)
        
        userDefaults.remove(key: key)
        let retrievedValue: Int? = userDefaults.get(key: key)
        
        XCTAssertNil(retrievedValue)
    }
}
