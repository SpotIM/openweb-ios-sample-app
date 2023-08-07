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
import Quick
import Nimble

@testable import SpotImCore

final class OWTimeMeasuringServiceTests: QuickSpec {
    
    override func spec() {
        describe("OWTimeMeasuringService") {
            it("should measure time") {
                let timeMeasuringService = OWTimeMeasuringService()
                let key = OWTimeMeasuringService.OWKeys.conversationUIBuildingTime

                let expectation = QuickSpec.current.expectation(description: "measure time expectation")

                timeMeasuringService.startMeasure(forKey: key)

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                    let result = timeMeasuringService.endMeasure(forKey: key)

                    if case let .time(milliseconds) = result {
                        expect(milliseconds).to(beGreaterThanOrEqualTo(10))
                    } else {
                        fail("expected a time measurement result, but received an error: \(result)")
                    }

                    expectation.fulfill()
                }

                QuickSpec.current.wait(for: [expectation], timeout: 1.0)
            }

            it("should report an error when end measure is called without start measure") {
                let timeMeasuringService = OWTimeMeasuringService()
                let key = OWTimeMeasuringService.OWKeys.conversationUIBuildingTime

                let result = timeMeasuringService.endMeasure(forKey: key)

                if case let .error(message) = result {
                    expect(message).to(equal("Error: start measure must be called before end measure"))
                } else {
                    fail("expected an error message, but received a time measurement result: \(result)")
                }
            }
        }
    }
}
