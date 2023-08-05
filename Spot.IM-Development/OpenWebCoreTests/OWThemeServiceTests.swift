//
//  OWThemeServiceTests.swift
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

final class OWThemeServiceTests: XCTestCase {

    var disposeBag: DisposeBag!

    override func setUp() {
        super.setUp()
        disposeBag = DisposeBag()
    }

    override func tearDown() {
        disposeBag = nil
        super.tearDown()
    }

    func testInitialStyle() {
        let scheduler = TestScheduler(initialClock: 0)
        let observer = scheduler.createObserver(OWThemeStyle.self)

        let themeStyleService = OWThemeStyleService()
        themeStyleService.style.subscribe(observer).disposed(by: disposeBag)

        scheduler.start()

        XCTAssertEqual(observer.events, [.next(0, .light)])
    }

    func testSetStyle() {
        let scheduler = TestScheduler(initialClock: 0)
        let observer = scheduler.createObserver(OWThemeStyle.self)

        let themeStyleService = OWThemeStyleService()
        themeStyleService.style.subscribe(observer).disposed(by: disposeBag)

        scheduler.scheduleAt(10) {
            themeStyleService.setStyle(style: .dark)
        }

        scheduler.scheduleAt(20) {
            themeStyleService.setStyle(style: .light)
        }

        scheduler.start()

        let expectedEvents: [Recorded<Event<OWThemeStyle>>] = [
            .next(0, .light),
            .next(10, .dark),
            .next(20, .light)
        ]

        XCTAssertEqual(observer.events, expectedEvents)
    }

    func testSetEnforcement() {
        let scheduler = TestScheduler(initialClock: 0)
        let observer = scheduler.createObserver(OWThemeStyle.self)

        let themeStyleService = OWThemeStyleService()
        themeStyleService.style.subscribe(observer).disposed(by: disposeBag)

        scheduler.scheduleAt(10) {
            themeStyleService.setEnforcement(enforcement: .theme(.dark))
        }
        
        scheduler.scheduleAt(20) {
            themeStyleService.setStyle(style: .light)
        }
        
        scheduler.scheduleAt(30) {
            observer.onCompleted()
        }

        scheduler.start()

        let expectedEvents: [Recorded<Event<OWThemeStyle>>] = [
            .next(0, .light),
            .next(10, .dark),
            // .next(20, .light) is NOT expected here. due to enforcement of dark before.
            .completed(30)
        ]

        XCTAssertEqual(observer.events, expectedEvents)
    }
}
