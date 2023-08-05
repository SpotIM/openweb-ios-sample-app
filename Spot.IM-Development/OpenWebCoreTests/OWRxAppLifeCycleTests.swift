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
@testable import SpotImCore

class OWRxAppLifeCycleTests: XCTestCase {

    var disposeBag: DisposeBag!

    override func setUp() {
        super.setUp()
        disposeBag = DisposeBag()
    }

    override func tearDown() {
        disposeBag = nil
        super.tearDown()
    }
    
    func testWillTerminate() {
        let expectation = XCTestExpectation(description: "will terminate expectation")
        let notificationCenter = NotificationCenter()
        let appLifeCycle = OWRxAppLifeCycle(
            notificationCenter: notificationCenter,
            queueScheduler: SerialDispatchQueueScheduler(qos: .userInteractive, internalSerialQueueName: UUID().uuidString)
        )

        appLifeCycle.willTerminate.subscribe { _ in expectation.fulfill() }.disposed(by: disposeBag)

        notificationCenter.post(name: UIApplication.willTerminateNotification, object: nil)

        wait(for: [expectation], timeout: 1.0)
    }
    
    func testDidBecomeActive() {
        let expectation = XCTestExpectation(description: "did become active expectation")
        let notificationCenter = NotificationCenter()
        let appLifeCycle = OWRxAppLifeCycle(
            notificationCenter: notificationCenter,
            queueScheduler: SerialDispatchQueueScheduler(qos: .userInteractive, internalSerialQueueName: UUID().uuidString)
        )

        appLifeCycle.didBecomeActive.subscribe { _ in expectation.fulfill() }.disposed(by: disposeBag)

        notificationCenter.post(name: UIApplication.didBecomeActiveNotification, object: nil)

        wait(for: [expectation], timeout: 1.0)
    }
    
    func testDidEnterBackground() {
        let expectation = XCTestExpectation(description: "did enter background expectation")
        let notificationCenter = NotificationCenter()
        let appLifeCycle = OWRxAppLifeCycle(
            notificationCenter: notificationCenter,
            queueScheduler: SerialDispatchQueueScheduler(qos: .userInteractive, internalSerialQueueName: UUID().uuidString)
        )

        appLifeCycle.didEnterBackground.subscribe { _ in expectation.fulfill() }.disposed(by: disposeBag)

        notificationCenter.post(name: UIApplication.didEnterBackgroundNotification, object: nil)

        wait(for: [expectation], timeout: 1.0)
    }
    
    func testWillEnterForeground() {
        let expectation = XCTestExpectation(description: "will enter foreground expectation")
        let notificationCenter = NotificationCenter()
        let appLifeCycle = OWRxAppLifeCycle(
            notificationCenter: notificationCenter,
            queueScheduler: SerialDispatchQueueScheduler(qos: .userInteractive, internalSerialQueueName: UUID().uuidString)
        )

        appLifeCycle.willEnterForeground.subscribe { _ in expectation.fulfill() }.disposed(by: disposeBag)

        notificationCenter.post(name: UIApplication.willEnterForegroundNotification, object: nil)

        wait(for: [expectation], timeout: 1.0)
    }
    
    func testWillResignActiveNotification() {
        let expectation = XCTestExpectation(description: "will resign active expectation")
        let notificationCenter = NotificationCenter()
        let appLifeCycle = OWRxAppLifeCycle(
            notificationCenter: notificationCenter,
            queueScheduler: SerialDispatchQueueScheduler(qos: .userInteractive, internalSerialQueueName: UUID().uuidString)
        )

        appLifeCycle.willResignActive.subscribe { _ in expectation.fulfill() }.disposed(by: disposeBag)

        notificationCenter.post(name: UIApplication.willResignActiveNotification, object: nil)

        wait(for: [expectation], timeout: 1.0)
    }
}
