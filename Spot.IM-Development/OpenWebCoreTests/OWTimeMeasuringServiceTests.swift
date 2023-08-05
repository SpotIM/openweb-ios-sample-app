//
//  OWTimeMeasuringServiceTests.swift
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

class OWTimeMeasuringServiceTests: XCTestCase {
    
    func testMeasureTime() {
        let timeMeasuringService = OWTimeMeasuringService()
        let key = OWTimeMeasuringService.OWKeys.conversationUIBuildingTime
        
        let expectation = XCTestExpectation(description: "measure time expectation")
        
        timeMeasuringService.startMeasure(forKey: key)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            let result = timeMeasuringService.endMeasure(forKey: key)
            
            if case let .time(milliseconds) = result {
                XCTAssertGreaterThanOrEqual(milliseconds, 10)
            } else {
                XCTFail("expected a time measurement result, but received an error: \(result)")
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testEndMeasureWithoutStartMeasure() {
        let timeMeasuringService = OWTimeMeasuringService()
        let key = OWTimeMeasuringService.OWKeys.conversationUIBuildingTime
        
        let result = timeMeasuringService.endMeasure(forKey: key)
        
        if case let .error(message) = result {
            XCTAssertEqual(message, "Error: start measure must be called before end measure")
        } else {
            XCTFail("expected an error message, but received a time measurement result: \(result)")
        }
    }
}
