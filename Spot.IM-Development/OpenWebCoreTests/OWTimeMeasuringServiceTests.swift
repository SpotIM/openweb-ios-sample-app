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
            var timeMeasuringService: OWTimeMeasuringService!
            var key: OWTimeMeasuringService.OWKeys!
            var measureSuccess: Bool!

            beforeEach {
                timeMeasuringService = OWTimeMeasuringService()
                key = OWTimeMeasuringService.OWKeys.conversationUIBuildingTime
                measureSuccess = false
            }

            afterEach {
                timeMeasuringService = nil
                key = nil
            }

            context("measuring time") {
                it("should measure time") {
                    timeMeasuringService.startMeasure(forKey: key)

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                        switch timeMeasuringService.endMeasure(forKey: key) {
                        case .time(milliseconds: let time):
                            measureSuccess = time > 0
                        case .error:
                            measureSuccess = false
                        }
                    }

                    expect(measureSuccess).toEventually(equal(true))
                }

                it("should report an error when end measure is called without start measure") {
                    switch timeMeasuringService.endMeasure(forKey: key) {
                    case .time(milliseconds: let time):
                        measureSuccess = time > 0
                    case .error:
                        measureSuccess = false
                    }

                    expect(measureSuccess).to(equal(false))
                }
            }
        }
    }
}
