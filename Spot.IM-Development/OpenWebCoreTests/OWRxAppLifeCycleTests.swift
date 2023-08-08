//
//  OWRxAppLifeCycleTests.swift
//  OpenWebCoreTests
//
//  Created by Philip Kluz on 2023-08-03.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import XCTest
import UIKit
import RxSwift
import RxTest
import RxBlocking
import Quick
import Nimble

@testable import SpotImCore

final class OWRxAppLifeCycleTests: QuickSpec {

    override func spec() {
        describe("OWRxAppLifeCycle") {
            var disposeBag: DisposeBag!

            beforeEach {
                disposeBag = DisposeBag()
            }

            afterEach {
                disposeBag = nil
            }

            it("should receive 'willTerminate' notification") {
                let expectation = QuickSpec.current.expectation(description: "will terminate expectation")
                let notificationCenter = NotificationCenter()
                let appLifeCycle = OWRxAppLifeCycle(
                    notificationCenter: notificationCenter,
                    queueScheduler: SerialDispatchQueueScheduler(qos: .userInteractive, internalSerialQueueName: UUID().uuidString)
                )

                appLifeCycle.willTerminate.subscribe { _ in
                    expectation.fulfill()
                }.disposed(by: disposeBag)

                notificationCenter.post(name: UIApplication.willTerminateNotification, object: nil)

                QuickSpec.current.waitForExpectations(timeout: 1.0, handler: nil)
            }

            it("should receive 'didBecomeActive' notification") {
                let expectation = QuickSpec.current.expectation(description: "did become active expectation")
                let notificationCenter = NotificationCenter()
                let appLifeCycle = OWRxAppLifeCycle(
                    notificationCenter: notificationCenter,
                    queueScheduler: SerialDispatchQueueScheduler(qos: .userInteractive, internalSerialQueueName: UUID().uuidString)
                )

                appLifeCycle.didBecomeActive.subscribe { _ in
                    expectation.fulfill()
                }.disposed(by: disposeBag)

                notificationCenter.post(name: UIApplication.didBecomeActiveNotification, object: nil)

                QuickSpec.current.waitForExpectations(timeout: 1.0, handler: nil)
            }

            it("should receive 'didEnterBackground' notification") {
                let expectation = QuickSpec.current.expectation(description: "did enter background expectation")
                let notificationCenter = NotificationCenter()
                let appLifeCycle = OWRxAppLifeCycle(
                    notificationCenter: notificationCenter,
                    queueScheduler: SerialDispatchQueueScheduler(qos: .userInteractive, internalSerialQueueName: UUID().uuidString)
                )

                appLifeCycle.didEnterBackground.subscribe { _ in
                    expectation.fulfill()
                }.disposed(by: disposeBag)

                notificationCenter.post(name: UIApplication.didEnterBackgroundNotification, object: nil)

                QuickSpec.current.waitForExpectations(timeout: 1.0, handler: nil)
            }

            it("should receive 'willEnterForeground' notification") {
                let expectation = QuickSpec.current.expectation(description: "will enter foreground expectation")
                let notificationCenter = NotificationCenter()
                let appLifeCycle = OWRxAppLifeCycle(
                    notificationCenter: notificationCenter,
                    queueScheduler: SerialDispatchQueueScheduler(qos: .userInteractive, internalSerialQueueName: UUID().uuidString)
                )

                appLifeCycle.willEnterForeground.subscribe { _ in
                    expectation.fulfill()
                }.disposed(by: disposeBag)

                notificationCenter.post(name: UIApplication.willEnterForegroundNotification, object: nil)

                QuickSpec.current.waitForExpectations(timeout: 1.0, handler: nil)
            }

            it("should receive 'willResignActive' notification") {
                let expectation = QuickSpec.current.expectation(description: "will resign active expectation")
                let notificationCenter = NotificationCenter()
                let appLifeCycle = OWRxAppLifeCycle(
                    notificationCenter: notificationCenter,
                    queueScheduler: SerialDispatchQueueScheduler(qos: .userInteractive, internalSerialQueueName: UUID().uuidString)
                )

                appLifeCycle.willResignActive.subscribe { _ in
                    expectation.fulfill()
                }.disposed(by: disposeBag)

                notificationCenter.post(name: UIApplication.willResignActiveNotification, object: nil)

                QuickSpec.current.waitForExpectations(timeout: 1.0, handler: nil)
            }
        }
    }
}
