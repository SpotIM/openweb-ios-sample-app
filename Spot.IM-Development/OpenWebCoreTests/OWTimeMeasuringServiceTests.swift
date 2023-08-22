//
//  OWTimeMeasuringServiceTests.swift
//  OpenWebCoreTests
//
//  Created by Philip Kluz on 2023-08-02.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import XCTest
import RxSwift
import Quick
import Nimble

@testable import SpotImCore

class OWTimeMeasuringServiceTests: QuickSpec {

    override func spec() {
        describe("Testing time measuring service") {

            // `sut` stands for `Subject Under Test`
            var sut: OWTimeMeasuringService!
            var key: OWTimeMeasuringService.OWKeys!
            var measureSuccess: Bool!

            beforeEach {
                sut = OWTimeMeasuringService()
                key = OWTimeMeasuringService.OWKeys.conversationUIBuildingTime
                measureSuccess = false
            }

            afterEach {}

            context("1. measuring time") {
                it("should measure time") {
                    sut.startMeasure(forKey: key)

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                        switch sut.endMeasure(forKey: key) {
                        case .time(milliseconds: let time):
                            measureSuccess = time > 0
                        case .error:
                            measureSuccess = false
                        }
                    }

                    expect(measureSuccess).toEventually(equal(true))
                }

                it("should report an error when end measure is called without start measure") {
                    switch sut.endMeasure(forKey: key) {
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
